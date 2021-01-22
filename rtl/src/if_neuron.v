`timescale 1ns / 1ps
module if_neuron 
#(
    parameter THRESH=10,
    parameter RESET=0,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter WEIGHT_FILENAME="neuron.txt"
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output spike_out
);

reg [WEIGHT_SIZE - 1:0] potential;

integer input_index;

assign spike_out = (potential >= threshold_potential) ? 1 : 0;

reg [WEIGHT_SIZE-1:0] weight_mem [NUM_INPUTS-1:0];

integer weight_file;
reg [WEIGHT_SIZE-1:0] weight_file_input;

// initialize weight memory
initial begin
    
    weight_file = $fopen(WEIGHT_FILENAME,"r");

    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        $fscanf(weight_file,"%h\n",weight_file_input);
        weight_mem[input_index] = weight_file_input;
    end
    
    $fclose(weight_file);
end

// add all inputs that have a spike present
always @(posedge clk, posedge rst)
begin
    if (rst) begin
        potential = RESET;
    end
    else
    begin
        if(potential < threshold_potential)
            for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
                if(spike_in[input_index])
                    potential = potential + weight_mem[input_index];
            end
            //potential = potential + 1;
        else
            potential = RESET;
    end
end

endmodule