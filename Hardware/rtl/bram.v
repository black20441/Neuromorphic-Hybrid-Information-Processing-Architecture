
module bram
#(
  parameter  ADDR = 1,
  parameter  WIDE = 1,
  parameter  DEPTH = 2
)
(
input                               clka,
input                               wea,
input    [ADDR-1 : 0]    addra,
input    [WIDE-1 : 0]    dina,
input                               clkb,
input    [ADDR-1 : 0]    addrb,
output reg [WIDE-1 : 0]    doutb
);


reg [WIDE-1:0] mem_bram [DEPTH-1:0];
integer i;

initial begin
    for (i = 0;i < DEPTH ;i = i + 1) begin
        mem_bram [i] <= 0;
    end
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