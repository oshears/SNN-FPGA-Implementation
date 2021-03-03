////////// Asynchronous Spike Counter ///////////
`timescale 1ns / 1ps
module spike_counter
#(
    parameter NUM_INPUTS=1,
    parameter COUNTER_SIZE=4
)
(
    input wire [NUM_INPUTS-1:0] spike_in,
    input wire rst,
    output wire [COUNTER_SIZE - 1 : 0] counter_out [NUM_INPUTS - 1 : 0]
);

genvar i;
generate
for (i=0; i<NUM_INPUTS; i=i+1) begin : spike_counters
    counter 
    #(
        .DATA_WIDTH(COUNTER_SIZE)
    )
    counter (
        .clk(spike_in[i]),
        .rst(rst),
        .en(spike_in[i]),
        .dout(counter_out[i])
    );
end 
endgenerate


endmodule