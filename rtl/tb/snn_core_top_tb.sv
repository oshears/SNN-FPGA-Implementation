`timescale 1ns / 1ps
module snn_core_top_tb;

localparam C_S_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 16;
localparam THRESH = 256;
localparam RESET = 0;
localparam REFRAC = 0;
localparam WEIGHT_SIZE = 9;
localparam NUM_INPUTS = 9;
localparam NUM_LAYERS = 2;
localparam [31 : 0] NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0]  = {2,3};
localparam MAX_TIMESTEPS_BITS = 8;
localparam SPIKE_PATTERN_BATCH_ADDR_WIDTH = 1;

localparam NUM_OUTPUTS = NUM_HIDDEN_LAYER_NEURONS[0];

localparam CTRL_REG = 16'h0000;
localparam SIM_TIME_REG = 16'h0004;
localparam MEM_CFG_REG = 16'h0008;
localparam DEBUG_REG = 16'h000C;
localparam EXT_MEM_OFFSET = 16'h0100;

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
    .SPIKE_PATTERN_BATCH_ADDR_WIDTH(SPIKE_PATTERN_BATCH_ADDR_WIDTH)
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
    WAIT(10);

    S_AXI_ARESETN = 1;

    WAIT(1);

    /* Write Reg Tests */
    AXI_WRITE(CTRL_REG,32'hDEAD_BEEF);

    /* Read Reg Tests */
    AXI_READ(CTRL_REG,32'hDEAD_BEEF);

    /* SNN Simulation */
    AXI_WRITE(CTRL_REG,32'h0000_0006);
    AXI_READ(CTRL_REG,32'h0000_0006);

    /* Write Input Spike Gen Regs */
    for (i = 0; i < NUM_INPUTS; i = i + 1) begin
        AXI_WRITE(EXT_MEM_OFFSET + i, (32'hFFFF_FFFF / NUM_INPUTS) * i);
    end

    /* Write Synapse Memories */

    // Select Synapse Memories
    AXI_WRITE(MEM_CFG_REG, 32'h1);
    
    for (i = 0; i < NUM_LAYERS; i = i + 1) begin
        for (j = 0; j < NUM_HIDDEN_LAYER_NEURONS[i]; j = j + 1) begin
            num_synapses = (i == 0) ? NUM_INPUTS : NUM_HIDDEN_LAYER_NEURONS[i - 1];
            // Select Layer and Neuron
            AXI_WRITE(MEM_CFG_REG, {i[3:0],j[19:0],8'h1});
            for (k = 0; k < num_synapses; k = k + 1) begin
                // Write Synapse Weight
                AXI_WRITE(EXT_MEM_OFFSET + k, weight_counter);

                weight_counter = weight_counter + 1;
            end
        end
    end

    /* Write Spike Pattern */
    // Select Spike Pattern Memory
    AXI_WRITE(MEM_CFG_REG, 32'h2);
    for (i = 0; i < 2**MAX_TIMESTEPS_BITS; i = i + 1) begin
        // Loop through each input spike batch
        for (j = 0; j < 2**SPIKE_PATTERN_BATCH_ADDR_WIDTH; j = j + 1) begin
            // Select Spike Pattern Memory & Batch
            AXI_WRITE(MEM_CFG_REG, {j[5:0],2'h2});
            // Select the input spike batch
            if(i % 2 == 0)
                AXI_WRITE(EXT_MEM_OFFSET + i, 32'b0000_1111_1010_0101_0000_1111_1010_0101);
            else
                AXI_WRITE(EXT_MEM_OFFSET + i, 32'b1111_0000_0101_1010_1111_0000_0010_0001);
        end
    end


    /* Set Sim Time to 100 */
    AXI_WRITE(SIM_TIME_REG, 2**MAX_TIMESTEPS_BITS);

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