`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module MP_refresh_conv1 #(
  parameter CONV1_CHANNEL_NUM_O = 127)
(
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//conv1_weight_search
    input      [`MP_WIDE-1 : 0]         MP_1                       ,
    input      [`MP_WIDE-1 : 0]         MP_2                       ,
    input      [`MP_WIDE-1 : 0]         MP_3                       ,
    input      [`MP_WIDE-1 : 0]         MP_4                       ,
    input      [`CONV1_CHANNEL_O_WIDE-1 : 0]  channel_o            ,
    input                               MP_valid                   ,

//MP_ram_r
    output reg [`CONV1_MP_ADDR-1 : 0]   mp_addr_r                  ,
    input      [`MP_WIDE-1 : 0]         mp                         ,

//MP_ram_w
    output reg [`CONV1_MP_ADDR-1 : 0]   mp_addr_w                  ,
    output reg [`MP_WIDE-1 : 0]         mp_w                       ,
    output reg                          mp_w_en                    ,

//next layer fifo
    input                               almost_full                ,
    input                               full                       ,
    output reg [`SYNAPSE_INDEX-1 : 0]   s_index_conv1              ,
    output reg                          w_en                       
);

//localparam
localparam IDLE = 3'd0;
localparam MP_GET = 3'd1;
localparam MP_WAIT = 3'd2;
localparam MP_REFRESH = 3'd3;
localparam FIRE = 3'd4;
localparam WRITE_BACK = 3'd5;

//parameter
parameter kernel_size = 4;
parameter threshold = 567;

//reg 
//reg  (F1FA,FAF1)//;
reg           [2 : 0]                           current_state              ;
reg           [2 : 0]                           next_state                 ;
reg   signed  [`MP_WIDE-1 : 0]                  MP_1_reg                   ;
reg   signed  [`MP_WIDE-1 : 0]                  MP_2_reg                   ;
reg   signed  [`MP_WIDE-1 : 0]                  MP_3_reg                   ;
reg   signed  [`MP_WIDE-1 : 0]                  MP_4_reg                   ;
reg   signed  [`MP_WIDE-1 : 0]                  MP_reg                     ;
reg           [3 : 0]                           cnt_MP                     ;
reg                                             spike                      ;
reg                                             spike1                     ;
reg                                             spike2                     ;
reg                                             spike3                     ;
reg                                             spike4                     ;


