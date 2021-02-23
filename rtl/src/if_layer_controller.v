`timescale 1ns / 1ps
module if_layer_controller
#(
    parameter REFRAC=5,
    parameter NUM_INPUTS=4,
    parameter NUM_OUTPUTS=1
)
(
    input clk,
    input rst,
    input [NUM_OUTPUTS-1:0] spike_in,
    output reg [NUM_OUTPUTS-1:0] neuron_rst
);

genvar i;
generate
    for (i=0; i<NUM_OUTPUTS; i=i+1) begin : spike_resets
        always @(posedge clk, posedge rst) begin
            if (rst)
                neuron_rst = 1;
            else
                neuron_rst = spike_in;
        end
    end
endgenerate

endmodule