module testbench_TOP();

//`define DUMP;
string dump_file;
initial begin
    `ifdef DUMP
        if($value$plusargs("FSDB=%s",dump_file))
            $display("dump_file = %s",dump_file);
        $fsdbDumpfile(dump_file);        
        $fsdbDumpvars(0, testbench_TOP);
        $fsdbDumpMDA();
    `endif
end

// parameter vcd_start = 23407250;
// parameter vcd_hold = 100;

// initial begin
//     `ifdef VCD_ON
//         #vcd_start;
//         $dumpfile("./vcd_TOP.vcd");
//         $dumpvars(0,testbench_TOP.dut);
//         #vcd_hold;
//         # 100;
//         $fclose("./vcd_TOP.vcd");
//     `endif
// end


parameter t = 5;
parameter rst_time = 5;
parameter rst_time_delete = 10;
parameter finish_time = 1915320;//23407251

reg clk;
reg rstn;
wire almost_full;
wire full;
reg w_en;
reg [`SYNAPSE_INDEX-1 : 0]s_index_o;
TOP_snn dut(
	.clk(clk),
	.rstn(rstn),
	.almost_full(almost_full),
	.full(full),
	.w_en(w_en),
	.s_index_o(s_index_o)
);

initial begin   //clock
    clk = 1'b0;
    forever begin
        #(t/2) clk = ~clk;
    end
end

initial begin   //reset
    rstn = 1'b1;
    #rst_time rstn = 1'b0;
    #rst_time_delete rstn = 1'b1;
end

// initial begin
//     readmemb("rtl/sn11.txt",test_ram);
//     readmemh("rtl/conv13.txt",weight_ram);
// end

initial begin       //finish
    # finish_time;
    $finish;
end

endmodule

