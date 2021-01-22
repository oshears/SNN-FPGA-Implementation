`timescale 1ns / 1ps
module if_network 
#(
    parameter THRESH=10,
    parameter RESET=0,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_OUTPUTS=1
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output [NUM_OUTPUTS-1:0] spike_out
);


genvar i;
generate
    for (i=0; i<NUM_OUTPUTS; i=i+1) begin : output_neurons
    if_neuron 
    #(
        .THRESH(THRESH),
        .RESET(RESET),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_INPUTS),
        .WEIGHT_FILENAME({i+48,".txt"})
    )
    if_neuron (
        .clk(clk),
        .rst(rst),
        .spike_in(spike_in),
        .spike_out(spike_out[i])
    );
end 
endgenerate

endmodule