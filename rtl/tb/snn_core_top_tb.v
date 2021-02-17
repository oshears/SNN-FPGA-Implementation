`timescale 1ns / 1ps
module snn_core_top_tb;
// Inputs
reg S_AXI_ACLK;

reg S_AXI_ARESETN;
reg [8:0] S_AXI_AWADDR; 
reg S_AXI_AWVALID;
reg [8:0] S_AXI_ARADDR; 
reg S_AXI_ARVALID;
reg [31:0] S_AXI_WDATA;  
reg [3:0] S_AXI_WSTRB;  
reg S_AXI_WVALID; 
reg S_AXI_RREADY; 
reg S_AXI_BREADY; 
wire S_AXI_AWREADY; 
wire S_AXI_ARREADY; 
wire S_AXI_WREADY;  
wire [31:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;  
wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;  

integer i = 0;
integer j = 0;

snn_core_top
#(
    .C_S_AXI_ACLK_FREQ_HZ(100000000),
    .C_S_AXI_DATA_WIDTH(32),
    .C_S_AXI_ADDR_WIDTH(9),
    .THRESH(15),
    .RESET(0),
    .REFRAC(5),
    .WEIGHT_SIZE(32),
    .NUM_INPUTS(9),
    .NUM_OUTPUTS(2),
    .NUM_LAYERS(1),
    .NUM_HIDDEN_LAYER_NEURONS(3)
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


initial begin
    S_AXI_ARESETN = 0;
    S_AXI_AWADDR = 0;
    S_AXI_AWVALID = 0;
    S_AXI_ARADDR = 0;
    S_AXI_ARVALID = 0;
    S_AXI_WDATA = 0;
    S_AXI_WSTRB = 0;
    S_AXI_WVALID = 0;
    S_AXI_RREADY = 0;
    S_AXI_BREADY = 0;

    @(posedge S_AXI_ACLK);
    @(posedge S_AXI_ACLK);

    S_AXI_ARESETN = 1;

    
    /* Write Reg Tests */
    for (i = 0; i < 4; i = i + 4)
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_AWADDR = i;
        S_AXI_AWVALID = 1'b1;
        S_AXI_WVALID = 1;
        S_AXI_WDATA = 32'hDEADBEEF;
        S_AXI_BREADY = 1'b1;
        @(posedge S_AXI_WREADY);
        @(posedge S_AXI_ACLK);
        S_AXI_WVALID = 0;
        S_AXI_AWVALID = 0;
        S_AXI_BREADY = 1'b0;
    end

    /* Read Reg Tests */
    for (i = 0; i < 4; i = i + 4)
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_ARADDR = i;
        S_AXI_ARVALID = 1'b1;
        @(posedge S_AXI_RVALID);
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1'b1;
        @(posedge S_AXI_ACLK);
        S_AXI_RREADY = 0;
    end

    #100;

    $finish;

end



endmodule