`timescale 1ns / 1ps
module if_network 
#(
    parameter threshold_potential=10,
    parameter reset_potential=0,
    parameter weight_size=32,
    parameter num_inputs=4,
    parameter weight_filename="neuron.txt",
    parameter num_outputs=1
)
(
    input clk,
    input rst,
    input [num_inputs-1:0] spike_in,
    output [num_outputs-1:0] spike_out
);


genvar i;
generate
    for (i=1; i<=10; i=i+1) begin : generate_block_identifier // <-- example block name
    if_neuron if_neuron (
        .clk(clk),
        .rst(rst),
        .spike_in(spike_in),
        .spike_out(spike_out[i]),
    );
end 
endgenerate

endmodule