`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module conv1_weight_search2 
#(
parameter CONV1_CHANNEL_NUM_O = 128,
parameter CONV1_CHANNEL_NUM_I = 256)
(
//system signal
    input                                         clk                    ,
    input                                         rstn                   ,

//conv_fifo      
    input                                         almost_empty           ,
    input                                         empty                  ,
    output reg                                    r_en                   ,
    input            [(`CONV1_CHANNEL_I_WIDE+`RELATIVE_POS+`CONV1_CHANNEL_O_WIDE+`CONV1_PX_X_WIDE_+`CONV1_PX_Y_WIDE_- 1) : 0] valid_pix_pos_i,
      
//weight_ram      
    output reg       [`CONV1_WEIGHT_ADDR-1 : 0]   addr_r_weight          ,
    input            [`WEIGHT_INDEX-1 : 0]        weight_index           ,
      
//conv      
//    input            [1 : 0]                   timestep_switch         ,
      
//MP_refresh_co      
    output reg signed[`MP_WIDE-1 : 0]               MP_1                 ,
    output reg signed[`MP_WIDE-1 : 0]               MP_2                 ,
    output reg signed[`MP_WIDE-1 : 0]               MP_3                 ,
    output reg signed[`MP_WIDE-1 : 0]               MP_4                 ,
    output reg       [`CONV1_CHANNEL_O_WIDE-1 : 0]  channel_o            ,
    output reg                                      MP_valid             
);



//parameter
parameter kernel_size = 4;


//reg
reg [(`CONV1_CHANNEL_I_WIDE+`RELATIVE_POS+`CONV1_CHANNEL_O_WIDE+`CONV1_PX_X_WIDE_+`CONV1_PX_Y_WIDE_- 1) : 0] valid_pix_pos_i_reg;
reg [`CONV1_CHANNEL_I_WIDE-1 : 0]           channel_i;
reg [`CONV1_CHANNEL_O_WIDE-1 : 0]           channel_o_reg;
reg [`CONV1_PX_X_WIDE-1 : 0]                channel_i_x;
reg [`CONV1_PX_Y_WIDE-1 : 0]                channel_i_y;
reg [`CONV1_PX_X_WIDE_-1 : 0]               channel_o_x;
reg [`CONV1_PX_Y_WIDE_-1 : 0]               channel_o_y;
reg [3 : 0]                                 relative_px;
reg [3 : 0]                                 weight_px;

reg                                         r_en_reg;
reg                                         weight_valid;
reg                                         weight_valid_reg;
reg   signed [`WEIGHT_WIDE-1 : 0]           weight;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight1;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight2;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight3;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight4;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight5;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight6;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight7;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight8;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight9;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight10;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight11;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight12;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight13;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight14;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight15;
wire  signed [`WEIGHT_WIDE-1 : 0]           weight16;


//weight register
assign  weight1 =  16'd12;
assign  weight2 = -16'd27;
assign  weight3 =  16'd31;
assign  weight4 = -16'd57;
assign  weight5 =  16'd71;
assign  weight6 = -16'd4 ;
assign  weight7 = -16'd44;
assign  weight8 = -16'd127;
assign  weight9 =  16'd44;
assign  weight10 = -16'd83;
assign  weight11 = 16'd117;
assign  weight12 = 16'd4;
assign  weight13 = -16'd19;
assign  weight14 =  16'd21;
assign  weight15 = -16'd35;
assign  weight16 = -16'd12;


always @(*) begin
    case (weight_index)
        4'd0: weight = weight1;
        4'd1: weight = weight2;
        4'd2: weight = weight3;
        4'd3: weight = weight4;
        4'd4: weight = weight5;
        4'd5: weight = weight6;
        4'd6: weight = weight7;
        4'd7: weight = weight8;
        4'd8: weight = weight9;
        4'd9: weight = weight10;
        4'd10: weight = weight11;
        4'd11: weight = weight12;
        4'd12: weight = weight13;
        4'd13: weight = weight14;
        4'd14: weight = weight15;
        4'd15: weight = weight16;
        default: weight = 16'b0;
    endcase
end

