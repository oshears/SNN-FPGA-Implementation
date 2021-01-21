`timescale 1ns / 1ps

module if_neuron_tb;

reg clk;
reg rst;
reg [0:0] spike_in;

wire spike_out;

if_neuron 
#(
    .threshold_potential(10),
    .reset_potential(0),
    .weight_size(4),
    .num_inputs(1)
)
if_neuron
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
    #100;
    spike_in[0] = 1;
    #100;
    $finish;
end

endmodule;