`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
//conv
module conv1 #(
    parameter CHANNEL_NUM = 128)
(
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//conv_ram_controller
    input        [`CONV1_ADDR-1 : 0]    addr_most                  ,
    input                               spike_valid                ,
    output   reg [`CONV1_ADDR-1 : 0]    addr_r_spike               ,
    input        [`SYNAPSE_INDEX-1 : 0] s_index_ram                ,                        //12bit channel, 2bit x_pixel, 2bit y_pixel
    output   reg                        conv_over                  , 

//next fifo
    input                               almost_full                ,
    input                               full                       ,
    output                              w_en                       ,
    output reg   [`SYNAPSE_INDEX-1 : 0] s_index_o                   
);


//parameter
parameter padding = 1;
parameter wide = 2;
parameter hight = 2;
parameter stride = 1;
parameter kernel = 3;
parameter radius = (kernel - 1)/2;

//reg 
//valid_pixel_search
reg [`SYNAPSE_INDEX-1 : 0]       s_index_conv               ;
reg                              s_index_valid              ;
reg [`CONV1_CHANNEL_O_WIDE-1 : 0]conv1_channel_o            ;



//wire
wire [(`CONV1_CHANNEL_I_WIDE + `RELATIVE_POS + `CONV1_CHANNEL_O_WIDE + `CONV1_PX_X_WIDE_ + `CONV1_PX_Y_WIDE_ - 1) : 0] valid_pix_pos_i;
wire [(`CONV1_CHANNEL_I_WIDE + `RELATIVE_POS + `CONV1_CHANNEL_O_WIDE + `CONV1_PX_X_WIDE_ + `CONV1_PX_Y_WIDE_ - 1) : 0] valid_pix_pos;
wire                              almost_empty              ;
wire                              empty                     ;
wire                              r_en                      ;
wire [`CONV1_WEIGHT_ADDR-1 : 0]   addr_r_weight             ;
wire [`WEIGHT_INDEX-1 : 0]        weight_index              ;
wire [`MP_WIDE-1 : 0]             MP_1                      ;
wire [`MP_WIDE-1 : 0]             MP_2                      ;
wire [`MP_WIDE-1 : 0]             MP_3                      ;
wire [`MP_WIDE-1 : 0]             MP_4                      ;
wire                              MP_valid                  ;
wire [`CONV1_CHANNEL_O_WIDE-1 : 0]channel_o                 ;

wire [`CONV1_MP_ADDR-1 : 0]       mp_addr_r                 ;
wire [`MP_WIDE-1 : 0]             mp                        ;
wire [`CONV1_MP_ADDR-1 : 0]       mp_addr_w                 ;
wire [`MP_WIDE-1 : 0]             mp_w                      ;
wire                              mp_w_en                   ;
wire                              almost_full_              ;
wire                              full_                     ;
wire [`SYNAPSE_INDEX-1 : 0]       s_index_conv1             ;
wire                              w_en_                     ;

wire                              pixel_ready               ;
//useless
wire                              wea                       ;
wire [`CONV1_WEIGHT_ADDR-1 : 0]   addra                     ;
wire                              dina                      ;

//localparam
localparam IDLE = 2'd0;
localparam RAM = 2'd1;   //fetch the AER to PE
localparam PX_SEARCH = 2'd2;   
localparam OVER = 2'd3; 

//reg
reg  [1 : 0]                            current_state              ;
reg  [1 : 0]                            next_state                 ;

reg  [6 : 0]                            cnt_channel                ;

 
//state machine: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state <= IDLE;
    end
    else 
        current_state <= next_state;
end

//state machine: process 2
always @(*)
begin
   case (current_state)
    IDLE:
    begin
        if ((spike_valid == 1'b1)&&(pixel_ready == 1'b1)) begin
            next_state = RAM;
        end
        else
            next_state = IDLE;
    end 
    RAM:
    begin
        if ((pixel_ready == 1'b1)&&(addr_r_spike == (addr_most - 1))&&(cnt_channel == (CHANNEL_NUM - 1))) begin
            next_state = OVER;
        end
        else
            next_state = PX_SEARCH;
    end
    PX_SEARCH:
    begin        
        if ((spike_valid == 1'b1)&&(pixel_ready == 1'b1)) begin
            next_state = RAM;
        end
        else
            next_state = PX_SEARCH;   
    end
    OVER:
    begin
        next_state = IDLE;
    end
    default: ;
   endcase 
end

//state machine: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_r_spike <= 9'b0;
        s_index_valid <= 1'b0;
        s_index_conv <= {`SYNAPSE_INDEX{1'b0}};
        cnt_channel <= 7'b0;
        conv_over <= 1'b0;
    end
    else begin
        case (next_state)
            IDLE:
            begin
                addr_r_spike <= {`CONV1_ADDR{1'b0}};
                s_index_valid <= 1'b0;
                s_index_conv <= {`SYNAPSE_INDEX{1'b0}};
                cnt_channel <= 7'b0;
                conv_over <= 1'b0;
            end
            RAM:
            begin
                if ((addr_r_spike < (addr_most-1)))begin
                    addr_r_spike <= addr_r_spike + 1;
                    s_index_valid <= 1'b1;
                    s_index_conv <= s_index_ram;
                    cnt_channel <= cnt_channel;
                    conv_over <= conv_over;
                end
                else if (cnt_channel < 7'd127) begin
                    addr_r_spike <= 9'b0;
                    s_index_valid <= 1'b1;
                    s_index_conv <= s_index_ram;
                    cnt_channel <= cnt_channel + 1'b1;
                    conv_over <= conv_over;
                end
                else begin
                    addr_r_spike <= 9'b0;
                    s_index_valid <= 1'b0;
                    s_index_conv <= s_index_conv;
                    cnt_channel <= 7'b0;
                    conv_over <= conv_over;
                end
            end
            PX_SEARCH:
            begin
                s_index_conv <= s_index_conv;
                s_index_valid <= 1'b0;
            end
            OVER:
            begin
                conv_over <= 1'b1;
            end
            default: ;
        endcase
    end
end

//conv1_channel_o
always @(*) begin
    if (!rstn) begin
        conv1_channel_o = 7'b0;
    end
    else begin
        conv1_channel_o = cnt_channel;
    end
end

valid_pixel_search u_valid_pixel_search(
//system signal
    .clk             (clk             ),
    .rstn            (rstn            ),
//conv
    .s_index_conv    (s_index_conv    ),
    .s_index_valid   (s_index_valid   ),
    .conv1_channel_o (conv1_channel_o ),
    .pixel_ready     (pixel_ready     ),
//fifo
    .valid_pix_pos   (valid_pix_pos   ),
    .w_en_r          (w_en_            ),
    .full            (full_            ),
    .almost_full     (almost_full_     )
);



sync_fifo2 #(.WIDTH          (23),
  .DEPTH          (1024),
  .ADDR_WIDTH     (10))
conv_sync_fifo
(
    .clk          (clk          ),
    .rstn         (rstn         ),
    .wr_en        (w_en_        ),
    .wr_data      (valid_pix_pos),
    .rd_en        (r_en         ),
    .rd_data      (valid_pix_pos_i),
    .fifo_full    (full_        ),
    .fifo_empty   (empty        ),
    .almost_full  (almost_full_ ),
    .almost_empty (almost_empty )
);

conv1_weight_search2 u_conv1_weight_search(
    .clk             (clk             ),
    .rstn            (rstn            ),
    .almost_empty    (almost_empty    ),
    .empty           (empty           ),
    .r_en            (r_en            ),
    .valid_pix_pos_i (valid_pix_pos_i ),
    .addr_r_weight   (addr_r_weight   ),
    .weight_index    (weight_index    ),

    .MP_1            (MP_1            ),
    .MP_2            (MP_2            ),
    .MP_3            (MP_3            ),
    .MP_4            (MP_4            ),
    .channel_o       (channel_o       ),
    .MP_valid        (MP_valid        )
);



weight_ram weight_ram(
  .clka(clk),    
  .wea(wea),      
  .addra(addra),  
  .dina(dina),    
  .clkb(clk),    
  .addrb(addr_r_weight),  
  .doutb(weight_index)  
);

MP_refresh_conv1 u_MP_refresh_conv1(
    .clk           (clk           ),
    .rstn          (rstn          ),
    .MP_1          (MP_1          ),
    .MP_2          (MP_2          ),
    .MP_3          (MP_3          ),
    .MP_4          (MP_4          ),
    .channel_o     (channel_o     ),
    .MP_valid      (MP_valid      ),
    .mp_addr_r     (mp_addr_r     ),
    .mp            (mp            ),
    .mp_addr_w     (mp_addr_w     ),
    .mp_w          (mp_w          ),
    .mp_w_en       (mp_w_en       ),
    .almost_full   (almost_full   ),
    .full          (full          ),
    .s_index_conv1 (s_index_conv1 ),
    .w_en          (w_en          )
);

always @(*) begin
    if ((s_index_conv1 == 16'hF1FA)||(s_index_conv1 == 16'hFAF1)) begin
        s_index_o = s_index_conv1;
    end
    else 
        s_index_o = s_index_conv1 - 1;
end  


bram
#(
  .ADDR (9),
  .WIDE (15),
  .DEPTH (16384)
) 
conv_mp (
  .clka(clk),    
  .wea(mp_w_en),      
  .addra(mp_addr_w),  
  .dina(mp_w),    
  .clkb(clk),    
  .addrb(mp_addr_r),  
  .doutb(mp) 
);

endmodule