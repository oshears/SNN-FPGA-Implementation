`timescale 1ns / 1ps
module if_layer
#(
    parameter THRESH=15,
    parameter RESET=0,
    parameter REFRAC=5,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_OUTPUTS=1
)
(
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
        .REFRAC(REFRAC),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_INPUTS),
        //.WEIGHT_FILENAME({i+48,".txt"})
        .WEIGHT_FILENAME("neuron.txt")
    )
    if_neuron (
        .rst(rst),
        .spike_in(spike_in),
        .spike_out(spike_out[i])
    );
end 
endgenerate

endmodule