`timescale 1ns / 1ps
module if_neuron 
#(
    parameter THRESH=10,
    parameter RESET=0,
    parameter REFRAC=0,
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

integer input_index;

assign spike_out = (potential >= THRESH) ? 1 : 0;

reg [WEIGHT_SIZE-1:0] weight_mem [NUM_INPUTS-1:0];

integer weight_file;
reg [WEIGHT_SIZE-1:0] weight_file_input;

reg [31:0] refrac_counter = 0;
reg refrac_en = 0;
wire refrac_done = 0;
reg refrac_rst = 0;
reg [1:0] current_state = 0;
reg [1:0] next_state = 0;
reg accumulator_en = 0;


wire [WEIGHT_SIZE - 1 : 0] spike_accumulator_outputs [NUM_INPUTS - 1 : 0];
reg  [WEIGHT_SIZE - 1 : 0]  spike_accumulator_weights [NUM_INPUTS - 1 : 0];

localparam NORMAL_STATE = 0;
localparam REFRACTORY_STATE = 1;

// initialize weight memory
initial begin
    /*
    weight_file = $fopen(WEIGHT_FILENAME,"r");

    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        $fscanf(weight_file,"%h\n",weight_file_input);
        weight_mem[input_index] = weight_file_input;
        spike_accumulator_weights[input_index] = weight_file_input;
    end
    
    $fclose(weight_file);
    */
    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        spike_accumulator_weights[input_index] = 1;
    end
end

// value counters for each input
genvar i;
generate
    for (i=0; i<NUM_INPUTS; i=i+1) begin : spike_accumulators
        // reg  [WEIGHT_SIZE - 1: 0] spike_accumulator_weight;
        // wire  [WEIGHT_SIZE - 1: 0] spike_accumulator_output;
        
        spike_accumulator #(
            .DATA_WIDTH(WEIGHT_SIZE)
        ) 
        spike_accumulator
        (
            .spike_in(spike_in[i]),
            // .spike_weight(spike_accumulator_weight),
            .spike_weight(spike_accumulator_weights[i]),
            .rst(rst),
            .dout(spike_accumulator_outputs[i])
        );
    end

    
endgenerate

always @(spike_accumulator_outputs) begin
    potential = 0;
    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        potential = potential + spike_accumulator_outputs[input_index];
    end 
end


endmodule