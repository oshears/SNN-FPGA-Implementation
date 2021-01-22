`timescale 1ns / 1ps

module if_network_tb;

integer NUM_INPUTS = 4;
integer NUM_OUTPUTS = 4;
integer THRESH = 15;
integer RESET = 0;
integer WEIGHT_SIZE = 4;

reg clk = 0;
reg rst = 0;
reg [3:0] spike_in = 0;

wire [3:0] spike_out;

integer i = 0;
integer j = 0;

if_network 
#(
    .THRESH(THRESH),
    .RESET(RESET),
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
    
    for(i = 0; i < NUM_INPUTS) begin
        spike_in = 0;
        spike_in[i] = 1;
        #20;
    end

    $finish;
end

endmodule;