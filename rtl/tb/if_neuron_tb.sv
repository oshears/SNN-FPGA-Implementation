`timescale 1ns / 1ps

module if_neuron_tb;

localparam WEIGHT_SIZE = 32;
localparam THRESH = 15;
localparam RESET = 0;
localparam NUM_INPUTS = 4;
localparam WEIGHT_ADDR_WIDTH = 2;

reg rst = 0;
reg [NUM_INPUTS - 1:0] spike_in = 0;

reg mem_clk = 0;
reg [WEIGHT_ADDR_WIDTH - 1:0] mem_addr = 0;
reg [WEIGHT_SIZE - 1:0] mem_din = 0;
reg mem_wen = 0;

wire spike_out;

wire [WEIGHT_SIZE - 1 : 0] mem_dout;

integer i = 0;

if_neuron 
#(
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .THRESH(THRESH),
    .RESET(RESET),
    .NUM_INPUTS(NUM_INPUTS),
    .WEIGHT_ADDR_WIDTH(WEIGHT_ADDR_WIDTH)
)
uut
(
    .rst(rst),
    .spike_out(spike_out),
    .spike_in(spike_in),
    // weight memory access
    .mem_clk(mem_clk),
    .mem_addr(mem_addr),
    .mem_din(mem_din),
    .mem_wen(mem_wen),
    .mem_dout(mem_dout)
);

task WAIT( input [31:0] timesteps);
    integer i;
    begin
        for (i = 0; i < timesteps; i = i + 1)
            @(posedge mem_clk);
    end
endtask

always begin
    mem_clk = #1 ~mem_clk;
end


initial begin
    rst = 1;
    WAIT(1);
    rst = 0;

    // Setup Weights
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        mem_addr = i[1:0];
        if (i % 2 == 0)
            mem_din = (-1) * (i + 1);
        else
            mem_din = (i + 1);
        mem_wen = 1;
        @(posedge mem_clk);
        mem_wen = 0;
    end
    
    // Sequential Spikes
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in[i] = 1;
        WAIT(i+1);
        spike_in[i] = 0;
        WAIT(i+1);
    end

    rst = 1;
    WAIT(1);
    rst = 0;

    // Concurrent Spikes
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in = ~spike_in;
        WAIT(i+1);
        spike_in = ~spike_in;
        WAIT(i+1);
    end

    $finish;
end

endmodule