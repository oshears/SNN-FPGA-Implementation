`timescale 1ns / 1ps

module if_network_tb;

reg clk = 0;
reg rst = 0;
reg [0:0] spike_in = 0;

wire spike_out;

if_neuron 
#(
    .threshold_potential(10),
    .reset_potential(0),
    .weight_size(32),
    .num_inputs(1),
    .weight_filename("neuron.txt")
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