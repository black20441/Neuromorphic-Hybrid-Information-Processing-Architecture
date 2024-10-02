`include "../rtl/define.vh"
module pe_fc_layer1 
#(parameter WEIGHT_ADDR_BIAS = 512,
  parameter INPUT_CHANNEL_NUM      = 128,
    parameter OUTPUT_CHANNEL_NUM      = 256)
(
//system signal
    input                               clk                        ,
    input                               rstn                      ,
    
//fc_2ram_controller
    input                 [`SYNAPSE_INDEX-1 : 0] s_index_ram               ,//16
    input                [`CONV1_ADDR-1 : 0]    addr_most                  ,
    input                                    s_index_valid                  ,//addr_valid
    output                                   weight_ready,

//MP_refresh
    output       [`MP_WIDE-1 : 0]        mp_out                     ,
    output                              output_num_switch_pe,
    output       [`CHANNEL_WIDE-1:0] channel_num,        
    output                           mp_ready,

    output                           ram_release                
);

//localparam
localparam IDLE = 2'd0;
localparam WEIGHT_ADDR = 2'd1;//getting the weight addr
localparam WEIGHT = 2'd2;
localparam MP = 2'd3;    //giving the index to MP 

//reg
reg             [1 : 0]                   current_state;
reg             [1 : 0]                      next_state;

reg             [3 : 0]                    weight_index;

reg signed            [`WEIGHT_WIDE-1 : 0]            weight_o;

reg signed             [`WEIGHT_WIDE-1 : 0]            weight1;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight2;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight3;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight4;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight5;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight6;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight7;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight8;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight9;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight10;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight11;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight12;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight13;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight14;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight15;
reg signed             [`WEIGHT_WIDE-1 : 0]            weight16;

reg         [`CONV1_ADDR-1 : 0]    addr_most_cnt;
reg                 ram_release_reg;

reg [`WEIGHT_BRAM-1 : 0]       weight_bram_addr_reg;

//reg mp_ready_reg;
reg weight_ready_reg;
reg weight_ready_reg2;
reg weight_ready_reg3;
reg weight_ready_reg4;
reg  [`CHANNEL_WIDE-1:0] channel_num_reg;
reg  [`CHANNEL_WIDE-1:0] channel_num_reg2;
reg  [`CHANNEL_WIDE-1:0] channel_num_reg3;
reg  [`CHANNEL_WIDE-1:0] channel_num_reg4;



//weight_bram_port_r
 wire   [3 : 0]                 weight_index_i             ;


assign mp_ready=weight_ready;
assign channel_num=channel_num_reg4;//mp_out
assign ram_release=ram_release_reg;

