`timescale 1ns / 1ps

module if_neuron_tb;

reg clk;
reg rst;
wire spike_out;

if_neuron if_neuron(
    .clk(clk),
    .rst(rst),
    .spike_out(spike_out)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

endmodule;