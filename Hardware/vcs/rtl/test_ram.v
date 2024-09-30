module test_ram 
(
input                               clka,
input                               wea,
input    [10-1 : 0]    addra,
input    [8-1 : 0]    dina,
input                               clkb,
input    [10-1 : 0]    addrb,
output reg [8-1 : 0]    doutb
);

reg [8-1:0] mem_bram [1024-1:0];

initial begin
    $readmemb("testbench/sn11.txt",mem_bram);
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


endmodule //test_ram