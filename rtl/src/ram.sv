`timescale 1ns / 1ps

module ram
# (
ADDR_WIDTH = 20,
DATA_WIDTH = 32
)
(
    input clk,
    input wen,
    input [ADDR_WIDTH - 1 : 0] addr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout = 0
);

reg [DATA_WIDTH - 1 : 0] mem [2**ADDR_WIDTH - 1:0];

integer i = 0;

always @(posedge clk)
begin
    if (wen)
        mem[addr] <= din;

    dout = mem[addr];
end

initial begin
    for (i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
        mem[i] = 0;
    end
end

endmodule