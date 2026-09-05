`timescale 1ns/1ps
module packet_decoder(
    input logic clk,input logic rst,input logic [7:0] byte_in,input logic byte_valid,
    output logic [47:0] packet_out,output logic packet_valid,
    output logic [7:0] event_id,output logic [15:0] vehicle_id,output logic frame_error
);
    typedef enum logic [2:0] {WAIT_SOF,EVENT,VH,VL,CH,CL,EOF_MARK,NL} st_t; st_t st;
    logic [7:0] ev,vh; logic [15:0] vl,crc;
    always_ff @(posedge clk) begin
        if(rst) begin st<=WAIT_SOF; ev<=0;vh<=0;vl<=0;crc<=0;packet_out<=0;packet_valid<=0;event_id<=0;vehicle_id<=0;frame_error<=0; end
        else begin
            packet_valid<=0; frame_error<=0;
            if(byte_valid) case(st)
                WAIT_SOF: if(byte_in==8'hA5) st<=EVENT;
                EVENT: begin ev<=byte_in; st<=VH; end
                VH: begin vh<=byte_in; st<=VL; end
                VL: begin vl<={vh,byte_in}; st<=CH; end
                CH: begin crc[15:8]<=byte_in; st<=CL; end
                CL: begin crc[7:0]<=byte_in; st<=EOF_MARK; end
                EOF_MARK: if(byte_in==8'h5A) st<=NL; else begin frame_error<=1; st<=WAIT_SOF; end
                NL: begin
                    if(byte_in==8'h0A) begin packet_out<={8'hA5,ev,vl,crc}; packet_valid<=1; event_id<=ev; vehicle_id<=vl; end
                    else frame_error<=1;
                    st<=WAIT_SOF;
                end
                default: st<=WAIT_SOF;
            endcase
        end
    end
endmodule

