`timescale 1ns / 1ps
module if_network
#(
    parameter THRESH=15,
    parameter RESET=0,
    parameter REFRAC=5,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_LAYERS=1,
    parameter [31 : 0]  NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0] = {32'h1}
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output [NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1] - 1 : 0] spike_out
);

genvar i;


generate 
    
if (NUM_LAYERS == 1) begin

    if_layer 
    #(
        .THRESH(THRESH),
        .RESET(RESET),
        .REFRAC(REFRAC),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_INPUTS),
        .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[0])
    )
    hidden_layer_in (
        .clk(clk),
        .rst(rst),
        .spike_in(spike_in),
        .spike_out(spike_out)
    );

end
else if (NUM_LAYERS == 2) begin

wire [NUM_HIDDEN_LAYER_NEURONS[0] - 1 : 0] hidden_layer_connections; 

// Hidden Layer 1
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[0])
)
hidden_layer_in (
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(hidden_layer_connections)
);

// Output Layer
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS[0]),
    .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[1])
)
hidden_layer_out (
    .clk(clk),
    .rst(rst),
    .spike_in(hidden_layer_connections),
    .spike_out(spike_out)
);

end
else if (NUM_LAYERS > 2) begin

// Hidden Layer 1
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[0])
)
hidden_layer_in (
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(hidden_layer_connections[0].hidden_layer_i_connections)
);

for (i=0; i < NUM_LAYERS - 1; i=i+1) begin : hidden_layer_connections
    wire [NUM_HIDDEN_LAYER_NEURONS[i] - 1 : 0] hidden_layer_i_connections; 
end 

for (i=0; i<NUM_LAYERS - 2; i=i+1) begin : hidden_layers

    if_layer 
    #(
        .THRESH(THRESH),
        .RESET(RESET),
        .REFRAC(REFRAC),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS[i]),
        .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[i + 1])
    )
    hidden_layer (
        .clk(clk),
        .rst(rst),
        .spike_in(hidden_layer_connections[i].hidden_layer_i_connections),
        .spike_out(hidden_layer_connections[i + 1].hidden_layer_i_connections)
    );
end 

// Output Layer
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 2]),
    .NUM_NEURONS(NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1])
)
hidden_layer_out (
    .clk(clk),
    .rst(rst),
    .spike_in(hidden_layer_connections[NUM_LAYERS - 2].hidden_layer_i_connections),
    .spike_out(spike_out)
);

end

endgenerate

endmodule