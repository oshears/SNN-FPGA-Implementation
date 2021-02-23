`timescale 1ns / 1ps
module snn_fpga_top
(
    input wire clk,
    input wire rst,
    input wire spike_in,
    output wire spike_out
);

if_network 
#(
    .THRESH(4),
    .RESET(0),
    .REFRAC(0),
    .WEIGHT_SIZE(32),
    .NUM_INPUTS(1),
    .NUM_OUTPUTS(1),
    .NUM_LAYERS(1),
    .NUM_HIDDEN_LAYER_NEURONS(1)
)
if_network
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(spike_out)
);

endmodule