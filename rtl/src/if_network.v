`timescale 1ns / 1ps
module if_network
#(
    parameter THRESH=15,
    parameter RESET=0,
    parameter REFRAC=5,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_OUTPUTS=1,
    parameter NUM_LAYERS=1,
    parameter NUM_HIDDEN_LAYER_NEURONS=4
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output [NUM_OUTPUTS-1:0] spike_out
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
        .NUM_OUTPUTS(NUM_HIDDEN_LAYER_NEURONS)
    )
    hidden_layer_in (
        .clk(clk),
        .rst(rst),
        .spike_in(spike_in),
        .spike_out(spike_out)
    );

end
else if (NUM_LAYERS == 2) begin

wire [NUM_HIDDEN_LAYER_NEURONS - 1 : 0] hidden_layer_connections; 

// Hidden Layer 1
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_OUTPUTS(NUM_HIDDEN_LAYER_NEURONS)
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
    .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS),
    .NUM_OUTPUTS(NUM_OUTPUTS)
)
hidden_layer_out (
    .clk(clk),
    .rst(rst),
    .spike_in(hidden_layer_connections),
    .spike_out(spike_out)
);

end
else if (NUM_LAYERS > 2) begin

wire [((NUM_LAYERS+2) * NUM_HIDDEN_LAYER_NEURONS) - 1 : 0] hidden_layer_connections; 

// Hidden Layer 1
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_OUTPUTS(NUM_HIDDEN_LAYER_NEURONS)
)
hidden_layer_in (
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(hidden_layer_connections[NUM_HIDDEN_LAYER_NEURONS - 1 : 0])
);

for (i=0; i<NUM_LAYERS - 2; i=i+1) begin : output_layers
    if_layer 
    #(
        .THRESH(THRESH),
        .RESET(RESET),
        .REFRAC(REFRAC),
        .WEIGHT_SIZE(WEIGHT_SIZE),
        .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS),
        .NUM_OUTPUTS(NUM_HIDDEN_LAYER_NEURONS)
    )
    hidden_layer (
        .clk(clk),
        .rst(rst),
        .spike_in(hidden_layer_connections[((i + 1) * NUM_HIDDEN_LAYER_NEURONS) - 1 : (i * NUM_HIDDEN_LAYER_NEURONS)]),
        .spike_out(hidden_layer_connections[((i + 2) * NUM_HIDDEN_LAYER_NEURONS) - 1 : ((i + 1) * NUM_HIDDEN_LAYER_NEURONS)])
    );
end 

// Output Layer
if_layer 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_HIDDEN_LAYER_NEURONS),
    .NUM_OUTPUTS(NUM_OUTPUTS)
)
hidden_layer_out (
    .clk(clk),
    .rst(rst),
    .spike_in(hidden_layer_connections[((NUM_LAYERS + 1) * NUM_HIDDEN_LAYER_NEURONS) - 1 : (NUM_LAYERS * NUM_HIDDEN_LAYER_NEURONS)]),
    .spike_out(spike_out)
);

end

endgenerate

endmodule