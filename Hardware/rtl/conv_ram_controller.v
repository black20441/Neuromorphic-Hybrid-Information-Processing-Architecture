`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module conv_ram_controller (
//system   signal
    input                               clk                        ,
    input                               rstn                       ,

//fifo
    input        [15 : 0]               s_index_i                  ,
    input                               empty                      ,
    input                               almost_empty               ,
    output       reg                    r_en                       ,

//conv1
    input        [`CONV1_ADDR-1 : 0]    addr_r_spike               ,
    output   reg [`SYNAPSE_INDEX-1 : 0] s_index_ram                ,
    output   reg [`CONV1_ADDR-1 : 0]    addr_most                  ,
    output   reg                        addr_valid                 ,
    input                               ram_release                
);

//localpara
localparam IDLE = 2'd0;
localparam RAM1 = 2'd1;                                              //write RAM1
localparam RAM2 = 2'd2;                                              //write RAM2

localparam IDLE_R = 2'd0;
localparam RAM1_R = 2'd1;
localparam RAM2_R = 2'd2;

//reg
reg                [1 : 0]               current_state             ;
reg                [1 : 0]               next_state                ;
reg                [1 : 0]               current_state_r           ;
reg                [1 : 0]               next_state_r              ;
reg                [`CONV1_ADDR-1 : 0]   ram1_addr_r               ;
reg                [`CONV1_ADDR-1 : 0]   ram1_addr_w               ;
reg                [`CONV1_ADDR-1 : 0]   ram2_addr_r               ;
reg                [`CONV1_ADDR-1 : 0]   ram2_addr_w               ;
reg                [`SYNAPSE_INDEX-1 : 0]ram1_data_in              ;
reg                [`SYNAPSE_INDEX-1 : 0]ram2_data_in              ;

reg                                      ram1_w_en                 ;
reg                                      ram2_w_en                 ;
reg                                      ram1_valid                ;
reg                                      ram2_valid                ;

//wire
wire               [`SYNAPSE_INDEX-1 : 0]ram1_data_out             ;
wire               [`SYNAPSE_INDEX-1 : 0]ram2_data_out             ;

//RAM1 RAM2 addr_valid
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_valid <= 1'b0;
    end
    else if ((ram1_valid == 1'b1)||(ram2_valid == 1'b1)) begin
        addr_valid <= 1'b1;
    end
    else
        addr_valid <= 1'b0;
end

//state machine1_r: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state_r <= IDLE_R;
    end
    else
        current_state_r <= next_state_r;
end

