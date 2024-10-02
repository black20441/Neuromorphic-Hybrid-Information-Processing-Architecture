module single_bram1#(
  parameter  ADDR = 16,
  parameter  WIDE = 4,
  parameter  DEPTH = 32786
)
(
input                               clkb,
input    [ADDR-1 : 0]    addrb,
output reg [WIDE-1 : 0]    doutb
);


reg [WIDE-1:0] mem_bram [DEPTH-1:0];

initial begin
    $readmemb("testbench/linear1.txt",mem_bram);
end

always @(posedge clkb) begin
    doutb <= mem_bram[addrb];
end


endmodule