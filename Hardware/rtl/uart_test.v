
module uart_test (
//system signal
    input                               clk                        ,
    input                               rstn                       ,

//bram
    output  reg [9 : 0]                 addr_test_ram              ,
    input       [7 : 0]                 spike                      ,

//controller
    output  reg [7 : 0]                 test_data                  ,
    output  reg                         uart_done                  
);

//localpara
localparam IDLE = 3'd0;
localparam IDLE2 = 3'd1;
localparam READ = 3'd2;
localparam WAIT = 3'd3;
localparam OVER0 = 3'd4;
localparam OVER = 3'd5;
localparam OVER2 = 3'd6;
localparam OVER3 = 3'd7;

//reg
reg    [2 : 0]                         current_state;
reg    [2 : 0]                         next_state;
reg    [11 : 0]                        cnt_wait;   //2604个周期 25MHZ

reg    [6 : 0]                         cnt_data;  //1024个数据为一个timestep

//state machine: process1
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        current_state <= IDLE;
    end
    else
        current_state <= next_state;
end

//state machine: process2
always @(*) begin
    case (current_state)
        IDLE:begin
            if (cnt_wait == 12'd2604) begin
                next_state = IDLE2;
            end
            else 
                next_state = IDLE;
        end 
        IDLE2:begin
            if (cnt_wait == 12'd2604) begin
                next_state = READ;
            end
            else 
                next_state = IDLE2;
        end
        READ:begin
            next_state = WAIT;
        end
        WAIT:begin
            if ((cnt_data == 7'd127)&&(cnt_wait == 12'd2604)) begin
                next_state = OVER0;
            end
            else if (cnt_wait == 12'd2604)begin
                next_state = READ;
            end
            else
                next_state = WAIT;
        end
        OVER0:
            next_state = OVER;
        OVER:begin
            if (cnt_wait == 12'd2604) begin
                next_state = OVER2;
            end
            else
                next_state = OVER;
        end
        OVER2:begin
            if (cnt_wait == 12'd4095) begin
                next_state = OVER3;
            end
            else
                next_state = OVER2;
        end
        OVER3:begin
            next_state = IDLE;
        end
        default: ;
    endcase
end

//state machine: process3
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        addr_test_ram <= 10'b0;
        cnt_wait <= 12'b0;
        cnt_data <= 7'b0;
        test_data <= 8'b0;
        uart_done <= 1'b0;
    end
    else begin
        case (next_state)
            IDLE:begin
                addr_test_ram <= addr_test_ram;
                cnt_wait <= cnt_wait + 1;
                cnt_data <= 7'b0;
                if (cnt_wait == 12'd1302) begin
                    test_data <= 8'hFA;
                    uart_done <= 1'b1;
                end
                else begin
                    test_data <= 8'h00;
                    uart_done <= 1'b0;
                end
            end 
            IDLE2:begin
                addr_test_ram <= addr_test_ram;
                cnt_wait <= cnt_wait + 1;
                cnt_data <= 7'b0;
                if (cnt_wait == 12'd1302) begin
                    test_data <= 8'hF1;
                    uart_done <= 1'b1;
                end
                else begin
                    test_data <= 8'h00;
                    uart_done <= 1'b0;
                end              
            end
            READ:begin
                addr_test_ram <= addr_test_ram + 1;
                cnt_wait <= 12'b0;
                cnt_data <= cnt_data + 1;                
                test_data <= spike;
                uart_done <= 1'b1;
            end
            WAIT:begin
                addr_test_ram <= addr_test_ram;
                cnt_wait <= cnt_wait + 1;
                cnt_data <= cnt_data;
                test_data <= 8'b0;
                uart_done <= 1'b0;
            end
            OVER0:begin
                test_data <= spike;
                uart_done <= 1'b1;                
                cnt_wait <= 12'b0;
            end
            OVER:begin
                addr_test_ram <= addr_test_ram;
                cnt_wait <= cnt_wait + 1;
                cnt_data <= 7'b0; 
                if (cnt_wait == 12'd1302) begin
                    test_data <= 8'hF1;
                    uart_done <= 1'b1;
                end
                else begin
                    test_data <= 8'h00;
                    uart_done <= 1'b0;
                end
            end
            OVER2:begin
                addr_test_ram <= addr_test_ram;
                cnt_wait <= cnt_wait + 1;
                cnt_data <= 7'b0;                
                if (cnt_wait == 12'd3906) begin
                    test_data <= 8'hFA;
                    uart_done <= 1'b1;
                end
                else begin
                    test_data <= 8'h00;
                    uart_done <= 1'b0;
                end              
            end
            OVER3:begin
                cnt_wait <= 12'b0;
            end
            default: ;
        endcase
    end
end

endmodule //uart_test