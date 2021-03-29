`timescale 1ns / 1ps

module if_recurrent_network_tb;

localparam WEIGHT_SIZE=32;
localparam [2 * WEIGHT_SIZE - 1:0] THRESH=15;
localparam [2 * WEIGHT_SIZE - 1:0] RESET=0;
localparam [2 * WEIGHT_SIZE - 1:0] REFRAC=5;
localparam NUM_INPUTS=4;
localparam NUM_LAYERS=1;
localparam [31 : 0]  NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0] = {32'h4};
localparam LAYER_ADDR_WIDTH = 32;
localparam NEURON_ADDR_WIDTH = 28;
localparam WEIGHT_ADDR_WIDTH = 10;

localparam NUM_LAYER_INPUTS = NUM_INPUTS + NUM_HIDDEN_LAYER_NEURONS[0];
localparam NUM_NEURONS = NUM_HIDDEN_LAYER_NEURONS[0];

reg clk = 0;
reg rst = 0;
reg [NUM_INPUTS-1:0] spike_in = 0;

wire [NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1] - 1 : 0] spike_out;

reg [LAYER_ADDR_WIDTH - 1:0] mem_addr = 0;
reg [WEIGHT_SIZE - 1:0] mem_din = 0;
reg mem_wen = 0;

wire [WEIGHT_SIZE - 1 : 0] mem_dout;

if_network 
#(
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_LAYERS(NUM_LAYERS),
    .NUM_HIDDEN_LAYER_NEURONS(NUM_HIDDEN_LAYER_NEURONS),
    .LAYER_ADDR_WIDTH(LAYER_ADDR_WIDTH),
    .NEURON_ADDR_WIDTH(NEURON_ADDR_WIDTH),
    .WEIGHT_ADDR_WIDTH(WEIGHT_ADDR_WIDTH)
)
uut
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(spike_out),
    .mem_addr(mem_addr),
    .mem_din(mem_din),
    .mem_wen(mem_wen),
    .mem_dout(mem_dout)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

task WAIT( input [31:0] timesteps);
    integer i;
    begin
        for (i = 0; i < timesteps; i = i + 1)
            #1;
    end
endtask


initial begin
    static integer i = 0;
    static integer j = 0;

    rst = 1;
    #10;
    rst = 0;

    // Setup Weights
    for (j = 0; j < NUM_NEURONS; j++) begin
        for (i = 0; i < NUM_LAYER_INPUTS; i++) begin
            
            mem_addr = {4'h0,j[17:0],i[WEIGHT_ADDR_WIDTH - 1:0]};
            
            if (i % 2 == 0)
                mem_din = (-1) * (i + 1);
            else
                mem_din = (i + 1);

            mem_wen = 1;
            
            @(posedge clk);
            
            mem_wen = 0;
        end
    end
    
    // Sequential Spikes
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in[i] = 1;
        WAIT(i+1);
        spike_in[i] = 0;
        WAIT(i+1);
    end

    // Concurrent Spikes
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in = ~spike_in;
        WAIT(i+1);
        spike_in = ~spike_in;
        WAIT(i+1);
    end

    $finish;
end

endmodule