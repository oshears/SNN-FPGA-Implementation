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
    output reg [NUM_NEURONS-1:0] neuron_rst = 0
);

genvar i;
generate
    for (i = 0; i < NUM_NEURONS; i = i + 1) begin : spike_resets
        always @(posedge clk, posedge rst) begin
            if (rst)
                neuron_rst[i] = 1;
            else
                neuron_rst[i] = spike_in[i];
        end
    end
endgenerate

endmodule