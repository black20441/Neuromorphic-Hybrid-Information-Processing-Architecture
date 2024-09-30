`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module TOP_conv (
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//test ram
//    output  reg [9 : 0]                 addr_test_ram              ,
//    input       [7 : 0]                 spike                      ,

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

//wire
// wire                                    wea                        ;
// wire         [9 : 0]                    addra                      ;
// wire         [7 : 0]                    dina                       ;
// wire         [7 : 0]                    spike                      ;

// wire         [9 : 0]                    addr_test_ram              ;
// wire         [7 : 0]                    test_data                  ;
// wire                                    uart_done                  ;

// wire         [15 : 0]                   s_index                    ;
// wire                                    w_en_1                     ;
// wire                                    r_en_1                     ;
// wire                                    full_1                     ;
// wire                                    almost_full_1              ;
// wire         [1 : 0]                    timestep_switch            ;
// wire                                    empty_1                    ;
// wire                                    almost_empty_1             ;

// wire         [15 : 0]                   s_index_i                  ;
wire         [`CONV1_ADDR-1 : 0]        addr_r_spike               ;
wire         [15 : 0]                   s_index_ram                ;
wire         [`CONV1_ADDR-1 : 0]        addr_most                  ;
wire                                    addr_valid                 ;
wire                                    conv_over                  ;


///////////////



// blk_mem_test_ram your_instance_name (
//   .clka(clk),    // input wire clka
//   .wea(wea),      // input wire [0 : 0] wea
//   .addra(addra),  // input wire [9 : 0] addra
//   .dina(dina),    // input wire [7 : 0] dina
//   .clkb(clk),    // input wire clkb
//   .addrb(addr_test_ram),  // input wire [9 : 0] addrb
//   .doutb(spike )  // output wire [7 : 0] doutb
// );

// test_ram u_test_ram
// (
//   .clka(clk),    // input wire clka
//   .wea(wea),      // input wire [0 : 0] wea
//   .addra(addra),  // input wire [9 : 0] addra
//   .dina(dina),    // input wire [7 : 0] dina
//   .clkb(clk),    // input wire clkb
//   .addrb(addr_test_ram),  // input wire [9 : 0] addrb
//   .doutb(spike )  // output wire [7 : 0] doutb
// );

// uart_test u_uart_test(
//     .clk           (clk           ),
//     .rstn          (rstn          ),
//     .addr_test_ram (addr_test_ram ),
//     .spike         (spike         ),
//     .test_data     (test_data     ),
//     .uart_done     (uart_done     )
// );

// controller u_controller(
//     .clk             (clk             ),
//     .rstn            (rstn            ),
//     .uart_done       (uart_done       ),
//     .uart_data       (test_data       ),
//     .s_index         (s_index         ),
//     .w_en            (w_en_1          ),
//     .full            (full_1          ),
//     .almost_full     (almost_full_1   ),
//     .timestep_switch (timestep_switch )
// );


// sync_fifo u_sync_fifo(
//     .clk          (clk          ),
//     .rstn         (rstn         ),
//     .wr_en        (w_en_1       ),
//     .wr_data      (s_index      ),
//     .rd_en        (r_en_1       ),
//     .rd_data      (s_index_i    ),
//     .fifo_full    (full_1       ),
//     .fifo_empty   (empty_1      ),
//     .almost_full  (almost_full_1),
//     .almost_empty (almost_empty_1)
// );

/*
fifo_conv_buffer fifo_conv (
  .clk(clk),                    // input wire clk
  .srst(rstn),                  // input wire srst
  .din(s_index),                    // input wire [15 : 0] din
  .wr_en(w_en_1),                // input wire wr_en
  .rd_en(r_en_1),                // input wire rd_en
  .dout(s_index_i),                  // output wire [15 : 0] dout
  .full(full_1),                  // output wire full
  .almost_full(almost_full_1),    // output wire almost_full
  .empty(empty_1),                // output wire empty
  .almost_empty(almost_empty_1)  // output wire almost_empty
);*/

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