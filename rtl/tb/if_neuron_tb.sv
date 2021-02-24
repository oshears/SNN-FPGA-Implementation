`timescale 1ns / 1ps

module if_neuron_tb;

localparam NUM_INPUTS = 4;
localparam NUM_OUTPUTS = 1;
localparam THRESH = 15;
localparam RESET = 0;
localparam REFRAC = 5;
localparam WEIGHT_SIZE = 32;

reg rst = 0;
reg [NUM_INPUTS - 1:0] spike_in = 0;

wire spike_out;

integer i = 0;

if_neuron 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .WEIGHT_FILENAME("neuron.txt")
)
uut
(
    .rst(rst),
    .spike_out(spike_out),
    .spike_in(spike_in)
);

task WAIT( input [31:0] timesteps);
    integer i;
    begin
        for (i = 0; i < timesteps; i = i + 1)
            #1;
    end
endtask


initial begin
    rst = 1;
    WAIT(1);
    rst = 0;
    
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