//state machine1_r: process 2
always @(*) begin
    case (current_state_r)
        IDLE_R: 
        begin
            if (ram1_valid == 1'b1) begin
                next_state_r = RAM1;
            end
            else
                next_state_r = IDLE_R;
        end
        RAM1_R:
        begin
            if ((ram2_valid == 1'b1)&&(ram_release == 1'b1)) begin
                next_state_r = RAM2_R;
            end
            else
                next_state_r = RAM1_R;
        end
        RAM2_R:
        begin
            if ((ram1_valid == 1'b1)&&(ram_release == 1'b1)) begin
                next_state_r = RAM1_R;
            end
            else
                next_state_r = RAM2_R;
        end
        default: ;
    endcase
end

//state machine1_r: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_most <= {`CONV1_ADDR{1'b0}};
        s_index_ram <= {`SYNAPSE_INDEX{1'b0}};
        ram1_addr_r <= {`CONV1_ADDR{1'b0}};
        ram2_addr_r <= {`CONV1_ADDR{1'b0}};
    end
    else begin
        case (next_state_r)
            IDLE_R:
            begin
                addr_most <= {`CONV1_ADDR{1'b0}};
                s_index_ram <= {`SYNAPSE_INDEX{1'b0}};
                ram1_addr_r <= {`CONV1_ADDR{1'b0}};
                ram2_addr_r <= {`CONV1_ADDR{1'b0}};
            end 
            RAM1_R:
            begin
                addr_most <= ram1_addr_w;
                s_index_ram <= ram1_data_out;
                ram1_addr_r <= addr_r_spike;
                ram2_addr_r <= {`CONV1_ADDR{1'b0}};
            end
            RAM2_R:
            begin
                addr_most <= ram2_addr_w;
                s_index_ram <= ram2_data_out;
                ram2_addr_r <= addr_r_spike;
                ram1_addr_r <= {`CONV1_ADDR{1'b0}};
            end
            default: ;
        endcase
    end
        
end

//state machine2_w: process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state <= IDLE;
    end
    else
        current_state <= next_state;
end

//state machine2: process 2
always @(*) begin
    case (current_state)
        IDLE:
        begin
            if (empty != 1'b1) begin
                next_state = RAM1;
            end
            else
                next_state = IDLE;
        end
        RAM1:
        begin
            if ((s_index_i == 16'hFAF1)&&(ram1_valid == 1'b1)) begin
                next_state = RAM2;
            end
            else
                next_state = RAM1;
        end
        RAM2:
        begin
            if ((s_index_i == 16'hFAF1)&&(ram2_valid == 1'b1)) begin
                next_state = RAM1;
            end
            else
                next_state = RAM2;
        end
        default: ;
    endcase
end

//state machine2: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        r_en <= 1'b0;
        ram1_w_en <= 1'b0;
        ram2_w_en <= 1'b0;
        ram1_valid <= 1'b0;
        ram2_valid <= 1'b0;
        ram1_addr_w <= {`CONV1_ADDR{1'b0}};
        ram2_addr_w <= {`CONV1_ADDR{1'b0}};
        ram1_data_in <= {`SYNAPSE_INDEX{1'b0}};
        ram2_data_in <= {`SYNAPSE_INDEX{1'b0}};
    end
    else begin
        case (next_state)
            IDLE:
            begin
                r_en <= 1'b0;
                ram1_w_en <= 1'b0;
                ram2_w_en <= 1'b0;
                ram1_valid <= 1'b0;
                ram2_valid <= 1'b0;
                ram1_addr_w <= {`CONV1_ADDR{1'b0}};
                ram2_addr_w <= {`CONV1_ADDR{1'b0}};
                ram1_data_in <= {`SYNAPSE_INDEX{1'b0}};
                ram2_data_in <= {`SYNAPSE_INDEX{1'b0}};
            end
            RAM1:
            begin
                if (r_en == 1'b1) begin
                    r_en <= 1'b0;
                end
                else if (((empty != 1'b1)&&(s_index_i == 16'hF1FA)&&({ram1_valid,ram2_valid} != 2'b11))||((empty != 1'b1)&&(s_index_i == 16'hF1FA)&&({ram1_valid,ram2_valid} == 2'b11)&&(ram_release == 1'b1))) begin
                    r_en <= 1'b1;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= 1'b0;
                    ram1_addr_w <= {`CONV1_ADDR{1'b0}};
                    ram1_data_in <= {`SYNAPSE_INDEX{1'b0}};
                end
                else if ((s_index_i != 16'hF1FA)&&(s_index_i != 16'hFAF1)&&(empty != 1'b1)) begin
                    r_en <= 1'b1;
                    ram1_w_en <= 1'b1;
                    ram1_valid <= 1'b0;
                    ram1_addr_w <= ram1_addr_w + 1;
                    ram1_data_in <= s_index_i;
                end
                else if (s_index_i == 16'hFAF1) begin
                    r_en <= 1'b0;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= 1'b1;
                    ram1_addr_w <= ram1_addr_w;
                    ram1_data_in <= ram1_data_in;
                end
                else begin
                    r_en <= 1'b0;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= ram1_valid;
                    ram1_addr_w <= ram1_addr_w;
                    ram1_data_in <= s_index_i;
                end
            end
            RAM2:
            begin
                if (r_en == 1'b1) begin
                    r_en <= 1'b0;
                end
                else if (((empty != 1'b1)&&(s_index_i == 16'hF1FA)&&({ram1_valid,ram2_valid} != 2'b11))||((empty != 1'b1)&&(s_index_i == 16'hF1FA)&&({ram1_valid,ram2_valid} == 2'b11)&&(ram_release == 1'b1))) begin
                    r_en <= 1'b1;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= 1'b0;
                    ram2_addr_w <= {`CONV1_ADDR{1'b0}};
                    ram2_data_in <= {`SYNAPSE_INDEX{1'b0}};
                end
                else if ((s_index_i != 16'hF1FA)&&(s_index_i != 16'hFAF1)&&(empty != 1'b1)) begin
                    r_en <= 1'b1;
                    ram2_w_en <= 1'b1;
                    ram2_valid <= 1'b0;
                    ram2_addr_w <= ram2_addr_w + 1;
                    ram2_data_in <= ram2_data_in;
                end
                else if ((s_index_i == 16'hFAF1)&&(current_state != RAM1)) begin
                    r_en <= 1'b0;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= 1'b1;
                    ram2_addr_w <= ram2_addr_w;
                    ram2_data_in <= ram2_data_in;
                end
                else begin
                    r_en <= 1'b0;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= ram2_valid;
                    ram2_addr_w <= ram2_addr_w;
                    ram2_data_in <= s_index_i;
                end
            end
            default: ;
        endcase
    end
end


bram
#(
  .ADDR (9),
  .WIDE (16),
  .DEPTH (512)
) 
conv1_ram1 (
  .clka(clk),    
  .wea(ram1_w_en),      
  .addra(ram1_addr_w),  
  .dina(ram1_data_in),    
  .clkb(clk),    
  .addrb(ram1_addr_r),  
  .doutb(ram1_data_out)  
);

bram
#(
  .ADDR (9),
  .WIDE (16),
  .DEPTH (512)
) 
conv1_ram2 (
  .clka(clk),    
  .wea(ram1_w_en),      
  .addra(ram1_addr_w),  
  .dina(ram1_data_in),    
  .clkb(clk),    
  .addrb(ram1_addr_r),  
  .doutb(ram1_data_out)  
);


endmodule //conv_ram_controller