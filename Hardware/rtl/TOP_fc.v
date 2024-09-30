`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module TOP_fc(
    input                               clk                        ,
    input                               rstn                       ,

    // input      [`SYNAPSE_INDEX-1 : 0]   s_index_i                  ,
    // input                               write_in_en                ,               
    // input                               almost_full                ,
    // input                               full                       ,
//fifo
    output                              rd_en1                     ,
    input      [`SYNAPSE_INDEX-1 : 0]   rd_data_out1               ,
    input                               almost_empty_out1          ,
    input                               fifo_empty_out1            ,

    output                              w_en                       ,
    output     [`SYNAPSE_INDEX-1 : 0]   s_index_o   
  );


parameter WIDTH = 16;
parameter DEPTH = 1024;
parameter ADDR_WIDTH = 10;

// wire  rd_en1;
// wire  [WIDTH-1 : 0]  rd_data_out1;
// wire                 fifo_full_out1;
// wire                 fifo_empty_out1;
// wire                 almost_full_out1;
// wire                 almost_empty_out1;
wire                 ram_release1;


wire write_in_en_1;
wire [WIDTH-1 : 0]  s_index_i_1;


// assign write_in_en_1=(full==1'b1)?1'b0:write_in_en;
// assign s_index_i_1=s_index_i;
// 例化 sync_fifo
// sync_fifo_layer1 #(
//     .WIDTH(WIDTH),
//     .DEPTH(DEPTH),
//     .ADDR_WIDTH(ADDR_WIDTH)
// ) sync_fifo_layer1_inst (
//     .clk(clk),
//     .rstn(rstn),
//     .wr_en(write_in_en),//write_in_en_1
//     .wr_data(s_index_i_1),
//     .rd_en(rd_en1),// ??
//     .rd_data(rd_data_out1),

//     .fifo_full(fifo_full_out1),
//     .fifo_empty(fifo_empty_out1),
//     .almost_full(almost_full_out),
//     .almost_empty(almost_empty_out1)
// );


wire [`SYNAPSE_INDEX-1 : 0] s_index_ram_1;
wire [`CONV1_ADDR-1 : 0]    addr_most_1;
wire addr_valid_1;
wire [`MP_WIDE-1 : 0]        mp_out_1;
wire output_num_switch_pe_1;
wire [`CHANNEL_WIDE-1:0] channel_num_1;
wire mp_ready_1;
wire [`SYNAPSE_INDEX-1 : 0]   neuron_1;
wire                    neuron_valid_1;



fc_2ram_controller_layer1 fc_2ram_controller_layer1_inst(
    .clk (clk),
    .rstn (rstn),

    .s_index_i(rd_data_out1),
    .empty (fifo_empty_out1),
    .almost_empty   (almost_empty_out1),
    .r_en (rd_en1),

    .s_index_ram(s_index_ram_1),
    .addr_most (addr_most_1),
    .addr_valid(addr_valid_1),
    
    .ram_release (ram_release1)
    );
    

  pe_fc_layer1 #(
    .WEIGHT_ADDR_BIAS(512),
    .INPUT_CHANNEL_NUM(128),
    .OUTPUT_CHANNEL_NUM(256)
  ) u_pe_fc_layer1_inst(
    .clk                (clk                ),
    .rstn               (rstn               ),
    .s_index_ram            (s_index_ram_1),//输入通道
    .addr_most          (addr_most_1),//几个输入通道
    .s_index_valid      (addr_valid_1),//读mp
    . mp_out             (mp_out_1             ),//输出mp
    .output_num_switch_pe   (output_num_switch_pe_1),
    .channel_num        (channel_num_1        ),//对应输出通道
    .mp_ready           (mp_ready_1           ),//输出mp标志
    .ram_release        (ram_release1        )
);

MP_refresh_layer1 #(
      .THRESHOLD(305),
      .MP_RESET(`MP_WIDE'd0),
      .OUTPUT_CHANNEL_NUM(256) 
) u_MP_refresh_layer1_inst(
    .clk               (clk               ),
    .rstn              (rstn              ),
    .mp_ready          (mp_ready_1          ),
    .mp_out            (mp_out_1            ),
    .channel_num       (channel_num_1       ),
    .output_num_switch_pe (output_num_switch_pe_1),
    .neuron            (neuron_1            ),
    .neuron_valid      (neuron_valid_1     )//标志�???????次输出成功，�??�??channel
);

