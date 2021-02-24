`timescale 1ns / 1ps

module if_network_tb;

localparam NUM_INPUTS = 784;
localparam NUM_OUTPUTS = 100;
localparam THRESH = 25769803776;
localparam RESET = 10737418240;
localparam WEIGHT_SIZE = 4;
localparam REFRAC = 5;

reg rst = 0;
reg [NUM_INPUTS-1:0] spike_in = 0;

wire [NUM_OUTPUTS-1:0] spike_out;

integer i = 0;
integer j = 0;

if_network 
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_OUTPUTS(NUM_OUTPUTS)
)
uut
(
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(spike_out)
);


initial begin
    rst = 1;
    #10;
    rst = 0;
    
    for(i = 0; i < NUM_INPUTS; i = i + 1) begin
        spike_in = 0;
        spike_in[i] = 1;
        #20;
    end

    $finish;
end

endmodule