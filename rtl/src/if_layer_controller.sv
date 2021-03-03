`timescale 1ns / 1ps
module if_layer_controller
#(
    parameter REFRAC=5,
    parameter NUM_INPUTS=4,
    parameter NUM_NEURONS=1
)
(
    input clk,
    input rst,
    input [NUM_NEURONS-1:0] spike_in,
    output [NUM_NEURONS-1:0] neuron_rst
);

reg [NUM_NEURONS-1:0] neuron_rst_i = 0;

genvar i;
generate
    for (i = 0; i < NUM_NEURONS; i = i + 1) begin : spike_resets
        always @(posedge clk, posedge rst) begin
            if (rst)
                neuron_rst_i[i] = 1;
            else if (neuron_rst)
                neuron_rst_i[i] = 0;
            else
                neuron_rst_i[i] = spike_in[i];
        end
    end
endgenerate

assign neuron_rst = neuron_rst_i;

endmodule