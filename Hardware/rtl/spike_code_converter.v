`include "../rtl/define.vh"
`timescale 1 ns/ 100 ps
module spike_code_converter (
//system input
    input                               clk                        ,
    input                               rstn                       ,

//uart
    input                               uart_done                  ,
    input              [7 : 0]          uart_data                  ,

//output fifo
    output reg         [15 : 0]         s_index                    ,
    output reg                          w_en                       ,
    input                               full                       ,
    input                               almost_full                ,

//timestep switch to next pe
    output reg         [1 : 0]          timestep_switch             //10 start ,11 end
);


//localpara
localparam IDLE = 2'd0;
localparam INIT = 2'd1;
localparam OUTPUT = 2'd2;

//reg
reg                    [15 : 0]         s_index_reg                ;//begin signal(F1FA) ending signal(FAF1)
reg                    [15 : 0]         s_index_bit                ;

reg                                     buffer                     ;
reg                                     coding_en                  ;
reg                                     coding_sign                ;
reg                                     coding_sign_done           ;
reg                    [ 1 : 0]         con_current_state          ;
reg                    [ 1 : 0]         con_next_state             ;

reg                                     coding_style_reg           ;

//wire
wire                                    AER_position_valid         ;
wire                   [15 : 0]         AER_index_position         ;

wire                                    coding_style               ;


assign coding_style = ((s_index_reg == 16'hF1FA) && (con_next_state == INIT))? 1 : 0;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        coding_style_reg <= 1'b0;
    end
    else begin
        if (coding_style) begin
            coding_style_reg <= 1'b1;
        end
        else if (s_index_reg == 16'hFAF1) begin
            coding_style_reg <= 1'b0;
        end
        else begin
            coding_style_reg <= coding_style_reg;
        end
    end
end

//uart_data receive
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        buffer <= 1'b0;
        s_index_reg <= 8'b0;
        coding_en <= 1'b0;
    end
    else if ((uart_done)&&(buffer == 1'b0)) begin
        buffer <= 1'b1;
        s_index_reg[7 : 0] <= uart_data;
    end
    else if ((uart_done)&&(buffer == 1'b1)) begin
        buffer <= 1'b0;
        s_index_reg[15 : 8] <= uart_data;
        coding_en <= 1'b1;
    end
    else if (coding_en == 1'b1) begin
        coding_en <= 1'b0;
        s_index_reg <= 16'b0;
    end
    else begin
        buffer <= buffer;
        s_index_reg <= s_index_reg;
    end
end

//state machine
//Process 1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        con_current_state <= IDLE;
    end
    else
        con_current_state <= con_next_state;
end

//Process 2
always @(*) 
begin
   case (con_current_state)
    IDLE:
    begin
        if (s_index_reg == 16'hF1FA) begin
            con_next_state = INIT;
        end
        else
            con_next_state = IDLE;
    end 
    INIT:
    begin
        if (s_index_reg == 16'hFAF1) begin
            con_next_state = OUTPUT;
        end
        else
            con_next_state = INIT;
    end
    OUTPUT:
    begin
        if (almost_full == 1'b1) begin
            con_next_state = OUTPUT;
        end
        else
            con_next_state = IDLE;
    end
    default: con_next_state = 2'bxx;
   endcase
end

//Process 3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s_index_bit <= 16'b0;
    end
    else 
    begin
    case (con_next_state)
        IDLE: 
        begin
            w_en <= 1'b0;
            s_index <= 16'b0;
            s_index_bit <= 16'b0;
            timestep_switch <= 2'b0;
        end        
        INIT: 
        begin
            timestep_switch <= 2'b10;
             case ((coding_style)||(coding_style_reg))
                1'b0:begin
                if ((coding_en == 1'b1)&&(almost_full != 1'b1))begin
                    s_index <= s_index_reg;
                    w_en <= 1'b1;
                end
                else if ((coding_en == 1'b1)&&(almost_full == 1'b1)) begin
                    s_index <= s_index_reg;
                    w_en <= 1'b0;
                end 
                else begin
                    s_index <= 16'b0;
                    w_en <= 1'b0;
                end
                end
                1'b1:begin
                if ((AER_position_valid == 1'b1)&&(almost_full != 1'b1)) begin
                    s_index <= AER_index_position;
                    w_en <= 1'b1;
                end
                else if ((coding_en == 1'b1)&&(s_index_reg == 16'hF1FA)&&(almost_full != 1'b1)) begin
                    s_index <= 16'hF1FA;
                    w_en <= 1'b1;
                end
                else if ((coding_en == 1'b1)&&(s_index_reg == 16'hFAF1)&&(almost_full != 1'b1)) begin
                    s_index <= 16'hFAF1;
                    w_en <= 1'b1;
                end
                else if ((coding_en == 1'b1)&&((s_index_reg != 16'hF1FA)&&(s_index_reg != 16'hFAF1))&&(almost_full != 1'b1)) begin
                    s_index_bit <= s_index_reg;
                    w_en <= 1'b0;
                end
                else begin
                    s_index <= AER_index_position;
                    w_en <= 1'b0;
                end
                end
                default: begin
                    s_index <= s_index_reg;
                    w_en <= 1'b0;
                end
             endcase
        end
        OUTPUT:
        begin        
        if (almost_full != 1'b1) begin   
                w_en <= 1'b1;
                s_index <= 16'hFAF1; 
                s_index_bit <= 16'b0;
                timestep_switch <= 2'b11;
        end   
        else begin
                w_en <= 1'b0;
                s_index <= 16'hFAF1; 
                s_index_bit <= 16'b0;
                timestep_switch <= 2'b11;
        end            
        end     
        default: begin
                w_en <= 1'b0;
                s_index <= 16'b0;
                s_index_bit <= 16'bx;
                timestep_switch <= 2'b0;
                end
    endcase
    end
end

//coding_sign
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        coding_sign <= 1'b0;
        coding_sign_done <= 1'b0;
    end
    else if ((coding_sign_done == 1'b0)&&(coding_en == 1'b1)&&((s_index_reg != 16'hF1FA)&&(s_index_reg != 16'hFAF1))&&(almost_full != 1'b1)) begin
        coding_sign <= 1'b1;
        coding_sign_done <= 1'b1;
    end
    else if (coding_sign_done == 1'b1) begin
        coding_sign <= 1'b0;
        coding_sign_done <= 1'b0;
    end
    else begin
        coding_sign <= 1'b0;
        coding_sign_done <= 1'b0;
    end
end

AER_coding u_AER_coding(
    .clk                (clk                ),
    .rstn               (rstn               ),
    .coding_sign        (coding_sign        ),
    .timestep_switch    (timestep_switch    ),
    .s_index            (s_index_bit        ),
    .AER_index_position (AER_index_position ),
    .AER_position_valid (AER_position_valid )
);


endmodule //controller