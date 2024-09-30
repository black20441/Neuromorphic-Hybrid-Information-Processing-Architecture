
module weight_ram#(
  parameter ADDR = 18,
  parameter WIDE = 4,
  parameter DEPTH = 131072
)
(
input                               clka,
input                               wea,
input    [ADDR-1 : 0]               addra,
input    [WIDE-1 : 0]               dina,
input                               clkb,
input    [ADDR-1 : 0]               addrb,
output reg [WIDE-1 : 0]             doutb
);

// blk_mem_gen_0 weight_ram (
//   .clka(clk),    // input wire clka
//   .wea(wea),      // input wire [0 : 0] wea
//   .addra(addra),  // input wire [16 : 0] addra
//   .dina(dina),    // input wire [3 : 0] dina
//   .clkb(clk),    // input wire clkb
//   .addrb(addr_r_weight),  // input wire [16 : 0] addrb
//   .doutb(weight_index)  // output wire [3 : 0] doutb
// );

reg [WIDE-1:0] mem_bram [DEPTH-1:0];

initial begin
    $readmemh("testbench/conv13.txt",mem_bram);
end

always @(posedge clka) begin
    if (wea)
        mem_bram[addra] <= dina;
    else
        mem_bram[addra] <= mem_bram[addra];
end


always @(posedge clkb) begin
    doutb <= mem_bram[addrb];
end


endmodule