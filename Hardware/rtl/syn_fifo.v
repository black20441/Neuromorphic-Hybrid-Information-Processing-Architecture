module sync_fifo 
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


//reg
reg                                             buffer;

    //定义�?个计数器，用于判断空�?
    // reg [2 : 0] cnt; // $clog2(depth)=3 - 1 : 0

    //定义读写地址
    reg [10 : 0] wr_ptr;
    reg [10 : 0] rd_ptr;

    //定义�?个宽度为为width，深度为depth的fifo
    reg [WIDTH - 1 : 0] fifo [DEPTH - 1 : 0]; 

    //写地�?操作
    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            wr_ptr <= 0;
        else if(wr_en && !fifo_full)    //写使能，且fifo未写�?
            wr_ptr <= wr_ptr + 1;
    end

    //读地�?操作
    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            rd_ptr <= 0;
        else if(rd_en && !fifo_empty)   //读使能，且fifo不为�?
            rd_ptr <= rd_ptr + 1;
    end

    //写数�?
    integer i;

    always @ (posedge clk or negedge rstn) begin
        if(!rstn) begin //复位清空fifo
            for(i = 0; i < DEPTH; i = i + 1)
                fifo[i] <= 0;
        end
        else if(wr_en && !fifo_full)  //写使能时将数据写入fifo 修改
            fifo[wr_ptr] <= wr_data;
        // else    //否则保持
        //     fifo[wr_ptr] <= fifo[wr_ptr];
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            buffer <= 1'b0;
        end
        else if ((fifo_empty == 1'b1)&&(rd_data == 16'hFAF1)) begin
            buffer <= 1'b1;
        end
        else begin
            buffer <= 1'b0;
        end
    end



    //读数�?
    always @ (posedge clk or negedge rstn) begin
        if(!rstn)
            rd_data <= 0;
        else if ((fifo_empty == 1'b1)&&(rd_data == 16'hFAF1)&&(buffer == 1'b1)) begin
            rd_data <= 16'hF1FA;
        end
        else if (rd_en  && !fifo_empty) //修改
            rd_data <= fifo[rd_ptr];
        else if ((fifo[rd_ptr] == 16'hF1FA)||(fifo[rd_ptr] == 16'hFAF1))
            rd_data <= fifo[rd_ptr];    //从fifo中读取数�?
        else
        rd_data <= rd_data;
    end

    //辅助计数，用于判断空�?
    // always @ (posedge clk or negedge rstn) begin
    //     if(!rstn)
    //         cnt <= 0;
    //     else if (wr_en && !rd_en && !fifo_full) //有效的只写入
    //         cnt <= cnt + 1;
    //     else if (!wr_en && rd_en && !fifo_empty) //有效的只读取
    //         cnt <= cnt - 1;
    //     // else 
    //     //     cnt <= cnt;
    // end

    //空满判断
    // assign fifo_full = (cnt == depth)? 1'b1 : 1'b0;
    // assign fifo_empty = (cnt == 0) ? 1'b1 : 1'b0;

    assign fifo_full = ((wr_ptr[4] ^ rd_ptr[4]) && (wr_ptr[4 - 1 : 0] == rd_ptr[4 - 1 : 0])) ? 1'b1 : 1'b0;
    assign fifo_empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0;
    assign almost_full = ((wr_ptr[4] ^ rd_ptr[4]) && ((wr_ptr[4 - 1 : 0] + 1)== rd_ptr[4 - 1 : 0])) ? 1'b1 : 1'b0;
    assign almost_empty = (wr_ptr == (rd_ptr + 1)) ? 1'b1 : 1'b0;
endmodule