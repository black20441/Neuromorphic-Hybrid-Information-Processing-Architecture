
module local_position 
#(parameter PIC_WIDE = 2)
(
    //system signal
    input                                clk                       ,
    input                                rstn                      ,

    //conv
    input         [`INDEX_PX-1 : 0]      pic_index                 ,
    input                                pic_index_valid           ,
    output    reg [`INDEX_PX_WIDE-1 : 0] pic_index_x               ,
    output    reg [`INDEX_PX_WIDE-1 : 0] pic_index_y               ,
    output    reg                        pic_pos_valid                 
);

//localpara
localparam IDLE = 2'd0;
//localparam INIT = 2'd1;
localparam PIC_INDEX  = 2'd1;
localparam WIRTEBACK  = 2'd2;

//reg
reg                    [1 : 0]           pic_pos_current_state     ;
reg                    [1 : 0]           pic_pos_next_state        ;
//reg                    [`INDEX_PX-1 : 0] pic_index_reg             ;

//state machine: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pic_pos_current_state <= IDLE;
    end
    else
        pic_pos_current_state <= pic_pos_next_state;
end

//state machine: process 2
always @(*) begin
   case (pic_pos_current_state)
        IDLE:
        begin
            if (pic_index_valid) 
                pic_pos_next_state = PIC_INDEX;
            else
                pic_pos_next_state = IDLE;
        end
        PIC_INDEX:
        begin
                pic_pos_next_state = WIRTEBACK;
        end
        WIRTEBACK:
        begin
            if (pic_pos_valid)
                pic_pos_next_state = IDLE;
            else
                pic_pos_next_state = WIRTEBACK;
        end
        default: pic_pos_next_state = 2'bxx;
   endcase
end

//state machine: process 3
always @(posedge clk) begin
    begin
        case (pic_pos_next_state)
            IDLE:
            begin
                pic_pos_valid <= 1'b0;
                pic_index_x <= {`INDEX_PX_WIDE{1'b0}};
                pic_index_y <= {`INDEX_PX_WIDE{1'b0}};
            end 
            PIC_INDEX:
            begin
                case (pic_index)
                    4'd0:begin
                        pic_index_x <= 2'b10;
                        pic_index_y <= 2'b10;                        
                    end
                    4'd1:begin
                        pic_index_x <= 2'b01;
                        pic_index_y <= 2'b01;                        
                    end
                    4'd2:begin
                        pic_index_x <= 2'b10;
                        pic_index_y <= 2'b01;                          
                    end
                    4'd3:begin
                        pic_index_x <= 2'b01;
                        pic_index_y <= 2'b10;                          
                    end
                    default: ;
                endcase
            end
            WIRTEBACK:
            begin
                pic_pos_valid <= 1'b1;
            end            
            default: ;
        endcase
    end
end
endmodule //local_position