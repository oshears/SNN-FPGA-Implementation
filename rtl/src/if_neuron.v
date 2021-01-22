`timescale 1ns / 1ps
module if_neuron 
#(
    parameter threshold_potential=10,
    parameter reset_potential=0,
    parameter weight_size=32,
    parameter num_inputs=4,
    parameter weight_filename="neuron.txt"
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

reg [weight_size-1:0] weight_mem [num_inputs-1:0];

integer weight_file;
reg [weight_size-1:0] weight_file_input;

// initialize weight memory
initial begin
    
    weight_file = $fopen(weight_filename,"r");

    for(input_index = 0; input_index < num_inputs; input_index = input_index + 1) begin
        $fscanf(weight_file,"%h\n",weight_file_input);
        weight_mem[input_index] = weight_file_input;
    end
    
    $fclose(weight_file);
end

// add all inputs that have a spike present
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
                    potential = potential + weight_mem[input_index];
            end
            //potential = potential + 1;
        else
            potential = reset_potential;
    end
end

endmodule