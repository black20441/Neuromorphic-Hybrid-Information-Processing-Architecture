`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module TOP_conv (
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//fifo
    input        [15 : 0]               s_index_i                  ,
    input                               empty                      ,
    input                               almost_empty               ,
    output                              r_en                       ,

//next fifo
    input                               almost_full                ,
    input                               full                       ,
    output                              w_en                       ,
    output       [`SYNAPSE_INDEX-1 : 0] s_index_o                   
);

wire         [`CONV1_ADDR-1 : 0]        addr_r_spike               ;
wire         [15 : 0]                   s_index_ram                ;
wire         [`CONV1_ADDR-1 : 0]        addr_most                  ;
wire                                    addr_valid                 ;
wire                                    conv_over                  ;



conv_ram_controller u_conv_ram_controller(
    .clk          (clk          ),
    .rstn         (rstn         ),
    .s_index_i    (s_index_i    ),
    .empty        (empty        ),
    .almost_empty (almost_empty ),
    .r_en         (r_en         ),
    .addr_r_spike (addr_r_spike ),
    .s_index_ram  (s_index_ram  ),
    .addr_most    (addr_most    ),
    .addr_valid   (addr_valid   ),
    .ram_release  (conv_over    )
);

conv1 u_conv1(
    .clk          (clk          ),
    .rstn         (rstn         ),
    .addr_most    (addr_most    ),
    .spike_valid  (addr_valid   ),
    .addr_r_spike (addr_r_spike ),
    .s_index_ram  (s_index_ram  ),
    .conv_over    (conv_over    ),
    .almost_full  (almost_full  ),
    .full         (full         ),
    .w_en         (w_en         ),
    .s_index_o    (s_index_o    )
);

endmodule //TOP