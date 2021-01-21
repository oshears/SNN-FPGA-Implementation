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
    input [num_inputs-1:0] spike_in,
    output spike_out
);

reg [weight_size - 1:0] potential;

integer input_index;

assign spike_out = (potential >= threshold_potential) ? 1 : 0;

reg [num_inputs-1:0] input_weights [weight_size-1:0] = 0;

always @(posedge clk, posedge rst)
begin
    if (rst) begin
        potential = reset_potential;
    end
    else
    begin
        if(potential < threshold_potential)
            for(input_index = 0; input_index < num_inputs; input_index = input_index + 1) begin
                if(spike_in[input_index])
                    potential = potential + input_weights[input_index];
            end
            //potential = potential + 1;
        else
            potential = reset_potential;
    end
end

endmodule