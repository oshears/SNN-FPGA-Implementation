`timescale 1ns / 1ps

module register
# (
DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

always @(posedge clk, posedge rst)
begin
    if (rst)
        dout <= 0;
    else
        dout <= din;
end

endmodule