`timescale 1ns / 1ps
module if_neuron 
#(
    parameter [61:0] THRESH=10,
    parameter [61:0] RESET=0,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter WEIGHT_ADDR_WIDTH=8
)
(
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output spike_out,

    // weight memory access
    input mem_clk,
    input [WEIGHT_ADDR_WIDTH - 1 : 0] mem_addr,
    input [WEIGHT_SIZE - 1 : 0] mem_din,
    input mem_wen,
    output reg [WEIGHT_SIZE - 1 : 0] mem_dout = 0
);

reg [2 * WEIGHT_SIZE - 1:0] potential = RESET;
reg [2 * WEIGHT_SIZE - 1:0] threshold = THRESH;


assign spike_out = (potential >= threshold) ? 1 : 0;

// reg [WEIGHT_SIZE-1:0] weight_mem [NUM_INPUTS-1:0];

wire [2*WEIGHT_SIZE - 1 : 0] spike_accumulator_outputs [NUM_INPUTS - 1 : 0];
reg  [WEIGHT_SIZE - 1 : 0]  spike_accumulator_weights [NUM_INPUTS - 1 : 0];


always @(posedge mem_clk) begin
    if (mem_addr < NUM_INPUTS) begin
        if(mem_wen) begin
            spike_accumulator_weights[mem_addr] <= mem_din;
        end
        mem_dout <= spike_accumulator_weights[mem_addr];
    end
end

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
    integer input_index = 0;
    
    // set potential equal to reset value
    potential = RESET;

    // add all the spike accumulators to the potential
    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        potential = potential + spike_accumulator_outputs[input_index];
    end 
end

initial begin
    integer weight_index = 0;

    for (weight_index = 0; weight_index < NUM_INPUTS; weight_index = weight_index + 1) begin
        spike_accumulator_weights[weight_index] = 32'b1;
    end
end


endmodule