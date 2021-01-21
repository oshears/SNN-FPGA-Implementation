`timescale 1ns / 1ps
module if_neuron 
#(
    parameter threshold_potential=10,
    parameter reset_potential=0,
    parameter weight_size=32,
    parameter num_inputs=4
)
(
    input clk,
    input rst,
    input [num_inputs:0][weight_size-1:0] inputs,
    input [num_inputs:0] spike_in,
    output spike_out
);

reg [weight_size - 1:0] potential;

always @(posedge clk, posedge rst)
begin
    if (rst) begin
        potential = reset_potential;
    end
    else
    begin
        potential = potential + 1;
    end
end

endmodule