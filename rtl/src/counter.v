`timescale 1ns / 1ps

module counter
# (
DATA_WIDTH = 32
)
(
    input clk,
    input en,
    input rst,
    output reg [DATA_WIDTH - 1 : 0] dout
);

always @(posedge clk, posedge rst)
begin
    if (rst)
        dout <= 0;
    else if (en)
        dout <= dout + 1;
end

endmodule