//MP_reg
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        MP_1_reg <= {`MP_WIDE{1'b0}};
        MP_2_reg <= {`MP_WIDE{1'b0}};
        MP_3_reg <= {`MP_WIDE{1'b0}};
        MP_4_reg <= {`MP_WIDE{1'b0}};
    end
    else if (MP_valid == 1'b1) begin
        MP_1_reg <= MP_1;
        MP_2_reg <= MP_2;
        MP_3_reg <= MP_3;
        MP_4_reg <= MP_4;
    end
    else if ((cnt_MP == 4'd4)&&(next_state == MP_REFRESH)) begin
        MP_1_reg <= {`MP_WIDE{1'b0}};
        MP_2_reg <= {`MP_WIDE{1'b0}};
        MP_3_reg <= {`MP_WIDE{1'b0}};
        MP_4_reg <= {`MP_WIDE{1'b0}};
    end
    else begin
        MP_1_reg <= MP_1_reg;
        MP_2_reg <= MP_2_reg;
        MP_3_reg <= MP_3_reg;
        MP_4_reg <= MP_4_reg;
    end
end

//state machine: process1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state <= IDLE;
    end
    else
        current_state <= next_state;
end

//state machine: process 2
always @(*) begin
    case (current_state)
        IDLE:
        begin
            if (MP_valid == 1'b1) begin
                next_state = MP_GET;
            end
            else
                next_state = IDLE;
        end 
        MP_GET:
        begin
            next_state = MP_WAIT;
        end
        MP_WAIT:
        begin
            next_state = MP_REFRESH;
        end
        MP_REFRESH:
        begin
            next_state = FIRE;
        end
        FIRE:
        begin
            next_state = WRITE_BACK;
        end
        WRITE_BACK:
        begin
            if (cnt_MP == 4'd4) begin
                next_state = IDLE;
            end
            else begin
                next_state = MP_GET;
            end
        end
        default: ;
    endcase
end

//state machine: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt_MP <= 4'b0;
        mp_addr_r <= {`CONV1_MP_ADDR{1'b0}};
        mp_addr_w <= {`CONV1_MP_ADDR{1'b0}};
        mp_w_en <= 1'b0;
        MP_reg <= {`MP_WIDE{1'b0}};
    end
    else begin
        case (next_state)
            IDLE:
            begin
                spike1 <= 1'b0;
                spike2 <= 1'b0;
                spike3 <= 1'b0;
                spike4 <= 1'b0;
                cnt_MP <= 4'b0;
                mp_addr_r <= {`CONV1_MP_ADDR{1'b0}};
                mp_addr_w <= {`CONV1_MP_ADDR{1'b0}};
                mp_w_en <= 1'b0;      
                MP_reg <= {`MP_WIDE{1'b0}};          
            end 
            MP_GET:
            begin
                cnt_MP <= cnt_MP + 1;
                if (channel_o != CONV1_CHANNEL_NUM_O) begin
                    mp_addr_r <= {{3{1'b0}},cnt_MP} + ((channel_o - 1)* kernel_size);                
                end
                else begin
                    mp_addr_r <= {{3{1'b0}},cnt_MP} + ((channel_o) * kernel_size);
                end
                mp_addr_w <= {`CONV1_MP_ADDR{1'b0}};
                mp_w_en <= 1'b0;  
            end
            MP_WAIT:
            begin
                cnt_MP <= cnt_MP;
                mp_addr_r <= mp_addr_r;
                mp_addr_w <= mp_addr_w;
                mp_w_en <= 1'b0;
            end
            MP_REFRESH:
            begin
                cnt_MP <= cnt_MP;
                mp_addr_r <= mp_addr_r;
                mp_addr_w <= mp_addr_w;
                mp_w_en <= 1'b0;
                case (cnt_MP)
                    4'd1: 
                    begin
                        MP_reg <= mp + MP_1_reg;
                    end
                    4'd2:
                    begin
                        MP_reg <= mp + MP_2_reg;
                    end
                    4'd3:
                    begin
                        MP_reg <= mp + MP_3_reg;
                    end
                    4'd4:
                    begin
                        MP_reg <= mp + MP_4_reg;
                    end
                    default: 
                    begin
                        MP_reg <= {`MP_WIDE{1'b0}}; 
                    end
                endcase
            end
            FIRE:
            begin
                cnt_MP <= cnt_MP;
                mp_addr_r <= mp_addr_r;
                mp_addr_w <= mp_addr_w;
                mp_w_en <= 1'b0;
                if (MP_reg > 597) begin
                    MP_reg <= {`MP_WIDE{1'b0}};
                    case (cnt_MP)
                        4'd1: 
                        begin
                            spike1 <= 1'b1;
                        end
                        4'd2:
                        begin
                            spike2 <= 1'b1;
                        end
                        4'd3:
                        begin
                            spike3 <= 1'b1;
                        end
                        4'd4:
                        begin
                            spike4 <= 1'b1;
                        end 
                        default: 
                        begin
                            spike1 <= spike1;
                            spike2 <= spike2;
                            spike3 <= spike3;
                            spike4 <= spike4;
                        end
                    endcase
                end
                else begin
                    MP_reg <= MP_reg;
                    spike1 <= spike1;
                    spike2 <= spike2;
                    spike3 <= spike3;
                    spike4 <= spike4;
                end
            end
            WRITE_BACK:
            begin
                cnt_MP <= cnt_MP;
                mp_addr_r <= mp_addr_r;
                mp_addr_w <= mp_addr_r;
                mp_w_en <= 1'b1;
                mp_w <= MP_reg;
            end
            default: ;
        endcase
    end
end

//spike sending
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        spike <= 1'b0;
    end
    else if ((current_state == WRITE_BACK)&&(cnt_MP == 4'd4)) begin
        spike <= (spike1)||(spike2)||(spike3)||(spike4);
    end
    else if (w_en == 1'b1) begin
        spike <= 1'b0;
    end
    else
        spike <= spike;
end

//s_index_conv1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s_index_conv1 <= {`SYNAPSE_INDEX{1'b0}};
    end
    else if ((channel_o == ({`CONV1_CHANNEL_O_WIDE{1'b0}} + 1)) && (next_state == MP_GET) && (cnt_MP == 4'd0)) begin
        s_index_conv1 <= 16'hF1FA;
    end
    else if (spike == 1'b1) begin
        s_index_conv1 <= channel_o;
    end
    else if ((channel_o == CONV1_CHANNEL_NUM_O) && (current_state == WRITE_BACK) && (cnt_MP == 4'd4)) begin
        s_index_conv1 <= 16'hFAF1;
    end
    else
        s_index_conv1 <= {`SYNAPSE_INDEX{1'b0}};
end

//w_en
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        w_en <= 1'b0;
    end
    else if (w_en == 1'b1) begin
        w_en <= 1'b0;
    end
    else if ((channel_o == ({`CONV1_CHANNEL_O_WIDE{1'b0}} + 1)) && (next_state == MP_GET) && (cnt_MP == 4'd0)) begin
        w_en <= 1'b1;
    end
    else if (spike == 1'b1) begin
        w_en <= 1'b1;
    end
    else if ((channel_o == CONV1_CHANNEL_NUM_O) && (current_state == WRITE_BACK) && (cnt_MP == 4'd4)) begin
        w_en <= 1'b1;
    end
    else
        w_en <= 1'b0;
end
endmodule //MP_refresh_conv1