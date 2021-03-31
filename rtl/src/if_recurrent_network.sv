`timescale 1ns / 1ps
module if_recurrent_network
#(
    parameter WEIGHT_SIZE=32,
    parameter [2 * WEIGHT_SIZE - 1:0] THRESH=15,
    parameter [2 * WEIGHT_SIZE - 1:0] RESET=0,
    parameter [2 * WEIGHT_SIZE - 1:0] REFRAC=5,
    parameter NUM_INPUTS=4,
    parameter NUM_LAYERS=1,
    parameter [31 : 0]  NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0] = {32'h1},
    parameter LAYER_ADDR_WIDTH = 32,
    parameter NEURON_ADDR_WIDTH = 28,
    parameter WEIGHT_ADDR_WIDTH = 10
)
(
    input  wire clk,
    input  wire rst,
    input  wire [NUM_INPUTS-1:0] spike_in,
    output wire [NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1] - 1 : 0] spike_out,

    // weight memory access
    input  wire [LAYER_ADDR_WIDTH - 1 : 0] mem_addr,
    input  wire [WEIGHT_SIZE - 1 : 0] mem_din,
    input  wire mem_wen,
    output wire [WEIGHT_SIZE - 1 : 0] mem_dout
);

localparam NUM_LAYER_INPUTS = NUM_HIDDEN_LAYER_NEURONS[0] + NUM_INPUTS;

wire [NUM_LAYER_INPUTS - 1 : 0] layer_spikes = {spike_out,spike_in};

wire [LAYER_ADDR_WIDTH - NEURON_ADDR_WIDTH - WEIGHT_ADDR_WIDTH:0] layer_mem_sel;
assign layer_mem_sel = mem_addr[LAYER_ADDR_WIDTH - 1:NEURON_ADDR_WIDTH];
wire [NEURON_ADDR_WIDTH-1:0] mem_addr_i;
assign mem_addr_i = mem_addr[NEURON_ADDR_WIDTH-1:0]; 

if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_LAYER_INPUTS),
    .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[0]),
    .WEIGHT_ADDR_WIDTH(WEIGHT_ADDR_WIDTH),
    .NEURON_ADDR_WIDTH(NEURON_ADDR_WIDTH)
)
hidden_layer_in (
    .clk(clk),
    .rst(rst),
    .spike_in(layer_spikes),
    .spike_out(spike_out),
    .mem_addr(mem_addr_i),
    .mem_din(mem_din),
    .mem_wen(mem_wen),
    .mem_dout(mem_dout)
);


endmodule