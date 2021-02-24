`timescale 1ns / 1ps

module snn_fpga_top_tb;

reg clk = 0;
reg rst = 0;
reg spike_in = 0;

wire spike_out;

integer i = 0;

snn_fpga_top  uut
(
    .clk(clk),
    .rst(rst),
    .spike_in(spike_in),
    .spike_out(spike_out)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

task WAIT( input [31:0] timesteps);
    integer i;
    begin
        for (i = 0; i < timesteps; i = i + 1)
            #1;
    end
endtask


initial begin
    rst = 1;
    #10;
    rst = 0;
    
    // Sequential Spikes
    for(i = 0; i < 10; i = i + 1) begin
        spike_in = 1;
        WAIT(i+1);
        spike_in = 0;
        WAIT(i+1);
    end

    $finish;
end

endmodule