`timescale 1ns / 1ps

module spike_accumulator
# (
DATA_WIDTH = 32
)
(
    input spike_in,
    input [DATA_WIDTH-1:0] spike_weight,
    input rst,
    output reg [2*DATA_WIDTH-1:0] dout
);

always @(posedge spike_in, posedge rst)
begin
    if (rst)
        dout <= 0;
    else
        dout <= dout + spike_weight;
end

endmodule