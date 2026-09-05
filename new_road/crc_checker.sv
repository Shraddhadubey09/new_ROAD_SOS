`timescale 1ns/1ps
module crc_checker(
    input logic clk,input logic rst,input logic [47:0] packet_in,input logic packet_valid,
    output logic crc_pass,output logic crc_done
);
    function automatic [15:0] upd(input [15:0] crc,input [7:0] data);
        integer i; reg [15:0] c;
        begin c=crc; for(i=0;i<8;i=i+1) c=(c[15]^data[7-i])?({c[14:0],1'b0}^16'h1021):{c[14:0],1'b0}; upd=c; end
    endfunction
    logic [15:0] c1,c2,c3,calc;
    always_comb begin c1=upd(16'hFFFF,packet_in[47:40]); c2=upd(c1,packet_in[39:32]); c3=upd(c2,packet_in[31:24]); calc=upd(c3,packet_in[23:16]); end
    always_ff @(posedge clk) begin
        if(rst) begin crc_pass<=0; crc_done<=0; end
        else begin crc_done<=0; if(packet_valid) begin crc_pass<=(calc==packet_in[15:0]); crc_done<=1; end end
    end
endmodule
