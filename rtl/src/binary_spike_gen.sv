`timescale 1ns / 1ps
module binary_spike_gen
#(
    parameter NUM_OUTPUTS=1,
    parameter SPIKE_PERIOD=1
)
(
    input clk,
    input rst,
    input [NUM_OUTPUTS-1:0] spike_en,
    output [NUM_OUTPUTS-1:0] spike_out
);

wire [NUM_OUTPUTS - 1 : 0] counter_out;

genvar i;
generate
for (i=0; i<NUM_OUTPUTS; i=i+1) begin : output_spikes
    counter 
    #(
        .DATA_WIDTH(1)
    )
    counter (
        .clk(clk),
        .rst(rst),
        .en(1'b1),
        .dout(counter_out[i])
    );
    assign spike_out[i] = (spike_en) ? counter_out[i] : 1'b0;
end 
endgenerate


endmodule