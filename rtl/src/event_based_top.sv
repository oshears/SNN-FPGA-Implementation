`timescale 1ns / 1ps
module event_based_top
(
    input wire clk,
    input wire rst,
    input wire spike_in,
    output reg spike_out
);

always @(spike_in) begin
    spike_out = spike_in;
end

endmodule