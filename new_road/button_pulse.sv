`timescale 1ns/1ps
module button_pulse #(
    parameter int DEBOUNCE_CYCLES = 500_000  // 5 ms @ 100 MHz
)(
    input  logic clk,
    input  logic rst,
    input  logic button_in,
    output logic pulse
);
    localparam int CW = (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);
    logic sync1, sync2, stable;
    logic [CW-1:0] count;

    always_ff @(posedge clk) begin
        if (rst) begin
            sync1 <= 0; sync2 <= 0; stable <= 0; count <= '0; pulse <= 0;
        end else begin
            sync1 <= button_in;
            sync2 <= sync1;
            pulse <= 1'b0;
            if (sync2 == stable) begin
                count <= '0;
            end else if (DEBOUNCE_CYCLES <= 1 || count == DEBOUNCE_CYCLES-1) begin
                stable <= sync2;
                count <= '0;
                if (sync2) pulse <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
