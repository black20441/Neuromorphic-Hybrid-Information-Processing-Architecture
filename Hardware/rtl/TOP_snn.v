`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module TOP_snn (
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//test ram
//    output  reg [9 : 0]                 addr_test_ram              ,
//    input       [7 : 0]                 spike                      ,

//next fifo
    input                               almost_full                ,
    input                               full                       ,
    output                              w_en                       ,
    output       [`SYNAPSE_INDEX-1 : 0] s_index_o                   
);


//wire test_ram
wire                                    wea                        ;
wire             [9 : 0]                addra                      ;
wire             [7 : 0]                dina                       ;
wire             [9 : 0]                addr_test_ram              ;
wire             [7 : 0]                spike                      ;

//uart test
wire         [7 : 0]                    test_data                  ;
wire                                    uart_done                  ;

//wire spike_code_converter
wire         [15 : 0]                   s_index                    ;
wire                                    w_en_1                     ;
wire                                    r_en_1                     ;
wire                                    full_1                     ;
wire                                    almost_full_1              ;
wire         [1 : 0]                    timestep_switch            ;
wire                                    empty_1                    ;
wire                                    almost_empty_1             ;

//wire fifo
wire         [15 : 0]                   s_index_1                  ;


//wire conv
wire                                    almost_full_2              ;
wire                                    full_2                     ;
wire                                    w_en_2                     ;
wire         [15 : 0]                   s_index_o_2                ;
wire                                    r_en_2                     ;
wire         [15 : 0]                   fc_rd_data                 ;
wire                                    empty_2                    ;
wire                                    almost_empty_2             ;
// wire                                    almost_empty_out1          ;
// wire                                    fifo_empty_out1            ;

//wire fc
wire                                    w_en_out                   ;
wire         [15 : 0]                   s_index_o_out              ;




test_ram u_test_ram
(
  .clka(clk),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [9 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(addr_test_ram),  // input wire [9 : 0] addrb
  .doutb(spike )  // output wire [7 : 0] doutb
);

uart_test u_uart_test(
    .clk           (clk           ),
    .rstn          (rstn          ),
    .addr_test_ram (addr_test_ram ),
    .spike         (spike         ),
    .test_data     (test_data     ),
    .uart_done     (uart_done     )
);

spike_code_converter u_spike_code_converter(
    .clk             (clk             ),
    .rstn            (rstn            ),
    .uart_done       (uart_done       ),
    .uart_data       (test_data       ),
    .s_index         (s_index         ),
    .w_en            (w_en_1          ),
    .full            (full_1          ),
    .almost_full     (almost_full_1   ),
    .timestep_switch (timestep_switch )
);

sync_fifo u_sync_fifo(
    .clk          (clk          ),
    .rstn         (rstn         ),
    .wr_en        (w_en_1       ),
    .wr_data      (s_index      ),
    .rd_en        (r_en_1       ),
    .rd_data      (s_index_1    ),
    .fifo_full    (full_1       ),
    .fifo_empty   (empty_1      ),
    .almost_full  (almost_full_1),
    .almost_empty (almost_empty_1)
);


TOP_conv u_TOP_conv(
    .clk          (clk          ),
    .rstn         (rstn         ),
    .s_index_i    (s_index_1    ),
    .empty        (empty_1      ),
    .almost_empty (almost_empty_1),
    .r_en         (r_en_1       ),
    .almost_full  (almost_full_2),
    .full         (full_2       ),
    .w_en         (w_en_2       ),
    .s_index_o    (s_index_o_2  )
);


// TOP_conv u_TOP_conv(
//     .clk         (clk         ),
//     .rstn        (rstn        ),
//     .almost_full (almost_full_i),
//     .full        (full_i      ),
//     .w_en        (w_en_i      ),
//     .s_index_o   (s_index_o_i )
// );

sync_fifo_layer1 #(
    .WIDTH(16),
    .DEPTH(1024),
    .ADDR_WIDTH(10)
) sync_fifo_layer1_inst (
    .clk(clk),
    .rstn(rstn),
    .wr_en(w_en_2),//write_in_en_1
    .wr_data(s_index_o_2),
    .rd_en(r_en_2),// ??
    .rd_data(fc_rd_data),

    .fifo_full(full_2),
    .fifo_empty(empty_2),
    .almost_full(almost_full_2),
    .almost_empty(almost_empty_2)
);


TOP_fc u_TOP_fc(
    .clk               (clk               ),
    .rstn              (rstn              ),
    .rd_en1            (r_en_2            ),
    .rd_data_out1      (fc_rd_data        ),
    .almost_empty_out1 (almost_empty_2    ),
    .fifo_empty_out1   (empty_2           ),
    .w_en              (w_en              ),
    .s_index_o         (s_index_o         )
);


// TOP_fc u_TOP_fc(
//     .clk         (clk         ),
//     .rstn        (rstn        ),
//     .s_index_i   (s_index_o_i  ),
//     .write_in_en (w_en_i      ),
//     .almost_full (almost_full ),
//     .full        (full        ),
//     .w_en        (w_en        ),
//     .s_index_o   (s_index_o   )
// );



endmodule //TOP