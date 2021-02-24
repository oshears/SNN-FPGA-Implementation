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
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output spike_out
);

reg [WEIGHT_SIZE - 1:0] potential = 0;
reg threshold = THRESH;

integer input_index = 0;
integer weight_index = 0;

assign spike_out = (potential >= threshold) ? 1 : 0;

// reg [WEIGHT_SIZE-1:0] weight_mem [NUM_INPUTS-1:0];

wire [WEIGHT_SIZE - 1 : 0] spike_accumulator_outputs [NUM_INPUTS - 1 : 0];
reg  [WEIGHT_SIZE - 1 : 0]  spike_accumulator_weights [NUM_INPUTS - 1 : 0];

// initialize weight memory
/*
initial begin
    /*
    weight_file = $fopen(WEIGHT_FILENAME,"r");

    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        $fscanf(weight_file,"%h\n",weight_file_input);
        weight_mem[input_index] = weight_file_input;
        spike_accumulator_weights[input_index] = weight_file_input;
    end
    
    $fclose(weight_file);
end
*/

// value counters for each input
genvar i;
generate
    for (i=0; i<NUM_INPUTS; i=i+1) begin : spike_accumulators
        
        spike_accumulator #(
            .DATA_WIDTH(WEIGHT_SIZE)
        ) 
        spike_accumulator
        (
            .spike_in(spike_in[i]),
            .spike_weight(spike_accumulator_weights[i]),
            .rst(rst),
            .dout(spike_accumulator_outputs[i])
        );
    end

    
endgenerate

always_comb begin
    potential = 0;
    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        potential = potential + spike_accumulator_outputs[input_index];
    end 
end

always @(posedge rst) begin
    for (weight_index = 0; weight_index < NUM_INPUTS; weight_index = weight_index + 1) begin
        spike_accumulator_weights[weight_index] = 32'b1;
    end
    threshold = THRESH;
end


endmodule