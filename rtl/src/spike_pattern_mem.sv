`timescale 1ns / 1ps

module spike_pattern_mem
# (
    NUM_SPIKES = 100,
    TIMESTEP_ADDR_WIDTH = 8,
    SPIKE_PATTERN_BATCH_ADDR_WIDTH = 6,
    SPIKES_PER_BATCH = 32
    // NUM_RAMS = $ceil(NUM_SPIKES / 32)  
)
(
    input clk,
    input [TIMESTEP_ADDR_WIDTH - 1 : 0] mem_addr,
    input mem_wen,
    input [SPIKE_PATTERN_BATCH_ADDR_WIDTH - 1 : 0] batch_sel,
    input [SPIKES_PER_BATCH - 1 : 0] mem_data_in,
    output reg [SPIKES_PER_BATCH - 1 : 0] mem_data_out,
    output reg [NUM_SPIKES - 1 : 0] spikes
);

// localparam NUM_RAMS = $clog(NUM_SPIKES);

reg mem [2**TIMESTEP_ADDR_WIDTH - 1:0][NUM_SPIKES - 1 : 0];


always @(posedge clk)
begin
    integer batch_index = 0;
    integer spike_index = 0;
    integer data_in_index = 0;


    mem_data_out = 0;
    spikes = 0;

    if (mem_wen) begin
        for(batch_index = 0; batch_index < 2**SPIKE_PATTERN_BATCH_ADDR_WIDTH; batch_index = batch_index + 1) begin
            if (batch_sel == batch_index) begin
                data_in_index = 0;
                for(spike_index = batch_index * SPIKES_PER_BATCH; spike_index < (batch_index + 1) * SPIKES_PER_BATCH && spike_index < NUM_SPIKES; spike_index++) begin
                    mem[mem_addr][spike_index] <= mem_data_in[data_in_index];
                    data_in_index++;                    
                end
            end
        end
    end
    
    for(batch_index = 0; batch_index < 2**SPIKE_PATTERN_BATCH_ADDR_WIDTH; batch_index = batch_index + 1) begin
        if (batch_sel == batch_index) begin
            data_in_index = 0;
            for(spike_index = batch_index * SPIKES_PER_BATCH; spike_index < (batch_index + 1) * SPIKES_PER_BATCH && spike_index < NUM_SPIKES; spike_index++) begin
                mem_data_out[data_in_index] <= mem[mem_addr][spike_index];
                data_in_index++;
            end
        end
    end

    for(spike_index = 0; spike_index < NUM_SPIKES; spike_index = spike_index + 1) begin
        spikes[spike_index] = mem[mem_addr][spike_index];
    end
    
    
end

initial begin
    integer timestep = 0;
    integer spike_index = 0;

    for (timestep = 0; timestep < 2**TIMESTEP_ADDR_WIDTH; timestep++) begin
        for(spike_index = 0; spike_index < NUM_SPIKES; spike_index++) begin
            mem[timestep][spike_index] = 0;
        end
    end
end

endmodule