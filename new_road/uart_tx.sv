`timescale 1ns/1ps
module uart_tx #(
    parameter int CLK_FREQ_HZ=100_000_000, parameter int BAUD_RATE=115_200
)(
    input logic clk,input logic rst,input logic tx_start,input logic [7:0] tx_data,
    output logic tx,output logic tx_busy,output logic tx_done
);
    localparam int CPB=CLK_FREQ_HZ/BAUD_RATE;
    localparam int CW=(CPB<2)?1:$clog2(CPB);
    logic [CW-1:0] cnt; logic [3:0] bit_count; logic [9:0] shift;
    always_ff @(posedge clk) begin
        if(rst) begin tx<=1; tx_busy<=0; tx_done<=0; cnt<='0; bit_count<='0; shift<=10'h3FF; end
        else begin
            tx_done<=0;
            if(!tx_busy) begin
                tx<=1; cnt<='0; bit_count<='0;
                if(tx_start) begin shift<={1'b1,tx_data,1'b0}; tx_busy<=1; tx<=0; end
            end else if(cnt==CPB-1) begin
                cnt<='0;
                if(bit_count==9) begin tx_busy<=0; tx<=1; tx_done<=1; bit_count<='0; end
                else begin bit_count<=bit_count+1'b1; shift<={1'b1,shift[9:1]}; tx<=shift[1]; end
            end else cnt<=cnt+1'b1;
        end
    end
endmodule
