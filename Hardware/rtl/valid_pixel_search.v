`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module valid_pixel_search (
//system signal
    input                                                  clk                        ,
    input                                                  rstn                       ,
                   
//conv1                   
    input        [`SYNAPSE_INDEX-1 : 0]                    s_index_conv               ,  ///8bit channel ,2 bit x ,2 bit y
    input                                                  s_index_valid              ,
    input        [`CONV1_CHANNEL_O_WIDE-1 : 0]             conv1_channel_o            ,
    output reg                                             pixel_ready                ,

//conv_fifo
    output reg   [(`CONV1_CHANNEL_I_WIDE + `RELATIVE_POS + `CONV1_CHANNEL_O_WIDE + `CONV1_PX_X_WIDE_ + `CONV1_PX_Y_WIDE_ - 1) : 0] valid_pix_pos,
    output reg                                             w_en_r                     ,
    input                                                  full                       ,
    input                                                  almost_full                
    
);

//localparam
localparam IDLE = 3'd0;
localparam INIT = 3'd1;
localparam COL = 3'd2;
localparam ROW = 3'd3;
localparam RELATIVE_PX = 3'd4;
localparam COL_REFRESH = 3'd5;

//parameter
parameter padding = 1;
parameter wide = 3;
parameter hight = 3;
parameter stride = 1;
parameter kernel = 3;
parameter radius = (kernel - 1)/2;

//reg
reg              [2 : 0]                current_state              ;
reg              [2 : 0]                next_state                 ;
reg              [1 : 0]                column_num                 ;
reg                                     column_valid               ;
reg              [1 : 0]                row_num                    ;
reg                                     row_valid                  ;
reg                                     px_valid                   ;
reg              [`INDEX_PX_WIDE-1 : 0] index_px_x                 ;                              //each pixel's position index
reg              [`INDEX_PX_WIDE-1 : 0] index_px_y                 ;
reg              [`INDEX_PX_WIDE-1 : 0] index_px_x_                ;                              //each pixel's position range 
reg              [`INDEX_PX_WIDE-1 : 0] index_px_y_                ;
reg              [2 : 0]                initial_px                 ;
reg              [22 : 0]               valid_pix_pos_reg1         ;
reg              [22 : 0]               valid_pix_pos_reg2         ;
reg              [22 : 0]               valid_pix_pos_reg3         ;
reg              [22 : 0]               valid_pix_pos_reg4         ;
reg                                     s_index_valid_reg          ;
reg              [2 : 0]                cnt_pos                    ;

reg                                     w_en                       ;


