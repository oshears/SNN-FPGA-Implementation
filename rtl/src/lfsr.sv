`timescale 1ns / 1ps

module lfsr
# (
DATA_WIDTH = 32,
SEED = 32'hABCD_1234
)
(
    input clk,
    input rst,
    output reg [DATA_WIDTH-1:0] dout = SEED
);

localparam HALF_WIDTH = (DATA_WIDTH + 1)/2;

// reg [DATA_WIDTH - 1 : 0] dout_next = SEED;

wire feedback = dout[DATA_WIDTH - 1] ^ dout[HALF_WIDTH] ^ dout[0];

always @(posedge clk, posedge rst)
begin
    if (rst)
        dout = SEED;
    else
        dout <= {feedback,dout[DATA_WIDTH - 1 : 1]};
end

endmodule