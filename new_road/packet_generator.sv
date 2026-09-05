`timescale 1ns/1ps
// 8-byte wire frame: A5 | TYPE/EVENT | VEH_H | VEH_L | CRC_H | CRC_L | 5A | 0A
// CRC-16/CCITT-FALSE covers the first four bytes.
module packet_generator (
    input logic clk, input logic rst,
    input logic request, input logic [7:0] event_id, input logic [15:0] vehicle_id,
    output logic uart_start, output logic [7:0] uart_data,
    input logic uart_busy, input logic uart_done,
    output logic busy, output logic packet_done,
    output logic [47:0] packet_out
);
    typedef enum logic [3:0] {IDLE, C0,C1,C2,C3,CW,S0,S1,S2,S3,S4,S5,S6,S7} st_t;
    st_t state;
    logic [7:0] ev; logic [15:0] veh, crc_reg; logic [15:0] crc_out; logic crc_valid;
    logic crc_start, crc_dv, crc_last; logic [7:0] crc_data;

    crc_generator u_crc(.clk(clk),.rst(rst),.start(crc_start),.data_valid(crc_dv),.last(crc_last),.data_in(crc_data),.crc_out(crc_out),.crc_valid(crc_valid));

    always_ff @(posedge clk) begin
        if (rst) begin state<=IDLE; ev<=0; veh<=0; crc_reg<=0; packet_out<=0; end
        else case(state)
            IDLE: if(request) begin ev<=event_id; veh<=vehicle_id; state<=C0; end
            C0: state<=C1;
            C1: state<=C2;
            C2: state<=C3;
            C3: state<=CW;
            CW: if(crc_valid) begin crc_reg<=crc_out; packet_out<={8'hA5,ev,veh,crc_out}; state<=S0; end
            S0: if(!uart_busy) state<=S1;
            S1: if(!uart_busy) state<=S2;
            S2: if(!uart_busy) state<=S3;
            S3: if(!uart_busy) state<=S4;
            S4: if(!uart_busy) state<=S5;
            S5: if(!uart_busy) state<=S6;
            S6: if(!uart_busy) state<=S7;
            S7: if(uart_done) state<=IDLE;
            default: state<=IDLE;
        endcase
    end

    always_comb begin
        crc_start=0; crc_dv=0; crc_last=0; crc_data=0;
        uart_start=0; uart_data=0; busy=(state!=IDLE); packet_done=0;
        case(state)
            C0: begin crc_start=1; crc_dv=1; crc_data=8'hA5; end
            C1: begin crc_dv=1; crc_data=ev; end
            C2: begin crc_dv=1; crc_data=veh[15:8]; end
            C3: begin crc_dv=1; crc_last=1; crc_data=veh[7:0]; end
            S0: begin uart_data=8'hA5; if(!uart_busy) uart_start=1; end
            S1: begin uart_data=ev; if(!uart_busy) uart_start=1; end
            S2: begin uart_data=veh[15:8]; if(!uart_busy) uart_start=1; end
            S3: begin uart_data=veh[7:0]; if(!uart_busy) uart_start=1; end
            S4: begin uart_data=crc_reg[15:8]; if(!uart_busy) uart_start=1; end
            S5: begin uart_data=crc_reg[7:0]; if(!uart_busy) uart_start=1; end
            S6: begin uart_data=8'h5A; if(!uart_busy) uart_start=1; end
            S7: begin uart_data=8'h0A; if(!uart_busy) uart_start=1; if(uart_done) packet_done=1; end
            default: ;
        endcase
    end
endmodule