//s_index_valid_reg
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s_index_valid_reg <= 1'b0;
    end
    else begin
        if (s_index_valid == 1'b1) begin
            s_index_valid_reg <= 1'b1;
        end
        else if (cnt_pos == 3'd4) begin
            s_index_valid_reg <= 1'b0;
        end
        else begin
            s_index_valid_reg <= s_index_valid_reg;
        end     
    end
end

//w_en_r
always @(*) begin
    if (!rstn) begin
        w_en_r <= 1'b0;
    end
    else if ((s_index_valid_reg == 1'b1)) begin
        w_en_r <= 1'b1;
    end
    else begin
        w_en_r <= 1'b0;
    end
end

//valid_pix_pos_reg1234
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_pix_pos_reg1 <= 23'b0;
        valid_pix_pos_reg2 <= 23'b0;
        valid_pix_pos_reg3 <= 23'b0;
        valid_pix_pos_reg4 <= 23'b0;
    end
    else if ((s_index_valid == 1'b1)) begin
        case ({index_px_x,index_px_y})
            4'b0101: begin
                valid_pix_pos_reg1 <= {s_index_conv [11 : 4],4'b0101,conv1_channel_o,4'b0101};
                valid_pix_pos_reg2 <= {s_index_conv [11 : 4],4'b0001,conv1_channel_o,4'b1001};
                valid_pix_pos_reg3 <= {s_index_conv [11 : 4],4'b0100,conv1_channel_o,4'b0110};
                valid_pix_pos_reg4 <= {s_index_conv [11 : 4],4'b0000,conv1_channel_o,4'b1010};
            end
            4'b1001: begin
                valid_pix_pos_reg1 <= {s_index_conv [11 : 4],4'b1001,conv1_channel_o,4'b0101};
                valid_pix_pos_reg2 <= {s_index_conv [11 : 4],4'b0101,conv1_channel_o,4'b1001};
                valid_pix_pos_reg3 <= {s_index_conv [11 : 4],4'b1000,conv1_channel_o,4'b0110};
                valid_pix_pos_reg4 <= {s_index_conv [11 : 4],4'b0100,conv1_channel_o,4'b1010};
            end
            4'b0110: begin
                valid_pix_pos_reg1 <= {s_index_conv [11 : 4],4'b0110,conv1_channel_o,4'b0101};
                valid_pix_pos_reg2 <= {s_index_conv [11 : 4],4'b0010,conv1_channel_o,4'b1001};
                valid_pix_pos_reg3 <= {s_index_conv [11 : 4],4'b0101,conv1_channel_o,4'b0110};
                valid_pix_pos_reg4 <= {s_index_conv [11 : 4],4'b0001,conv1_channel_o,4'b1010};
            end
            4'b1010: begin
                valid_pix_pos_reg1 <= {s_index_conv [11 : 4],4'b1010,conv1_channel_o,4'b0101};
                valid_pix_pos_reg2 <= {s_index_conv [11 : 4],4'b0110,conv1_channel_o,4'b1001};
                valid_pix_pos_reg3 <= {s_index_conv [11 : 4],4'b1001,conv1_channel_o,4'b0110};
                valid_pix_pos_reg4 <= {s_index_conv [11 : 4],4'b0101,conv1_channel_o,4'b1010};       
            end
            default: begin
                valid_pix_pos_reg1 <= 23'b0;
                valid_pix_pos_reg2 <= 23'b0;
                valid_pix_pos_reg3 <= 23'b0;
                valid_pix_pos_reg4 <= 23'b0;
            end
        endcase
    end
    else begin
        valid_pix_pos_reg1 <= valid_pix_pos_reg1;
        valid_pix_pos_reg2 <= valid_pix_pos_reg2;
        valid_pix_pos_reg3 <= valid_pix_pos_reg3;
        valid_pix_pos_reg4 <= valid_pix_pos_reg4;
    end
end

//valid_pix_pos
always @(*) begin
    if (!rstn) begin
        valid_pix_pos <= 23'b0;
    end
    else begin
        case (cnt_pos)
            3'd1:begin
                valid_pix_pos <= valid_pix_pos_reg1;
            end 
            3'd2:begin
                valid_pix_pos <= valid_pix_pos_reg2;
            end
            3'd3:begin
                valid_pix_pos <= valid_pix_pos_reg3;
            end
            3'd4:begin
                valid_pix_pos <= valid_pix_pos_reg4;
            end
            default: begin
                valid_pix_pos <= 23'b0;
            end
        endcase
    end
end

//channel_i,x_i,y_i
always @(*) begin
    if ((s_index_valid == 1'b1)) begin
        index_px_y = s_index_conv [1 : 0];
        index_px_x = s_index_conv [3 : 2];
        // valid_pix_pos [22 : 15] = s_index_conv [11 : 4];
        // valid_pix_pos [10 : 4] = conv1_channel_o;
    end
    else begin
        index_px_y = index_px_y;
        index_px_x = index_px_x;
        // valid_pix_pos [22 : 15] = valid_pix_pos [22 : 15];
        // valid_pix_pos [10 : 4] = valid_pix_pos [10 : 4] ;
    end
end

//cnt_pos
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt_pos <= 3'b0;
    end
    else if (s_index_valid == 1'b1) begin
        cnt_pos <= cnt_pos + 1;
    end
    else if ((cnt_pos != 3'b0)&&(cnt_pos != 3'd5)) begin
        cnt_pos <= cnt_pos + 1;
    end
    else if (cnt_pos == 3'd5) begin
        cnt_pos <= 3'b0;
    end
    else begin
        cnt_pos <= cnt_pos;
    end
end

//pixel_ready
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pixel_ready <= 1'b1;
    end
    else begin
        if (cnt_pos == 3'd4) begin
            pixel_ready <= 1'b1;
        end
        else if ((cnt_pos == 3'd5)||(s_index_valid == 1'b1)) begin
            pixel_ready <= 1'b0;
        end
        else begin
            pixel_ready <= pixel_ready;
        end
    end
end

// //state machine: process 1
// always @(posedge clk or negedge rstn) begin
//     if (!rstn) begin
//         current_state <= IDLE;
//     end
//     else
//         current_state <= next_state;
// end

// //state machine: process 2
// always @(*) begin
//     if (!rstn) begin
//         next_state = IDLE;
//     end
//     else begin
//         case (current_state)
//             IDLE:
//             begin
//                 if (s_index_valid == 1'b1) begin
//                     next_state = INIT;
//                 end
//                 else
//                     next_state = IDLE;
//             end 
//             INIT:
//             begin
//                 next_state = COL;
//             end
//             COL:
//             begin
//                 if (column_valid == 1'b1) begin
//                     next_state = ROW;
//                 end
//                 else if (column_num <= 2'd2) begin
//                     next_state = COL;
//                 end
//                 else
//                     next_state = IDLE;
//             end
//             ROW:
//             begin
//                 if (row_valid == 1'b1) begin
//                     next_state = RELATIVE_PX;
//                 end
//                 else if (row_num <= 2'd2) begin
//                     next_state = ROW;
//                 end
//                 else
//                     next_state = COL;
//             end
//             RELATIVE_PX:
//             begin
//                 if (row_num == 2'd3) begin
//                     next_state = COL_REFRESH;
//                 end
//                 else
//                     next_state = ROW;
//             end
//             COL_REFRESH:
//             begin
//                 if (column_num == 2'd3) begin
//                     next_state = IDLE;
//                 end
//                 else
//                     next_state = COL;
//             end
//             default: ;
//         endcase
//     end
// end

// //state machine: process 3
// always @(posedge clk or negedge rstn) begin
//     if (!rstn) begin
//         column_num <= 2'b0;
//         row_num <= 2'b0;
//         index_px_x_ <= 2'b0;
//         index_px_y_ <= 2'b0;
//     end
//     else 
//     begin
//         case (next_state)
//             IDLE:
//             begin
//                 px_valid <= 1'b0;
//                 column_num <= 2'b0;
//                 row_num <= 2'b0;
//                 index_px_x_ <= index_px_x - radius;
//                 index_px_y_ <= index_px_y - radius;
//                 valid_pix_pos [3 : 2] <= 2'b0;
//                 valid_pix_pos [1 : 0] <= 2'b0;
//             end 
//             INIT:
//             begin
//                 w_en <= 1'b1;
//                 px_valid <= 1'b0;
//                 column_num <= 2'b0;
//                 row_num <= 2'b0;
//                 column_valid <= 1'b0;
//                 index_px_x_ <= index_px_x - radius;
//                 index_px_y_ <= index_px_y - radius; 
//             end
//             COL:
//             begin
//                 row_num <= 2'b0;
//                 px_valid <= 1'b0;
//                 index_px_y_ <= 2'b0;
//                 if ((index_px_x_ <= 2'd2)&&(index_px_x_ >= 2'd1)&&(column_num < (2 * radius + 1))) begin
//                     column_valid <= 1'b1;
//                     column_num <= column_num;
//                     index_px_x_ <= index_px_x_;
//                 end
//                 else if ((column_num < (2 * radius + 1))) begin
//                     column_valid <= 1'b0;
//                     column_num <= column_num + 1;
//                     index_px_x_ <= index_px_x_ + 1;
//                 end
//                 else begin
//                     column_valid <= 1'b0;
//                     column_num <= column_num;
//                     index_px_x_ <= index_px_x_;
//                 end
//             end
//             ROW:
//             begin
//                 px_valid <= 1'b0;
//                 if ((index_px_y_ <= 2'd2)&&(index_px_y_ >= 2'd1)&&(row_num < (2 * radius + 1))) begin
//                     row_valid <= 1'b1;
//                     row_num <= row_num;
//                     index_px_y_ <= index_px_y_;
//                 end
//                 else if ((row_num < (2 * radius + 1))) begin
//                     row_valid <= 1'b0;
//                     row_num <= row_num + 1;
//                     index_px_y_ <= index_px_y_ + 1;
//                 end
//                 else begin
//                     row_valid <= 1'b0;
//                     row_num <= row_num;
//                     index_px_y_ <= index_px_y_;
//                 end
//             end
//             RELATIVE_PX:
//             begin
//                 valid_pix_pos [3 : 2] <= index_px_x_;
//                 valid_pix_pos [1 : 0] <= index_px_y_;
//                 column_valid <= 1'b0;
//                 row_valid <= 1'b0;
//                 row_num <= row_num + 1;
//                 index_px_y_ <= index_px_y_ + 1;
//                 valid_pix_pos[14 : 13] <= index_px_x - index_px_x_ + 1;
//                 valid_pix_pos[12 : 11] <= index_px_y - index_px_y_ + 1;
//                 if (almost_full == 1'b0) begin
//                     w_en <= 1'b1;
//                     px_valid <= 1'b1;
//                 end
//                 else begin
//                     w_en <= 1'b0;
//                     px_valid <= 1'b0;
//                 end
//             end
//             COL_REFRESH:
//             begin
//                 if (row_num == 2'd3) begin
//                     column_num <= column_num + 1;
//                     index_px_x_ <= index_px_x_ + 1;
//                 end
//                 else begin
//                     column_num <= column_num;
//                     index_px_x_ <= index_px_x_;
//                 end
//             end
//             default: ;
//         endcase
//     end
// end

// //w_en_r
// always @(*) begin
//     if (!rstn) begin
//         w_en_r = 1'b0;
//     end
//     else if (current_state == RELATIVE_PX) begin
//         w_en_r = w_en;
//     end
//     else
//         w_en_r = 1'b0;
// end

endmodule //valid_pixel_search