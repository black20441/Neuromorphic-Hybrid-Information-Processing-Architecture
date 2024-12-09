

module AER_coding (
//system input
    input                               clk                        ,
    input                               rstn                       ,


//controller
    input                               coding_sign                ,//0 AER, 1 二值
    input         [1 : 0]               timestep_switch            ,
    input         [15 : 0]              s_index                    ,
    output   reg  [15 : 0]              AER_index_position         ,
    output   reg                        AER_position_valid                     
);

//localpara
localparam IDLE = 2'd0;
localparam AER  = 2'd1;
localparam PX = 2'd2;
localparam WRITEBACK = 2'd3;

//reg
reg      [1 : 0]         AER_current_state;
reg      [1 : 0]         AER_next_state;
reg      [15 : 0]        s_cnt;
reg      [3 : 0]         s_cnt2;
reg                      AER_done;
reg      [15 : 0]        AER_index;
reg                      AER_valid;
reg                      pic_pos_valid_;

      
//wire
wire     [9 : 0]         pic_num;
wire     [3 : 0]         pic_index;
wire                     pic_valid;
wire     [1 : 0]         pic_index_x;
wire     [1 : 0]         pic_index_y;
wire                     pic_pos_valid;


//pic_pos_valid_
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pic_pos_valid_ <= 1'b0;
    end
    else if(pic_pos_valid == 1'b1) begin
        pic_pos_valid_ <= 1'b1;
    end
    else begin
        pic_pos_valid_ <= 1'b0;
    end
end

//state machine: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        AER_current_state <= IDLE;
    end
    else begin
        AER_current_state <= AER_next_state;
    end
end

//state machine: process2
always @(*) 
begin
    case (AER_current_state)
        IDLE:
        begin
            if (coding_sign == 1'b1) begin
                AER_next_state = AER;
            end
            else
                AER_next_state = IDLE;
        end
        AER:
        begin
            if (((s_cnt2 == 16'd15)&&(s_index[15] == 1'b0))||((s_cnt2 == 16'd15)&&(s_index[15] == 1'b1)&&(pic_pos_valid_ == 1'b1))) begin
                AER_next_state = WRITEBACK;
            end
            else if (pic_pos_valid == 1'b1) begin
                AER_next_state = PX;
            end
            else
                AER_next_state = AER;
        end
        PX: 
        begin
            if (s_cnt2 == 16'd15) begin
                AER_next_state = WRITEBACK;
            end
            else
                AER_next_state = AER;
        end
        WRITEBACK:
        begin
            AER_next_state = IDLE;
        end
        default: AER_next_state = 2'bxx;
    endcase
end

//state machine: process3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s_cnt <= 16'b0;
        s_cnt2 <= 4'b0;
        AER_index <= 16'b0;
        AER_valid <= 1'b0;
    end
    else
    begin
        case (AER_next_state)
            IDLE:
            begin
                s_cnt2 <= 4'b0;
                AER_index <= 16'b0;
                AER_valid <= 1'b0;
            end
            AER:
            begin
            case (s_cnt2)
                4'd0:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[0] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd1;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[0] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd0;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd1;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd1:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[1] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd2;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[1] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd1;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd2;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end 
                4'd2:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[2] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd3;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[2] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd2;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd3;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd3:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[3] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd4;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[3] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd3;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd4;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd4:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[4] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd5;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[4] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd4;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd5;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd5:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[5] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd6;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[5] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd5;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd6;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd6:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[6] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd7;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                  
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[6] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd6;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd7;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd7:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[7] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd8;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[7] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd7;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd8;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd8:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[8] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd9;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[8] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd8;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd9;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd9:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[9] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd10;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[9] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd9;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd10;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd10:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[10] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd11;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[10] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd10;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd11;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd11:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[11] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd12;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[11] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd11;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd12;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                    // if (AER_done == 1'b1) begin
                    //     AER_valid <= 1'b0;                        
                    // end
                    // else
                    //     AER_valid <= 1'b0;
                end
                4'd12:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[12] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd13;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[12] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd12;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd13;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd13:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[13] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd14;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                     
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[13] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd13;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd14;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd14:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[14] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd15;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                        
                    end
                    else if((s_index[14] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd14;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd15;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
                4'd15:begin
                    AER_position_valid <= 1'b0;
                    if ((s_index[15] == 1'b1)&&(pic_pos_valid_ == 1'b1)) begin
                        s_cnt2 <= 4'd15;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;                        
                    end
                    else if (AER_done == 1'b1) begin
                        AER_valid <= 1'b0;
                         
                    end
                    else if((s_index[15] == 1'b1)&&(pic_pos_valid_ != 1'b1)) begin
                        s_cnt2 <= 4'd15;
                        AER_index <= s_cnt + {11'b0,s_cnt2} + 16'd1;
                        AER_done <= 1'b1;
                        AER_valid <= 1'b1;
                    end
                    else begin
                        s_cnt2 <= 4'd15;
                        AER_valid <= 1'b0;
                        AER_done <= 1'b0;
                        AER_index <= 16'b0;
                    end
                end
            default: begin
                    s_cnt2 <= 4'd0;
                    AER_valid <= 1'b0;
                    AER_index <= 16'b0;
            end
            endcase
            end
            PX:
            begin
                    AER_index_position [15 : 4] <= {{2{1'b0}},pic_num};
                    AER_index_position [3 : 2] <= pic_index_x;
                    AER_index_position [1 : 0] <= pic_index_y;
                    AER_position_valid <= 1'b1;
            end
            WRITEBACK:
            begin
                AER_done <= 1'b0;
                AER_position_valid <= 1'b0;
                if (s_cnt2 == 4'd15) begin
                    s_cnt <= s_cnt + 16'd16;
                end
                else if (timestep_switch == 2'b11) begin
                    s_cnt2 <= 16'b0;
                end
                else
                    s_cnt2 <= s_cnt2;
            end 
            default:begin
                    s_cnt2 <= 4'b0;
                    s_cnt  <= 16'bx;
                    AER_index <= 16'b0;
                    AER_valid <= 1'b0; 
            end
            endcase
    end
end



pic_num_detection u_pic_num_detection(
    .clk       (clk       ),
    .rstn      (rstn      ),
    .timestep_switch(timestep_switch),
    .AER_index (AER_index ),
    .AER_valid (AER_valid ),
    .pic_num   (pic_num   ),
    .pic_index (pic_index ),
    .pic_valid (pic_valid )
);

local_position u_local_position(
    .clk             (clk             ),
    .rstn            (rstn            ),
    .pic_index       (pic_index       ),
    .pic_index_valid (pic_valid       ),
    .pic_index_x     (pic_index_x     ),
    .pic_index_y     (pic_index_y     ),
    .pic_pos_valid   (pic_pos_valid   )
);


endmodule //AER_coding