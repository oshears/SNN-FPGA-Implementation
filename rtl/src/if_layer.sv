`timescale 1ns / 1ps
module if_layer
#(
    parameter [61:0] THRESH=15,
    parameter [61:0] RESET=0,
    parameter [61:0] REFRAC=5,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_NEURONS=1,
    parameter SINGLE_SPIKE=0,
    parameter NEURON_ADDR_WIDTH = 28,
    parameter WEIGHT_ADDR_WIDTH = 10
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output [NUM_NEURONS-1:0] spike_out,

    // weight memory access
    input [NEURON_ADDR_WIDTH - 1 : 0] mem_addr,
    input [WEIGHT_SIZE - 1 : 0] mem_din,
    input mem_wen,
    output [WEIGHT_SIZE - 1 : 0] mem_dout
);

wire [NUM_NEURONS-1:0] spike_out_i;
wire [NUM_NEURONS-1:0] neuron_rst;

assign spike_out = spike_out_i;


wire [NEURON_ADDR_WIDTH - WEIGHT_ADDR_WIDTH:0] neuron_mem_sel;
assign neuron_mem_sel = mem_addr[NEURON_ADDR_WIDTH - 1:WEIGHT_ADDR_WIDTH];
wire [WEIGHT_ADDR_WIDTH - 1 :0] mem_addr_i;
assign mem_addr_i = mem_addr[WEIGHT_ADDR_WIDTH - 1 : 0]; 

wire [NUM_NEURONS - 1 : 0] neuron_wen;

wire [WEIGHT_SIZE - 1 : 0] neuron_mem_dout [NUM_NEURONS - 1 : 0];

reg [WEIGHT_SIZE - 1 : 0] mem_dout_i = 0;

integer mem_dout_sel = 0;

assign mem_dout = mem_dout_i;

always_comb begin : mem_dout_block
    mem_dout_i = neuron_mem_dout[0]; 
    for (mem_dout_sel = 0; mem_dout_sel < NUM_NEURONS; mem_dout_sel = mem_dout_sel + 1) begin
        if (neuron_mem_sel == mem_dout_sel) begin
            mem_dout_i = neuron_mem_dout[mem_dout_sel];
        end
    end
end

genvar i;
generate
    for (i = 0; i < NUM_NEURONS; i = i + 1) begin
        assign neuron_wen[i] = (neuron_mem_sel == i) ? mem_wen : 0;
    end

    for (i=0; i<NUM_NEURONS; i=i+1) begin : output_neurons
    if_neuron 
    #(
        .THRESH(THRESH),
        .RESET(RESET),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_INPUTS),
        .WEIGHT_ADDR_WIDTH(WEIGHT_ADDR_WIDTH)
        //.WEIGHT_FILENAME({i+48,".txt"})
        // .WEIGHT_FILENAME("neuron.txt")
    )
    if_neuron (
        .rst(neuron_rst[i]),
        .spike_in(spike_in),
        .spike_out(spike_out_i[i]),
        .mem_clk(clk),
        .mem_addr(mem_addr_i),
        .mem_din(mem_din),
        .mem_wen(neuron_wen[i]),
        .mem_dout(neuron_mem_dout[i])
    );
end 
endgenerate

if_layer_controller
#(
    .REFRAC(REFRAC),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_NEURONS(NUM_NEURONS)
)
if_layer_controller
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_out_i),
    .neuron_rst(neuron_rst)
);

endmodule