assign weight_ready=weight_ready_reg4? 1'b1:1'b0;
assign mp_out=weight_ready?weight_o:{`MP_WIDE{1'b0}};
assign output_num_switch_pe=(channel_num_reg4==channel_num_reg3)?1'b0:1'b1;

//weight register
always @(posedge clk or negedge rstn)  begin
    if (!rstn) begin
    weight1<=`WEIGHT_WIDE'd0;
    weight2<=`WEIGHT_WIDE'd0;
    weight3<=`WEIGHT_WIDE'd0;
    weight4<=`WEIGHT_WIDE'd0;
    weight5<=`WEIGHT_WIDE'd0;
    weight6<=`WEIGHT_WIDE'd0;
    weight7<=`WEIGHT_WIDE'd0;
    weight8<=`WEIGHT_WIDE'd0;
    weight9<=`WEIGHT_WIDE'd0;
    weight10<=`WEIGHT_WIDE'd0;
    weight11<=`WEIGHT_WIDE'd0;
    weight12<=`WEIGHT_WIDE'd0;
    weight13<=`WEIGHT_WIDE'd0;
    weight14<=`WEIGHT_WIDE'd0;
    weight15<=`WEIGHT_WIDE'd0;
    weight16<=`WEIGHT_WIDE'd0;    
    end
    else begin
    weight1<=`WEIGHT_WIDE'd72;
    weight2<=-`WEIGHT_WIDE'd41;
    weight3<=`WEIGHT_WIDE'd6;
    weight4<=-`WEIGHT_WIDE'd76;
    weight5<=`WEIGHT_WIDE'd34;
    weight6<=`WEIGHT_WIDE'd127;
    weight7<=-`WEIGHT_WIDE'd25;
    weight8<=-`WEIGHT_WIDE'd120;
    weight9<=-`WEIGHT_WIDE'd58;
    weight10<=`WEIGHT_WIDE'd103;
    weight11<=`WEIGHT_WIDE'd60;
    weight12<=`WEIGHT_WIDE'd47;
    weight13<=`WEIGHT_WIDE'd20;
    weight14<=-`WEIGHT_WIDE'd95;
    weight15<=`WEIGHT_WIDE'd86;
    weight16<=-`WEIGHT_WIDE'd9;
    end
end


always @(posedge clk or negedge rstn)  begin
if (!rstn)
weight_o<= {`WEIGHT_WIDE{1'b0}};
        else 
        begin
                case (weight_index_i)
                    4'd0: weight_o <= weight1;
                    4'd1: weight_o <= weight2;
                    4'd2: weight_o <= weight3;
                    4'd3: weight_o <= weight4;
                    4'd4: weight_o <= weight5;
                    4'd5: weight_o <= weight6;
                    4'd6: weight_o <= weight7;
                    4'd7: weight_o <= weight8;
                    4'd8: weight_o <= weight9;
                    4'd9: weight_o <= weight10;
                    4'd10: weight_o <= weight11;
                    4'd11: weight_o <= weight12;
                    4'd12: weight_o <= weight13;
                    4'd13: weight_o <= weight14;
                    4'd14: weight_o <= weight15;
                    4'd15: weight_o <= weight16;
                    default: weight_o<= {`WEIGHT_WIDE{1'b0}};
                endcase
            end
end


always @(posedge clk or negedge rstn)  begin
if (!rstn)
begin
    weight_bram_addr_reg<={`WEIGHT_BRAM{1'b0}};
    weight_ready_reg<=1'b0;
    end
else if(s_index_valid==1'b1)
begin
    weight_bram_addr_reg <= s_index_ram+ INPUT_CHANNEL_NUM*channel_num_reg;
    weight_ready_reg<=1'b1;
end
end

always @(posedge clk or negedge rstn)  begin
if (!rstn)
begin
    weight_ready_reg2<=1'b0;
    weight_ready_reg3<=1'b0;
end
else begin
weight_ready_reg2<=weight_ready_reg;
weight_ready_reg3<=weight_ready_reg2;
weight_ready_reg4<=weight_ready_reg3;
end
end


always @(posedge clk or negedge rstn)  begin
if (!rstn)
begin
    addr_most_cnt<={`CONV1_ADDR{1'b0}};
end
else if(s_index_valid==1'b1)
begin
    if(addr_most_cnt<addr_most)
    addr_most_cnt<=addr_most_cnt+1'b1;
    else
    addr_most_cnt<={`CONV1_ADDR{1'b0}};
end
end


always @(posedge clk or negedge rstn) 
begin
    if (!rstn)
    begin
        channel_num_reg<={`CHANNEL_WIDE{1'b0}};
    end
    else if(s_index_valid==1'b1)
    begin
        if((addr_most_cnt==addr_most)&&(addr_most_cnt!=0))
        begin
            if(channel_num_reg<(OUTPUT_CHANNEL_NUM-1'b1))
                begin
                    channel_num_reg<=channel_num_reg+1'b1;
                end
            else
            channel_num_reg<={`CONV1_ADDR{1'b0}};    
        end 
    end
end





always @(posedge clk or negedge rstn)  begin
if (!rstn)
begin
    channel_num_reg2<={`CHANNEL_WIDE{1'b0}};
    channel_num_reg3<={`CHANNEL_WIDE{1'b0}};
    channel_num_reg4<={`CHANNEL_WIDE{1'b0}};
end
else 
    begin
    channel_num_reg2<=channel_num_reg;
    channel_num_reg3<=channel_num_reg2;
    channel_num_reg4<=channel_num_reg3;
    end
end






always @(posedge clk or negedge rstn)  begin
if (!rstn)
begin
        ram_release_reg<=1'b0;
end
else    if((channel_num_reg==(OUTPUT_CHANNEL_NUM-1'b1))&&(addr_most_cnt==addr_most))
begin
        ram_release_reg<=1'b1;
end
else 
begin
        ram_release_reg<=1'b0;    
end
end


single_bram1 u_single_bram1(
    .clkb(clk),
    .addrb(weight_bram_addr_reg),
    .doutb(weight_index_i)
    );


endmodule //pe_fc