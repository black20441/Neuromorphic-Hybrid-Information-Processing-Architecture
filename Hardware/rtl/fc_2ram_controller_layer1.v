`include "../rtl/define.vh"

module fc_2ram_controller_layer1 (
//system   signal
    input                               clk                        ,
    input                               rstn                       ,

//fifo
    input        [15 : 0]               s_index_i                  ,
    input                               empty                      ,
    input                               almost_empty               ,
    output                           r_en                       ,

//fc
//    input        [`CONV1_ADDR-1 : 0]    addr_r_spike               ,//9
    output    [`SYNAPSE_INDEX-1 : 0] s_index_ram                ,//16
    output    [`CONV1_ADDR-1 : 0]    addr_most                  ,
    output                           addr_valid                 ,
    
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
reg                [`CONV1_ADDR-1 : 0]   ram1_addr_w_reg           ;
reg                [`CONV1_ADDR-1 : 0]   ram2_addr_r               ;
reg                [`CONV1_ADDR-1 : 0]   ram2_addr_w               ;
reg                [`CONV1_ADDR-1 : 0]   ram2_addr_w_reg           ;
reg                [`SYNAPSE_INDEX-1 : 0]ram1_data_in              ;
// reg                [`SYNAPSE_INDEX-1 : 0]ram1_data_out             ;
reg                [`SYNAPSE_INDEX-1 : 0]ram2_data_in              ;
// reg                [`SYNAPSE_INDEX-1 : 0]ram2_data_out             ;
reg                                      ram1_w_en                 ;
reg                                      ram2_w_en                 ;
reg                                      ram1_valid                ;
reg                                      ram2_valid                ;
reg                                      addr_valid_reg         ;
reg [`CONV1_ADDR-1 : 0]    addr_most_reg;
reg                     r_en_reg;
reg input_num_switch_pe;
reg ram_release_reg;
reg ram_release_reg2;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ram_release_reg <= 1'b0;
        ram_release_reg2<=1'b0;
    end
    else
    begin
    ram_release_reg<=ram_release;
    ram_release_reg2<=ram_release_reg;
    end
end

assign addr_valid=addr_valid_reg;
assign addr_most=addr_most_reg;
assign r_en=r_en_reg;
wire [`SYNAPSE_INDEX-1 : 0]ram1_data_out_wire;
wire [`SYNAPSE_INDEX-1 : 0]ram2_data_out_wire;
//RAM1 RAM2 addr_valid
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_valid_reg <= 1'b0;
    end
    else if ((ram1_valid == 1'b1)||(ram2_valid == 1'b1)) begin
        addr_valid_reg <= 1'b1;
    end
    else
        addr_valid_reg <= 1'b0;
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
                next_state_r = RAM1_R;//锛燂紵锛�?????? �??????�??????
               
            end
            else
                next_state_r = IDLE_R;
        end
        RAM1_R:
        begin
            if ((ram2_valid == 1'b1)&&(ram_release == 1'b1)) begin
                next_state_r = RAM2_R;
//                ram1_addr_w_reg<={`CONV1_ADDR{1'b0}};
            end
            else
                next_state_r = RAM1_R;
        end
        RAM2_R:
        begin
            if ((ram1_valid == 1'b1)&&(ram_release == 1'b1)) begin
                next_state_r = RAM1_R;
//                ram2_addr_w_reg<={`CONV1_ADDR{1'b0}};
            end
            else
                next_state_r = RAM2_R;
        end
        default: next_state_r=IDLE_R;
    endcase
end

//state machine1_r: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_most_reg <= {`CONV1_ADDR{1'b0}};
        ram1_addr_r <= {`CONV1_ADDR{1'b0}};
        ram2_addr_r <= {`CONV1_ADDR{1'b0}};
        input_num_switch_pe<=1'b0;
    end
    else begin
        case (next_state_r)
            IDLE_R:
            begin
                addr_most_reg <= {`CONV1_ADDR{1'b0}};
                ram1_addr_r <= {`CONV1_ADDR{1'b0}};
                ram2_addr_r <= {`CONV1_ADDR{1'b0}};
            end 
            RAM1_R:
            begin
                addr_most_reg <= ram1_addr_w_reg;
                if(ram1_addr_r<ram1_addr_w_reg)
                begin
                    ram1_addr_r <= ram1_addr_r+1'b1;
                    input_num_switch_pe<=1'b0;
                end
                else
                begin
                    ram1_addr_r<={`CONV1_ADDR{1'b0}};
                    input_num_switch_pe<=1'b1;
                end
                ram2_addr_r <= {`CONV1_ADDR{1'b0}};
            end
            RAM2_R:
            begin
                addr_most_reg <= ram2_addr_w_reg;
                if(ram2_addr_r<ram2_addr_w_reg)
                begin
                    ram2_addr_r <=ram2_addr_r+1'b1;
                    input_num_switch_pe<=1'b0;
                end
                else
                begin
                    ram2_addr_r<={`CONV1_ADDR{1'b0}};
                    input_num_switch_pe<=1'b1;
                end

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
            if (empty != 1'b1) begin//FIFO绌虹殑鏍�?淇�??�彿锛屼负�?��?�數骞虫椂琛ㄧずFIFO宸茬┖锛屼笉鑳藉�?杩涜璇绘搷浣溿��???????
                next_state = RAM1;
            end
            else
                next_state = IDLE;
        end
        RAM1:
        begin
      
        
          if ((s_index_i == 16'hFaF1)&&(ram1_valid == 1'b1)) begin//h Faf1 缁撴�?????? f1fa�?�濮�?
               next_state = RAM2;
            end
            
            else
                next_state = RAM1;
        end
        RAM2:
        begin
        if ((s_index_i == 16'hFaF1)&&(ram2_valid == 1'b1)) begin
                next_state = RAM1;
            end
            else
                next_state = RAM2;
        end
        default: next_state=IDLE;
    endcase
end

//state machine2: process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        r_en_reg <= 1'b0;
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
                r_en_reg <= 1'b0;
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
                if (((s_index_i == 16'hF1Fa)&&({ram1_valid,ram2_valid} != 2'b11))||//h Faf1 缁撴�?????? f1fa�?�濮�?
                (s_index_i == 16'hF1FA)&&
                ({ram1_valid,ram2_valid} == 2'b11)&&(ram_release == 1'b1)) begin  //锛燂紵锛燂紵
                    r_en_reg <= 1'b1;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= 1'b0;
                    ram1_addr_w <= {`CONV1_ADDR{1'b0}};
                    ram1_addr_w_reg<={`CONV1_ADDR{1'b0}};
                    ram1_data_in <= {`SYNAPSE_INDEX{1'b0}};
                end
                else if ((s_index_i != 16'hF1FA)&&(s_index_i != 16'hFAF1)&&(empty != 1'b1)) begin
                    r_en_reg <= 1'b1;
                    ram1_w_en <= 1'b1;
                    ram1_valid <= 1'b0;
                    ram1_addr_w <= ram1_addr_w + 1;
                    ram1_addr_w_reg<=ram1_addr_w;
                    ram1_data_in <= s_index_i;
                end
                else if ((s_index_i == 16'hFAF1)||(s_index_i==16'hxxxx))begin
                    r_en_reg <= 1'b0;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= 1'b1;
                    ram1_addr_w <= ram1_addr_w;
                    ram1_data_in <= ram1_data_in;//�??????�??????
                end
                else begin
                    r_en_reg <= 1'b0;
                    ram1_w_en <= 1'b0;
                    ram1_valid <= ram1_valid;
                    ram1_addr_w <= ram1_addr_w;
                    ram1_data_in <= s_index_i;
                end
            end
            RAM2:
            begin
                if (((s_index_i == 16'hF1Fa)&&({ram1_valid,ram2_valid} != 2'b11))||(s_index_i == 16'hF1FA)&&({ram1_valid,ram2_valid} == 2'b11)&&(ram_release== 1'b1)) begin
                    r_en_reg <= 1'b1;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= 1'b0;
                    ram2_addr_w <= {`CONV1_ADDR{1'b0}};
                    ram2_addr_w_reg <= {`CONV1_ADDR{1'b0}};
                    ram2_data_in <= {`SYNAPSE_INDEX{1'b0}};
                end
                else if ((s_index_i != 16'hF1FA)&&(s_index_i != 16'hFAF1)&&(empty != 1'b1)) begin
                    r_en_reg <= 1'b1;
                    ram2_w_en <= 1'b1;
                    ram2_valid <= 1'b0;
                    ram2_addr_w <= ram2_addr_w + 1;
                    ram2_addr_w_reg<=ram2_addr_w;
                    ram2_data_in <= s_index_i;
                end
                else if ((s_index_i == 16'hFAF1)||(s_index_i==16'hxxxx)) begin
                    r_en_reg <= 1'b0;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= 1'b1;
                    ram2_addr_w <= ram2_addr_w;
                    ram2_data_in <= ram2_data_in;
                end
                else begin
                    r_en_reg <= 1'b0;
                    ram2_w_en <= 1'b0;
                    ram2_valid <= ram2_valid;
                    ram2_addr_w <= ram2_addr_w;
                    ram2_data_in <= ram2_data_in;
                end
            end
            default: ;
        endcase
    end
end

// blk_mem_gen_0 ram1_layer1 (
//   .clka(clk),    // input wire clka
//   .wea(ram1_w_en),      // input wire [1 : 0] wea
//   .addra(ram1_addr_w_reg),  // input wire [6 : 0] addra
//   .dina(ram1_data_in),    // input wire [15 : 0] dina
//   .clkb(clk),    // input wire clkb
//   .addrb(ram1_addr_r),  // input wire [6 : 0] addrb
//   .doutb(ram1_data_out_wire)  // output wire [15 : 0] doutb
// );

bram
#(
  .ADDR (9),
  .WIDE (16),
  .DEPTH (512)
) 
ram1_layer1 (
  .clka(clk),    // input wire clka
  .wea(ram1_w_en),      // input wire [1 : 0] wea
  .addra(ram1_addr_w_reg),  // input wire [6 : 0] addra
  .dina(ram1_data_in),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(ram1_addr_r),  // input wire [6 : 0] addrb
  .doutb(ram1_data_out_wire)  // output wire [15 : 0] doutb
);

bram
#(
  .ADDR (9),
  .WIDE (16),
  .DEPTH (512)
) 
ram1_layer2 (
  .clka(clk),    // input wire clka
  .wea(ram2_w_en),      // input wire [1 : 0] wea
  .addra(ram2_addr_w_reg),  // input wire [6 : 0] addra
  .dina(ram2_data_in),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .addrb(ram2_addr_r),  // input wire [6 : 0] addrb
  .doutb(ram2_data_out_wire)  // output wire [15 : 0] doutb
);
// blk_mem_gen_0 ram2_layer1 (
//   .clka(clk),    // input wire clka
//   .wea(ram2_w_en),      // input wire [1 : 0] wea
//   .addra(ram2_addr_w_reg),  // input wire [6 : 0] addra
//   .dina(ram2_data_in),    // input wire [15 : 0] dina
//   .clkb(clk),    // input wire clkb
//   .addrb(ram2_addr_r),  // input wire [6 : 0] addrb
//   .doutb(ram2_data_out_wire)  // output wire [15 : 0] doutb
// );

assign s_index_ram=(current_state_r==IDLE)?{`SYNAPSE_INDEX{1'b0}}:
                        (current_state_r==RAM1_R)?ram1_data_out_wire:
                            (current_state_r==RAM2_R)?ram2_data_out_wire:s_index_ram;



endmodule //conv_ram_controller