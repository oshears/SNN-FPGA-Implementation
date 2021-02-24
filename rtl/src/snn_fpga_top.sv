`timescale 1ns / 1ps
module snn_fpga_top
(
    input wire clk,
    input wire rst,
    input wire spike_in,
    output reg spike_out
);

reg spike_in_i;
reg spike_out_i;


if_network 
#(
    .THRESH(4),
    .RESET(0),
    .REFRAC(0),
    .WEIGHT_SIZE(32),
    .NUM_INPUTS(1),
    .NUM_LAYERS(1),
    .NUM_HIDDEN_LAYER_NEURONS({1})
)
if_network
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in_i),
    .spike_out(spike_out_i)
);

always @(posedge clk) begin
    spike_in_i = spike_in;
end

always @(posedge spike_out_i, posedge rst) begin
    if (rst)
        spike_out = 0;
    else
        spike_out = 1;
end

endmodule