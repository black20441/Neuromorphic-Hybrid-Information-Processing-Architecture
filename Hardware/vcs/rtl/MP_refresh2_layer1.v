`include "../rtl/define.vh"
module MP_refresh_layer1 #(
    parameter  THRESHOLD =305,
    parameter MP_RESET=`MP_WIDE'd0,
    parameter OUTPUT_CHANNEL_NUM      = 256 )
(
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//pe_fc
    input                               mp_ready                   ,
    input    signed  [`MP_WIDE-1 : 0]   mp_out                     ,
    input      [`CHANNEL_WIDE-1 : 0]    channel_num                ,
    input                           output_num_switch_pe,

//next layer
    output  [`SYNAPSE_INDEX-1 : 0]   neuron                     ,
    output                           neuron_valid              

);

//localparam

//MP_bram_port_r
wire     signed [`MP_WIDE-1 : 0]         mp_r;
// mp_addr_r=channel_num

//MP_bram_port_w
reg [`MP_ADDR-1 : 0]         mp_addr_w_reg;

wire  signed    [`MP_WIDE-1 : 0]         mp_w;
wire mp_w_en;


reg mp_ready_reg;
//reg

    reg    signed    [`MP_WIDE-1 : 0]         mp_reg;
    // reg        [`MP_WIDE-1 : 0]         threshold;
    reg output_num_switch_pe_reg;
    reg output_num_switch_pe_reg2;
    reg [3:0]   timestep_num;
//    reg [`SYNAPSE_INDEX-1 : 0]   neuron_buffer  [1:0];
   
wire                                 spike;
wire                             mp_start;
wire                        timestep_switch_flag;


//encode
localparam IDLE = 2'b00, START=2'b01,WRITE = 2'b10, FINISH = 2'b11;
reg [1:0] current_state;
reg [1:0] next_state;
 reg  pause; 
reg write_enable_reg;
 reg  [`SYNAPSE_INDEX:0] output_data;  

    
assign timestep_switch_flag=((channel_num==0)&&(output_num_switch_pe_reg==1'b1))?1'b1:1'b0;  

// assign mp_addr_r=channel_num;
assign mp_w_en=(output_num_switch_pe_reg==1'b1)?1'b1:1'b0;
// assign mp_addr_w=mp_addr_w_reg;

assign spike=(output_num_switch_pe_reg!=1'b1)?1'b0:(mp_reg<=THRESHOLD)?1'b0:1'b1;
assign mp_w=(output_num_switch_pe_reg!=1'b1)?1'b0:(mp_reg<=THRESHOLD)?mp_reg:MP_RESET;
assign mp_start=mp_ready&(~mp_ready_reg);

assign neuron=output_data;
assign neuron_valid=write_enable_reg;

always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    mp_ready_reg<=1'b0;
    else
    mp_ready_reg<=mp_ready;
    end
    
always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    timestep_num<=4'b0;
    else if (timestep_switch_flag==1'b1)
    begin
    if(timestep_num<7)
    begin
    timestep_num<=timestep_num+1'b1;
    end
    else
    timestep_num<=4'b0;
    end
    else
    timestep_num<=timestep_num;
    end
//    reg        [`INDEX_PIC-1 : 0]       pic_num;
//    reg        [`INDEX_PX-1 : 0]        pic_index;
//    reg                                 pic_valid;
//    reg        [`INDEX_PX_WIDE-1 : 0]   pic_index_x;
//    reg        [`INDEX_PX_WIDE-1 : 0]   pic_index_y;
//    reg                                 pic_pos_valid;

//mp_refresh
//always @(posedge clk or negedge rstn) begin
//    if (!rstn) begin
//        mp_refresh_reg <= 1'b0;
//    end
//    else if ((current_state == FIRE)&&(spike == 1'b1))
//    begin
//         mp_refresh_reg <= 1'b1;
//    end
//    else if (current_state == IDLE) begin
//        mp_refresh_reg <= 1'b0;
//    end
//    else
//        mp_refresh_reg <= mp_refresh_reg;
//end


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mp_reg <= {`MP_WIDE{1'b0}};
    end
else    if (output_num_switch_pe_reg==1'b1)
begin
    mp_reg<=mp_out;
end
else if ((output_num_switch_pe==1'b1)||(mp_start==1'b1))
    mp_reg<=mp_reg+mp_out+mp_r;
    
else  mp_reg<=mp_reg+mp_out;
end


always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
        mp_addr_w_reg<={`MP_ADDR{1'b0}};
        end
        else     if (output_num_switch_pe_reg==1'b1)
        begin 
        if(mp_addr_w_reg< (OUTPUT_CHANNEL_NUM-1'b1))
            mp_addr_w_reg<=mp_addr_w_reg+1'b1;
            else
             mp_addr_w_reg<={`MP_ADDR{1'b0}};
        end
        end
        
 always@(posedge clk or negedge rstn)
 begin 
    if(!rstn)
    begin
    output_num_switch_pe_reg<=1'b0;
    output_num_switch_pe_reg2<=1'b0;
    end
    else
    begin
    output_num_switch_pe_reg<=output_num_switch_pe;
    output_num_switch_pe_reg2<=output_num_switch_pe_reg;
    end
 end
    
    
    

        

always@(posedge clk or negedge rstn)
begin
    if(!rstn)
    begin
    current_state<=IDLE;
    end
    else
    begin
    current_state<=next_state;
    end
    end
    
always@(*)
    begin
    case(current_state)
        IDLE:
        begin
        if(mp_start==1'b1)
        begin
            next_state<=START;
        end
        else
            next_state<=IDLE;
    end
    START:
    begin
        next_state<=WRITE;
    end
    WRITE:
    begin
        if(timestep_switch_flag==1'b1)
        begin
            next_state<=FINISH;
        end
        else
        next_state<=WRITE;
    end
    FINISH:
    begin
        if(pause)
        next_state<=FINISH;
        else
        next_state<=START;
    end
endcase
end



always @(posedge clk) begin
    case(next_state)
        IDLE: begin // ��ʼ״̬
            write_enable_reg <= 1'b0;
            output_data <= 8'b0;
            pause<=1'b0;
        end

        START: begin // timestep_switch_flagΪ1״̬
            write_enable_reg <= 1; // дʹ������
            output_data <= 16'hf1fa; // ��дһ��ʱ�ӵ�f1fa
        end
        WRITE: begin // spike�ߵ�ƽ״̬
            if (spike) begin
                write_enable_reg <= 1'b1; // spike�ߵ�ƽʱдʹ������
                output_data <= mp_addr_w_reg; // �������Ϊmp_addr_w_reg
            end else begin
                write_enable_reg <= 1'b0; // ���spike��͵�ƽ�����س�ʼ״�?
                output_data<=output_data;
            end
        end

        FINISH: begin
            if(spike==1'b1)
            begin
                pause<=1'b1;
            write_enable_reg <= 1; // дʹ������
            output_data <= mp_addr_w_reg; // ��дһ��ʱ�ӵ�faf1
            end
            else 
            begin
                pause<=1'b0;
                write_enable_reg <= 1;
                output_data <= 16'hfaf1;

        end
        end
        default: current_state <= IDLE; // Ĭ�Ϸ��س�ʼ״̬
    endcase
end
 
    

// mp_refresh_ram_0 mp_refresh_ram_layer1(
//     .clka(clk),
//     .wea(mp_w_en),
//     .addra(mp_addr_w_reg),
//     .dina(mp_w),
//     .clkb(clk),
//     .addrb(channel_num),
//     .doutb(mp_r)
//     );

bram
#(
  .ADDR (9),
  .WIDE (15),
  .DEPTH (16384)
)     
mp_refresh_ram_layer1(
    .clka(clk),
    .wea(mp_w_en),
    .addra(mp_addr_w_reg),
    .dina(mp_w),
    .clkb(clk),
    .addrb({2'b0,channel_num}),
    .doutb(mp_r)
    );

//        sync_fifo endfifo1 (
//    .clk(clk),
//    .rstn(rstn),
//    .wr_en(neuron_valid),
//    .wr_data(neuron),
//    .rd_en(1'b0)
//    );
endmodule //MP_refresh