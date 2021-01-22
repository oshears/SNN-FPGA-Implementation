`timescale 1ns / 1ps

module if_network_test_tb;

localparam NUM_INPUTS = 4;
localparam NUM_OUTPUTS = 1;
localparam THRESH = 15;
localparam RESET = 0;
localparam REFRAC = 5;
localparam WEIGHT_SIZE = 32;

reg clk = 0;
reg rst = 0;
reg [NUM_INPUTS-1:0] spike_in = 0;

wire [NUM_OUTPUTS-1:0] spike_out;

integer i = 0;
integer j = 0;

if_network 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_OUTPUTS(NUM_OUTPUTS)
)
uut
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(spike_out)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

initial begin
    rst = 1;
    #10;
    rst = 0;
    
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in = 0;
        spike_in[i] = 1;
        #20;
    end

    $finish;
end

endmodule;