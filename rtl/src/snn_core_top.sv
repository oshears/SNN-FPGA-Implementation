`timescale 1ns / 1ps
module snn_core_top
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 9,
    parameter THRESH=15,
    parameter RESET=0,
    parameter REFRAC=5,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter NUM_LAYERS=1,
    parameter [31 : 0]  NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0] = {32'h1}
)
(
    // axi_cfg_regs
    input S_AXI_ACLK,   
    input S_AXI_ARESETN,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR, 
    input S_AXI_AWVALID,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR, 
    input S_AXI_ARVALID,
    input [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA,  
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,  
    input S_AXI_WVALID, 
    input S_AXI_RREADY, 
    input S_AXI_BREADY, 

    output S_AXI_AWREADY, 
    output S_AXI_ARREADY, 
    output S_AXI_WREADY,  
    output [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA,
    output [1:0] S_AXI_RRESP,
    output S_AXI_RVALID,  
    output [1:0] S_AXI_BRESP,
    output S_AXI_BVALID    
);

localparam NUM_OUTPUTS = NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1];


wire rst;
wire snn_rst;

assign rst = ~S_AXI_ARESETN;

wire [31:0] debug;

wire [NUM_INPUTS - 1:0] spike_in;
wire [NUM_OUTPUTS - 1:0] spike_out;


axi_cfg_regs 
#(
    C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH
)
axi_cfg_regs
(
    // Debug Register Output
    .debug(debug),
    //AXI Signals
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

// binary_spike_gen
// #(
//     .NUM_OUTPUTS(NUM_INPUTS),
//     .SPIKE_PERIOD(1)
// )
// binary_spike_gen
// (
//     .clk(S_AXI_ACLK),
//     .rst(rst),
//     .spike_en(debug[NUM_INPUTS - 1 : 0]),
//     .spike_out(spike_in)
// );

if_network
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_LAYERS(NUM_LAYERS),
    .NUM_HIDDEN_LAYER_NEURONS(NUM_HIDDEN_LAYER_NEURONS)
)
if_network
(
    .clk(S_AXI_ACLK),
    .rst(snn_rst),
    .spike_in(spike_in),
    .spike_out(spike_out)
);

spike_counter
#(
    .NUM_INPUTS(NUM_OUTPUTS),
    .COUNTER_SIZE(4)
)
spike_counter
(
    .spike_in(spike_out),
    .rst(snn_rst),
    .counter_out()
);

spike_generator
# (
    .NUM_SPIKES(NUM_INPUTS),
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
)
spike_generator
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .mem_addr(0),
    .mem_wen(0),
    .mem_data_in(0),
    .mem_data_out(),
    .spikes(spike_in)
);


endmodule