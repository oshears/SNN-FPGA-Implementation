`timescale 1ns / 1ps
module snn_core_top_tb;

localparam C_S_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 16;
localparam THRESH = 4;
localparam RESET = 0;
localparam REFRAC = 0;
localparam WEIGHT_SIZE = 9;
localparam NUM_INPUTS = 9;
localparam NUM_LAYERS = 2;
localparam [31 : 0] NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0]  = {2,3};

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
    .NUM_HIDDEN_LAYER_NEURONS(NUM_HIDDEN_LAYER_NEURONS)
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
    .S_AXI_BREADY(S_AXI_BREADY)
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

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA );
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_ARADDR = READ_ADDR;
        S_AXI_ARVALID = 1'b1;
        @(posedge S_AXI_RVALID);
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1'b1;
        if (EXPECT_DATA == S_AXI_RDATA) 
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
    AXI_WRITE(32'h0,32'hDEAD_BEEF);

    /* Read Reg Tests */
    AXI_READ(32'h0,32'hDEAD_BEEF);

    /* SNN Simulation */
    AXI_WRITE(32'h0,32'h0000_0006);
    AXI_READ(32'h0,32'h0000_0006);

    /* Write Input Spike Gen Regs */
    for (i = 0; i < NUM_INPUTS; i = i + 1) begin
        AXI_WRITE(32'h0000_0100 + i, (32'hFFFF_FFFF / NUM_INPUTS) * i);
    end

    /* Write Synapse Memories */

    // Select Synapse Memories
    AXI_WRITE(32'h0000_0004, 32'h1);

    
    for (i = 0; i < NUM_LAYERS; i = i + 1) begin
        for (j = 0; j < NUM_HIDDEN_LAYER_NEURONS[i]; j = j + 1) begin
            num_synapses = (i == 0) ? NUM_INPUTS : NUM_HIDDEN_LAYER_NEURONS[i - 1];
            // Select Layer and Neuron
            AXI_WRITE(32'h0000_0008, {i[3:0],j[19:0],8'h1});
            for (k = 0; k < num_synapses; k = k + 1) begin
                // Write Synapse Weight
                AXI_WRITE(32'h0000_0100 + k, weight_counter);

                weight_counter = weight_counter + 1;
            end
        end
    end

    /* Set Sim Time to 100 */
    AXI_WRITE(32'h0000_0004, 100);

    /* Reset Network */
    AXI_WRITE(32'h0000_0000, 32'h1);


    WAIT(20);

    $finish;

end



endmodule