//valid_pix_pos_i_reg
always @(*) begin
    if (!rstn) begin
        valid_pix_pos_i_reg = 23'b0;
    end
    else if (r_en_reg == 1'b1) begin
        valid_pix_pos_i_reg = valid_pix_pos_i;
    end
    else begin
        valid_pix_pos_i_reg = 23'bx;
    end
end

//r_en_reg
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        r_en_reg <= 1'b0;
    end
    else if (r_en_reg == 1'b1) begin
        r_en_reg <= 1'b0;
    end
    else if (r_en == 1'b1) begin
        r_en_reg <= 1'b1;
    end
    else begin
        r_en_reg <= 1'b0;
    end
end

//channel_i,x,y,channel_o,x,y
always @(*) begin
    channel_i = valid_pix_pos_i_reg[22 : 15];
    channel_i_x = valid_pix_pos_i[3 : 2];
    channel_i_y = valid_pix_pos_i[1 : 0];
    channel_o_reg = valid_pix_pos_i_reg[10 : 4];
    channel_o_x = valid_pix_pos_i_reg[14 : 13];
    channel_o_y = valid_pix_pos_i_reg[12 : 11];
    // addr_r_weight = (kernel_size * channel_i) + (CONV1_CHANNEL_NUM_I * channel_o * 4) + weight_px - 1;
end

//relative_px
always @(*) begin
    case ({channel_i_y,channel_i_x})
        4'b0101:relative_px = 4'd1; 
        4'b0110:relative_px = 4'd2; 
        4'b1001:relative_px = 4'd3; 
        4'b1010:relative_px = 4'd4; 
        default: relative_px = 4'bx;
    endcase
end

always @(*) begin
    case ({channel_o_y,channel_o_x})
        4'b0000:weight_px = 4'd1; 
        4'b0001:weight_px = 4'd2; 
        4'b0010:weight_px = 4'd5; 
        4'b0100:weight_px = 4'd3; 
        4'b0101:weight_px = 4'd4; 
        4'b0110:weight_px = 4'd6; 
        4'b1000:weight_px = 4'd7; 
        4'b1001:weight_px = 4'd8; 
        4'b1010:weight_px = 4'd9; 
        default: weight_px = 4'bx;
    endcase
end

//MP_valid
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        channel_o <= {`CONV1_CHANNEL_O_WIDE{1'b0}};
    end
    else if (channel_o != channel_o_reg) begin
        channel_o <= channel_o_reg;
    end
    else
        channel_o <= channel_o;
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        MP_valid <= 1'b0;
    end
    else if ((channel_o != channel_o_reg)) begin  //||((channel_o == (CONV1_CHANNEL_NUM_O - 1))&&(empty == 1'b1))
        MP_valid <= 1'b1;
    end
    else
        MP_valid <= 1'b0;
end

//r_en
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        r_en <= 1'b0;
    end
    else if (r_en == 1'b1) begin
        r_en <= 1'b0;
    end
    else if (empty != 1'b1) begin
        r_en <= 1'b1;
    end
    else begin
        r_en <= 1'b0;
    end
end

//weight_valid
always @(*) begin
    if (!rstn) begin
        weight_valid = 1'b0;
    end
    else if ((weight_valid == 1'b1)&&(weight_valid_reg == 1'b1)) begin
        weight_valid = 1'b0;
    end
    else if ((weight_px == 4'd1)||(weight_px == 4'd2)||(weight_px == 4'd3)||(weight_px == 4'd4)) begin
        weight_valid = 1'b1;
    end
    else begin
        weight_valid = 1'b0;
    end
end

//weight_valid_reg
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        weight_valid_reg <= 1'b0;
    end
    else if (weight_valid_reg == 1'b1) begin
        weight_valid_reg <= 1'b0;
    end
    else if (weight_valid == 1'b1) begin
        weight_valid_reg <= 1'b1;
    end
    else begin
        weight_valid_reg <= 1'b0;
    end
end

//addr_weight
always @(*) begin
    if (!rstn) begin
        addr_r_weight <= {`CONV1_WEIGHT_ADDR{1'b0}};
    end
    else if(weight_valid == 1'b1) begin
        addr_r_weight <= (kernel_size * channel_i) + (CONV1_CHANNEL_NUM_I * channel_o * 4) + weight_px - 1;
    end
    else begin
        addr_r_weight <= {`CONV1_WEIGHT_ADDR{1'b0}};
    end
end

//mp_refresh
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        MP_1 <= {`MP_WIDE{1'b0}};
        MP_2 <= {`MP_WIDE{1'b0}};
        MP_3 <= {`MP_WIDE{1'b0}};
        MP_4 <= {`MP_WIDE{1'b0}};
    end
    else if (weight_valid_reg == 1'b1) begin
        case (relative_px)
            4'd1:MP_1 <= MP_1 + {weight[`WEIGHT_WIDE - 1],weight[`WEIGHT_WIDE - 3 : 0]};
            4'd2:MP_2 <= MP_2 + {weight[`WEIGHT_WIDE - 1],weight[`WEIGHT_WIDE - 3 : 0]};
            4'd3:MP_3 <= MP_3 + {weight[`WEIGHT_WIDE - 1],weight[`WEIGHT_WIDE - 3 : 0]};
            4'd4:MP_4 <= MP_4 + {weight[`WEIGHT_WIDE - 1],weight[`WEIGHT_WIDE - 3 : 0]};
            default: ;
        endcase
    end
    else if (MP_valid == 1'b1) begin
        MP_1 <= {`MP_WIDE{1'b0}};
        MP_2 <= {`MP_WIDE{1'b0}};
        MP_3 <= {`MP_WIDE{1'b0}};
        MP_4 <= {`MP_WIDE{1'b0}};
    end
    else begin
        MP_1 <= MP_1;
        MP_2 <= MP_2;
        MP_3 <= MP_3;
        MP_4 <= MP_4;
    end
end

endmodule //conv1_weight_search