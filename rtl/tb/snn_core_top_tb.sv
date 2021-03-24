`timescale 1ns / 1ps
module snn_core_top_tb;

localparam SIM_TIME = 100;

localparam C_S_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 16;
localparam [61:0] THRESH = 64'h6_0000_0000;
localparam [61:0] RESET =  64'h2_8000_0000;
localparam [61:0] REFRAC = 0;
localparam WEIGHT_SIZE = 32;
localparam NUM_INPUTS = 784;
localparam NUM_LAYERS = 1;
localparam [31 : 0] NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0]  = {100};
localparam MAX_TIMESTEPS_BITS = $clog2(SIM_TIME);
localparam SPIKE_PATTERN_BATCH_ADDR_WIDTH = 6; //2**6 batches of input spikes
localparam SPIKES_PER_BATCH = 32; //32 input spikes per batch
localparam OUTPUT_SPIKE_ADDR_BITS = $clog2(NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1]);

localparam NUM_OUTPUTS = NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1];

localparam CTRL_REG = 16'h0000;
localparam SIM_TIME_REG = 16'h0004;
localparam MEM_CFG_REG = 16'h0008;
localparam DEBUG_REG = 16'h000C;
localparam EXT_MEM_OFFSET = 16'h0100;

localparam real NUM_INPUTS_REAL = NUM_INPUTS;
localparam integer NUM_INPUT_SPIKE_BATCHES = $ceil(NUM_INPUTS_REAL / SPIKES_PER_BATCH);

reg S_AXI_ACLK = 0;
reg S_AXI_ARESETN = 0;
reg [C_S_AXI_ADDR_WIDTH - 1 : 0] S_AXI_AWADDR = 0; 
reg S_AXI_AWVALID = 0;
reg [C_S_AXI_ADDR_WIDTH - 1 : 0] S_AXI_ARADDR = 0; 
reg S_AXI_ARVALID = 0;
reg [C_S_AXI_DATA_WIDTH - 1 : 0] S_AXI_WDATA = 0;  
reg [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB = 0;  
reg S_AXI_WVALID = 0; 
reg S_AXI_RREADY = 0; 
reg S_AXI_BREADY = 0; 
wire S_AXI_AWREADY; 
wire S_AXI_ARREADY; 
wire S_AXI_WREADY;  
wire [C_S_AXI_DATA_WIDTH - 1 :0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;  
wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;  
wire busy;

integer i = 0;
integer j = 0;
integer k = 0;
integer weight_counter = 1;
integer num_synapses = NUM_INPUTS;

snn_core_top
#(
    .C_S_AXI_ACLK_FREQ_HZ(C_S_AXI_ACLK_FREQ_HZ),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_LAYERS(NUM_LAYERS),
    .NUM_HIDDEN_LAYER_NEURONS(NUM_HIDDEN_LAYER_NEURONS),
    .MAX_TIMESTEPS_BITS(MAX_TIMESTEPS_BITS),
    .SPIKE_PATTERN_BATCH_ADDR_WIDTH(SPIKE_PATTERN_BATCH_ADDR_WIDTH),
    .SPIKES_PER_BATCH(SPIKES_PER_BATCH),
    .OUTPUT_SPIKE_ADDR_BITS(OUTPUT_SPIKE_ADDR_BITS)
)
uut
(
    // axi_cfg_regs
    .S_AXI_ACLK(S_AXI_ACLK),     
    .S_AXI_ARESETN(S_AXI_ARESETN),  
    .S_AXI_AWADDR(S_AXI_AWADDR),   
    .S_AXI_AWVALID(S_AXI_AWVALID),  
    .S_AXI_AWREADY(S_AXI_AWREADY),  
    .S_AXI_ARADDR(S_AXI_ARADDR),   
    .S_AXI_ARVALID(S_AXI_ARVALID),  
    .S_AXI_ARREADY(S_AXI_ARREADY),  
    .S_AXI_WDATA(S_AXI_WDATA),    
    .S_AXI_WSTRB(S_AXI_WSTRB),    
    .S_AXI_WVALID(S_AXI_WVALID),   
    .S_AXI_WREADY(S_AXI_WREADY),   
    .S_AXI_RDATA(S_AXI_RDATA),    
    .S_AXI_RRESP(S_AXI_RRESP),    
    .S_AXI_RVALID(S_AXI_RVALID),   
    .S_AXI_RREADY(S_AXI_RREADY),   
    .S_AXI_BRESP(S_AXI_BRESP),    
    .S_AXI_BVALID(S_AXI_BVALID),   
    .S_AXI_BREADY(S_AXI_BREADY),
    .busy(busy)
);

initial begin
S_AXI_ACLK = 0;
forever #10 S_AXI_ACLK = ~S_AXI_ACLK;
end 

task AXI_WRITE( input [31:0] WRITE_ADDR, input [31:0] WRITE_DATA );
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_AWADDR = WRITE_ADDR;
        S_AXI_AWVALID = 1'b1;
        S_AXI_WVALID = 1;
        S_AXI_WDATA = WRITE_DATA;
        S_AXI_BREADY = 1'b1;
        @(posedge S_AXI_WREADY);
        @(posedge S_AXI_ACLK);
        S_AXI_WVALID = 0;
        S_AXI_AWVALID = 0;
        S_AXI_BREADY = 1'b0;
        @(posedge S_AXI_ACLK);
        S_AXI_AWADDR = 32'h0;
        S_AXI_WDATA = 32'h0;
        $display("%t: Wrote Data: %h",$time,WRITE_DATA);
    end
endtask

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA = 32'h0, input [31:0] MASK_DATA = 32'h0, input COMPARE=0);
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_ARADDR = READ_ADDR;
        S_AXI_ARVALID = 1'b1;
        @(posedge S_AXI_RVALID);
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1'b1;
        if (((EXPECT_DATA | MASK_DATA) == (S_AXI_RDATA | MASK_DATA)) || ~COMPARE) 
            $display("%t: Read Data: %h",$time,S_AXI_RDATA);
        else 
            $display("%t: ERROR: %h != %h",$time,S_AXI_RDATA,EXPECT_DATA);
        @(posedge S_AXI_ACLK);
        S_AXI_RREADY = 0;
        S_AXI_ARADDR = 32'h0;
    end
endtask

task WAIT( input [31:0] cycles);
    integer i;
    begin
        for (i = 0; i < cycles; i = i + 1)
            @(posedge S_AXI_ACLK);
    end
endtask


initial begin
    integer input_weight_file;
    integer weight_cntr;
    string weight_file_num_str;
    reg [31:0] weight_value;
    integer input_pattern_file;
    integer input_cntr;
    integer timestep_cntr;
    string spike_value_str;
    bit[NUM_INPUT_SPIKE_BATCHES * SPIKES_PER_BATCH - 1 : 0] spike_pattern [2**MAX_TIMESTEPS_BITS : 1];
    string line;

    WAIT(10);

    S_AXI_ARESETN = 1;

    WAIT(1);

    /* Write Reg Tests */
    // AXI_WRITE(CTRL_REG,32'hDEAD_BEEE);

    /* Read Reg Tests */
    // AXI_READ(CTRL_REG,32'hDEAD_BEEE);

    /* SNN Simulation */
    // AXI_WRITE(CTRL_REG,32'h0000_0006);
    // AXI_READ(CTRL_REG,32'h0000_0006);

    /* Write Input Spike Gen Regs */
    // for (i = 0; i < NUM_INPUTS; i = i + 1) begin
    //     AXI_WRITE(EXT_MEM_OFFSET + i, (32'hFFFF_FFFF / NUM_INPUTS) * i);
    // end

    /* Write Synapse Memories */

    // Select Synapse Memories
    AXI_WRITE(MEM_CFG_REG, 32'h1);
    
    for (i = 0; i < NUM_OUTPUTS; i++) begin
        weight_file_num_str.itoa(i);
        input_weight_file = $fopen({"/home/oshears/Documents/vt/research/code/verilog/snn_fpga/rtl/tb/neuron_weights/",weight_file_num_str,".txt"},"r");
        weight_cntr = 0;
        while(!$feof(input_weight_file)) begin
            $fgets(line,input_weight_file);
            weight_value = line.atohex();
            $display("Neuron: %d, Synapse: %d, Weight: %h",i[9:0],weight_cntr,weight_value);
            AXI_WRITE(MEM_CFG_REG, {4'b0000,i[17:0],weight_cntr[9:8],8'h1});
            AXI_WRITE(EXT_MEM_OFFSET + weight_cntr[7:0], weight_value);
            weight_cntr++;
        end
    end

    /* Write Spike Pattern */
    // Select Spike Pattern Memory
    AXI_WRITE(MEM_CFG_REG, 32'h2);
    input_pattern_file = $fopen("/home/oshears/Documents/vt/research/code/verilog/snn_fpga/rtl/tb/input_spike_patterns/mnist/input0.txt","r");
    timestep_cntr = 0;
    while(!$feof(input_pattern_file) && timestep_cntr < SIM_TIME) begin
        $fgets(line,input_pattern_file);
        input_cntr = 0;
        // Loop through each input on the line
        spike_pattern[timestep_cntr] = 0;
        for(i = 0; i < line.len(); i++) begin
            spike_value_str = line.substr(i,i);
            if (spike_value_str != "0" && spike_value_str != "1") continue;
            spike_pattern[timestep_cntr][input_cntr] = spike_value_str.atoi();
            input_cntr++;
        end

        $display("Spikes @ %d: %b",timestep_cntr,spike_pattern[timestep_cntr]);

        for (i = 0; i < NUM_INPUT_SPIKE_BATCHES; i++) begin
            $display("Writing spikes @ timestep: %d for batch %d range: [%d:%d] == %b",timestep_cntr,i,SPIKES_PER_BATCH * (i + 1) - 1,SPIKES_PER_BATCH * i, spike_pattern[timestep_cntr][SPIKES_PER_BATCH * (i + 1) - 1 -: SPIKES_PER_BATCH]);
            // Select Batch
            AXI_WRITE(MEM_CFG_REG, {i[5:0],2'h2});
            // Write Spike Pattern at batch index
            AXI_WRITE(EXT_MEM_OFFSET + timestep_cntr, spike_pattern[timestep_cntr][SPIKES_PER_BATCH * (i + 1) - 1 -: SPIKES_PER_BATCH]);
            AXI_READ(EXT_MEM_OFFSET + timestep_cntr, spike_pattern[timestep_cntr][SPIKES_PER_BATCH * (i + 1) - 1 -: SPIKES_PER_BATCH],0,1);
        end

        timestep_cntr++;
    end


    /* Set Sim Time to 100 */
    AXI_WRITE(SIM_TIME_REG, SIM_TIME);

    /* Start the Network */
    AXI_WRITE(CTRL_REG, 32'h1);

    WAIT(1);
    @(negedge busy);

    // Read Outputs
    // Select Spike Counter Memory
    AXI_WRITE(MEM_CFG_REG, 32'h3);
    for (i = 0; i < NUM_OUTPUTS; i = i + 1) begin
        AXI_READ(EXT_MEM_OFFSET + i);
    end

    $finish;

end



endmodule