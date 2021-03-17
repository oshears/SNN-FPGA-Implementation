`timescale 1ns / 1ps

module bernoulli_spike_generator
# (
    NUM_SPIKES = 32,
    ADDR_WIDTH = 32,
    DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input en,
    input [ADDR_WIDTH - 1 : 0] mem_addr,
    input mem_wen,
    input [DATA_WIDTH - 1 : 0] mem_data_in,
    output reg [DATA_WIDTH - 1 : 0] mem_data_out,
    output [NUM_SPIKES - 1 : 0] spikes
);

integer mem_iter = 0;

reg count = 0;

wire [DATA_WIDTH - 1 : 0] lfsr_out;

reg [DATA_WIDTH - 1 : 0] mem [2**$clog2(NUM_SPIKES) - 1 : 0];

genvar i;
generate
    for(i = 0; i < NUM_SPIKES; i = i + 1) begin : spike_outputs
        
        assign spikes[i] = (mem[i] > lfsr_out && count && en) ? 1 : 0;

    end
endgenerate


always @(posedge clk)
begin
    if (mem_wen)
        mem[mem_addr] <= mem_data_in;
    mem_data_out = mem[mem_addr];
end

initial begin
    for (mem_iter = 0; mem_iter < ADDR_WIDTH; mem_iter = mem_iter + 1) begin
        mem[mem_iter] = 32'h7FFF_FFFF;
        // mem[mem_iter] = {mem_iter[4:0],27'hFFF_FFFF};
    end
end

always @(posedge clk, posedge rst) begin
    if (rst)
        count = 0;
    else
        count = ~count;
end

lfsr
# (
    .DATA_WIDTH(DATA_WIDTH)
)
lfsr
(
    .clk(clk),
    .rst(rst),
    .dout(lfsr_out)
);



endmodule