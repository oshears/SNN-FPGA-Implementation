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
    output [NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1] - 1 : 0] spike_out,

    // weight memory access
    input [31 : 0] mem_addr,
    input [WEIGHT_SIZE - 1 : 0] mem_din,
    input mem_wen,
    output [WEIGHT_SIZE - 1 : 0] mem_dout
);


wire [3:0] layer_mem_sel;
assign layer_mem_sel = mem_addr[31:28];
wire [27:0] mem_addr_i;
assign mem_addr_i = mem_addr[27:0]; 

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
        .spike_out(spike_out),
        .mem_addr(mem_addr_i),
        .mem_din(mem_din),
        .mem_wen(mem_wen),
        .mem_dout(mem_dout)
    );

end
else if (NUM_LAYERS == 2) begin

wire [NUM_HIDDEN_LAYER_NEURONS[0] - 1 : 0] hidden_layer_connections; 

wire layer_0_wen;
wire layer_1_wen;

wire [WEIGHT_SIZE - 1 : 0] layer_0_dout;
wire [WEIGHT_SIZE - 1 : 0] layer_1_dout;

assign layer_0_wen = (layer_mem_sel == 0) ? mem_wen : 0;
assign layer_1_wen = (layer_mem_sel == 1) ? mem_wen : 0;
assign mem_dout = (layer_mem_sel == 0) ? layer_0_dout : layer_1_dout;

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
    .spike_out(hidden_layer_connections),
    .mem_addr(mem_addr_i),
    .mem_din(mem_din),
    .mem_wen(layer_0_wen),
    .mem_dout(layer_0_dout)
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
    .spike_out(spike_out),
    .mem_addr(mem_addr_i),
    .mem_din(mem_din),
    .mem_wen(layer_1_wen),
    .mem_dout(layer_1_dout)
);

end
else if (NUM_LAYERS > 2) begin

wire [NUM_LAYERS - 1 : 0] layer_wen;

wire [WEIGHT_SIZE - 1 : 0] layer_mem_dout [NUM_LAYERS - 1 : 0];

reg [WEIGHT_SIZE - 1 : 0] mem_dout_i = 0;

integer mem_dout_sel = 0;

for (i = 0; i < NUM_LAYERS; i = i + 1) begin
    assign layer_wen[i] = (layer_mem_sel == i) ? mem_wen : 0;
end

always_comb begin : mem_dout_block
    mem_dout_i = layer_mem_dout[0]; 
    for (mem_dout_sel = 0; mem_dout_sel < NUM_LAYERS; mem_dout_sel = mem_dout_sel + 1) begin
        if (layer_mem_sel == mem_dout_sel) begin
            mem_dout_i = layer_mem_dout[mem_dout_sel];
        end
    end
end

assign mem_dout = mem_dout_i;


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
    .spike_out(hidden_layer_connections[0].hidden_layer_i_connections),
    .mem_addr(mem_addr_i),
    .mem_din(mem_din),
    .mem_wen(layer_wen[0]),
    .mem_dout(layer_mem_dout[0])
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
        .spike_out(hidden_layer_connections[i + 1].hidden_layer_i_connections),
        .mem_addr(mem_addr_i),
        .mem_din(mem_din),
        .mem_wen(layer_wen[i+1]),
        .mem_dout(layer_mem_dout[i+1])
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
    .spike_out(spike_out),
    .mem_addr(mem_addr_i),
    .mem_din(mem_din),
    .mem_wen(layer_wen[NUM_LAYERS - 1]),
    .mem_dout(layer_mem_dout[NUM_LAYERS - 1])
);

end

endgenerate

endmodule