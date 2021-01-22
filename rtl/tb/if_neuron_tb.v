`timescale 1ns / 1ps

module if_neuron_tb;

reg clk = 0;
reg rst = 0;
reg [0:0] spike_in = 0;

wire spike_out;

if_neuron 
#(
    .THRESH(10),
    .RESET(0),
    .WEIGHT_SIZE(32),
    .NUM_INPUTS(1),
    .WEIGHT_FILENAME("neuron.txt")
)
uut
(
    .clk(clk),
    .rst(rst),
    .spike_out(spike_out),
    .spike_in(spike_in)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

initial begin
    rst = 1;
    #10;
    rst = 0;
    #100;
    spike_in[0] = 1;
    #100;
    $finish;
end

endmodule;