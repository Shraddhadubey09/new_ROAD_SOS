`timescale 1ns/1ps
module crc_generator (
    input logic clk, input logic rst, input logic start, input logic data_valid,
    input logic last, input logic [7:0] data_in,
    output logic [15:0] crc_out, output logic crc_valid
);
    logic [15:0] crc_reg;
    function automatic [15:0] crc16_update(input [15:0] crc, input [7:0] data);
        integer i; reg [15:0] c;
        begin
            c = crc;
            for (i=0;i<8;i=i+1)
                c = (c[15]^data[7-i]) ? ({c[14:0],1'b0} ^ 16'h1021) : {c[14:0],1'b0};
            crc16_update = c;
        end
    endfunction
    always_ff @(posedge clk) begin
        if (rst) begin crc_reg<=16'hFFFF; crc_out<=0; crc_valid<=0; end
        else begin
            crc_valid <= 0;
            if (data_valid) begin
                if (last) begin
                    crc_out <= crc16_update(start ? 16'hFFFF : crc_reg, data_in);
                    crc_valid <= 1'b1;
                    crc_reg <= 16'hFFFF;
                end else begin
                    crc_reg <= crc16_update(start ? 16'hFFFF : crc_reg, data_in);
                end
            end
        end
    end
endmodule