//layer2-------------------
wire  rd_en2;
wire   [WIDTH-1 : 0] rd_data_out2;
wire                 fifo_full_out2;
wire                 fifo_empty_out2;
wire                 almost_full_out2;
wire                 almost_empty_out2;
wire                 ram_release2;

wire                 write_in_en_2;
wire  [WIDTH-1 : 0]  s_index_i_2;

// assign write_in_en_2=(full==1'b1)?1'b0:neuron_valid_1;
assign write_in_en_2=neuron_valid_1;
assign s_index_i_2=neuron_1;
// 例化 sync_fifo
sync_fifo_layer2 #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) sync_fifo_layer2_inst (
    .clk(clk),
    .rstn(rstn),
    .wr_en(write_in_en_2),
    .wr_data(s_index_i_2),
    .rd_en(rd_en2),// ??
    .rd_data(rd_data_out2),

    .fifo_full(fifo_full_out2),
    .fifo_empty(fifo_empty_out2),
    .almost_full(almost_full_out2),
    .almost_empty(almost_empty_out2)
);


wire [`SYNAPSE_INDEX-1 : 0] s_index_ram_2;
wire [`CONV1_ADDR-1 : 0]    addr_most_2;
wire                    addr_valid_2;
wire [`MP_WIDE-1 : 0]        mp_out_2;
wire output_num_switch_pe_2;
wire [9-1:0] channel_num_2;
wire                        mp_ready_2;
wire [`SYNAPSE_INDEX-1 : 0]   neuron_2;
wire                    neuron_valid_2;



fc_2ram_controller_layer2 fc_2ram_controller_layer2_inst(
    .clk (clk),
    .rstn (rstn),

    .s_index_i(rd_data_out2),
    .empty (fifo_empty_out2),
    .almost_empty   (almost_empty_out2),
    .r_en (rd_en2),

    .s_index_ram(s_index_ram_2),
    .addr_most (addr_most_2),
    .addr_valid(addr_valid_2),
    
    .ram_release (ram_release2)
    );
    

  pe_fc_layer2 #( 
    .WEIGHT_ADDR_BIAS(512),
    .INPUT_CHANNEL_NUM(256),
    .OUTPUT_CHANNEL_NUM(10)
  ) u_pe_fc_layer2_inst(
    .clk                (clk                ),
    .rstn               (rstn               ),
    .s_index_ram            (s_index_ram_2),//输入通道
    .addr_most          (addr_most_2),//几个输入通道
    .s_index_valid      (addr_valid_2),//读mp
    . mp_out             (mp_out_2             ),//输出mp
    .output_num_switch_pe   (output_num_switch_pe_2),
    .channel_num        (channel_num_2        ),//对应输出通道
    .mp_ready           (mp_ready_2           ),//输出mp标志
    .ram_release        (ram_release2        )
);

MP_refresh_layer2 #(
      .THRESHOLD(407),
      .MP_RESET(`MP_WIDE'd0),
      .OUTPUT_CHANNEL_NUM(10) 
) u_MP_refresh_layer2(
    .clk               (clk               ),
    .rstn              (rstn              ),
    .mp_ready          (mp_ready_2          ),
    .mp_out            (mp_out_2            ),
    .channel_num       (channel_num_2       ),
    .output_num_switch_pe (output_num_switch_pe_2),
    .neuron            (s_index_o            ),
    .neuron_valid      (w_en                 )//标志�???????次输出成功，�??�??channel
);


    // assign          w_en=neuron_valid_2;              
    // assign          s_index_o=neuron_2;  





endmodule