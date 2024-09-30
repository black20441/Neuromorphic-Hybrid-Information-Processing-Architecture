
module pic_num_detection 
#(parameter PIC_WIDE_square = 4)
(
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//AER_coding
    input         [1 : 0]               timestep_switch            , 

    input         [15 : 0]              AER_index                  ,
    input                               AER_valid                  ,
    output    reg [`INDEX_PIC-1 : 0]    pic_num                    ,
    output    reg [`INDEX_PX-1 : 0]     pic_index                  ,
    output    reg                       pic_valid                   
);
    
//localpara
localparam RST = 3'd0;
localparam IDLE = 3'd1;
localparam INIT = 3'd2;
localparam CAL = 3'd3;
localparam PIC = 3'd4;
localparam WIRTEBACK  = 3'd5;

//reg
reg                    [2 : 0]         pic_num_current_state      ;
reg                    [2 : 0]         pic_num_next_state         ;
reg                    [15 : 0]        AER_index_reg              ;
reg                    [15 : 0]        AER_index_remain           ;



//state machine: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pic_num_current_state <= IDLE;
    end
    else
        pic_num_current_state <= pic_num_next_state;
end

//state machine: process 2
always @(*) begin
   case (pic_num_current_state)
    RST:
    begin
        pic_num_next_state = IDLE;
    end
    IDLE:
    begin
        if (AER_valid) 
            pic_num_next_state = INIT;
        else 
            pic_num_next_state = IDLE;
    end
    INIT:
    begin
        pic_num_next_state = CAL;
    end
    CAL:
    begin
        pic_num_next_state = PIC;
    end
    PIC:
    begin
        if (AER_index_remain < PIC_WIDE_square) 
            pic_num_next_state = WIRTEBACK;
        else
            pic_num_next_state = PIC;
    end
    WIRTEBACK:
    begin
        if ((pic_valid)&&(timestep_switch == 2'b11))
            pic_num_next_state = RST;
        else if (pic_valid) begin
            pic_num_next_state = IDLE;
        end
        else 
            pic_num_next_state = WIRTEBACK;
    end
    default: pic_num_next_state = 2'bxx;
   endcase
end

//state machine: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        AER_index_reg <= 16'b0;
        AER_index_remain <= 16'b0;
        pic_valid <= 1'b0;
        pic_num <= {`INDEX_PIC{1'b0}};
        pic_index <= {`INDEX_PX{1'b0}};
    end
    else
    begin
        case (pic_num_next_state)
            RST:
            begin
                AER_index_reg <= 16'b0;
                AER_index_remain <= 16'b0;
                pic_valid <= 1'b0;
                pic_num <= {`INDEX_PIC{1'b0}};
                pic_index <= {`INDEX_PX{1'b0}};
            end
            IDLE:
            begin
                AER_index_reg <= 16'b0;
                AER_index_remain <= (pic_num << 2);
                pic_valid <= 1'b0;
                pic_num <= pic_num;
                pic_index <= {`INDEX_PX{1'b0}};
            end 
            INIT:
                AER_index_reg <= AER_index;
            CAL:
            begin
                AER_index_remain <= AER_index_reg - AER_index_remain;
            end
            PIC:
            begin
                if (AER_index_remain > 16'd4) begin
                    AER_index_remain <= AER_index_remain - PIC_WIDE_square;
                    pic_num <= pic_num + 1;                    
                end
                else if (AER_index_remain == 16'd4) begin
                    AER_index_remain <= AER_index_remain - PIC_WIDE_square;
                    pic_num <= pic_num;
                end
                else begin
                    AER_index_remain <= AER_index_remain;
                    pic_num <= pic_num;
                end
            end
            WIRTEBACK:
                begin
                    pic_index <= AER_index_remain [`INDEX_PX-1 : 0];
                    pic_valid <= 1'b1;
                end
            default: ;
        endcase
    end
end



endmodule //pic_num_detection