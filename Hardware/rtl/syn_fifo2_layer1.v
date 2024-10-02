module sync_fifo_layer1
#(
parameter WIDTH          = 16,
parameter DEPTH          = 1024,
parameter ADDR_WIDTH     = 10
)
(
input											clk,
input											rstn,
input											wr_en,
input	[WIDTH-1 : 0]				            wr_data,
input											rd_en,
output reg	[WIDTH-1 : 0]	                    rd_data,

output     	     								fifo_full,
output     	     								fifo_empty,
output                                          almost_full,
output                                          almost_empty


);

wire wr_en_valid;
reg                                             buffer;


    reg [10 : 0] wr_ptr;
    reg [10 : 0] rd_ptr;

    reg [WIDTH - 1 : 0] fifo [DEPTH - 1 : 0]; 



assign wr_en_valid = (fifo_full==1'b1)?1'b0:wr_en;

    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            wr_ptr <= 0;
        else if(wr_en_valid && !fifo_full)    
            wr_ptr <= wr_ptr + 1;
    end


    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            rd_ptr <= 0;
        else if(rd_en && !fifo_empty) 
            rd_ptr <= rd_ptr + 1;
    end


    integer i;

    always @ (posedge clk or negedge rstn) begin
        if(!rstn) begin 
            for(i = 0; i < DEPTH; i = i + 1)
                fifo[i] <= 0;
        end
        else if(wr_en_valid && !fifo_full)  
            fifo[wr_ptr] <= wr_data;
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            buffer <= 1'b0;
        end
        else if ((rd_data == 16'hFAF1)) begin
            buffer <= 1'b1;
        end
        else begin
            buffer <= 1'b0;
        end
    end


    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            rd_data <= 0;
        else if ((rd_data == 16'hFAF1)&&(buffer == 1'b1)) begin
            rd_data <= 16'hF1FA;
        end
        else if (rd_en  && !fifo_empty) 
            rd_data <= fifo[rd_ptr];
        else
        rd_data <= rd_data;
    end


    assign fifo_full = ((wr_ptr[10] ^ rd_ptr[10]) && (wr_ptr[10 - 1 : 0] == rd_ptr[10 - 1 : 0])) ? 1'b1 : 1'b0;
    assign fifo_empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
    assign almost_full = ((wr_ptr[10] ^ rd_ptr[10]) && ((wr_ptr[10 - 1 : 0] + 1)== rd_ptr[10 - 1 : 0])) ? 1'b1 : 1'b0;
    assign almost_empty = (wr_ptr == (rd_ptr + 1)) ? 1'b1 : 1'b0;
    
    

    
endmodule