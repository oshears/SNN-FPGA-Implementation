`timescale 1ns / 1ps
module snn_core_top
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 16,
    // Neuron Threshold
    parameter [61:0] THRESH=15,
    // Neuron Membrane Potential Reset Value
    parameter [61:0] RESET=0,
    // Refractory Period
    parameter [61:0] REFRAC=5,
    // Weight Size in Bits
    parameter WEIGHT_SIZE=32,
    // Number of Network Inputs (e.g. pixels)
    parameter NUM_INPUTS=4,
    // Number of layers
    parameter NUM_LAYERS=1,
    // Number of neurons per layer
    parameter [31 : 0] NUM_HIDDEN_LAYER_NEURONS [NUM_LAYERS - 1 : 0] = {32'h1},
    // Parameters to configure spike pattern memory
    parameter MAX_TIMESTEPS_BITS = 8,
    parameter SPIKE_PATTERN_BATCH_ADDR_WIDTH = 6,
    parameter SPIKES_PER_BATCH = 32,
    parameter OUTPUT_SPIKE_ADDR_BITS = 4
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
    output S_AXI_BVALID,
    output busy
);

localparam NUM_OUTPUTS = NUM_HIDDEN_LAYER_NEURONS[NUM_LAYERS - 1];

wire rst;

assign rst = ~S_AXI_ARESETN;

wire [31:0] debug;
wire [31:0] ctrl;

wire [NUM_INPUTS - 1:0] spike_in;
wire [NUM_INPUTS - 1:0] bernoulli_spike_in;
wire [NUM_INPUTS - 1:0] bernoulli_spike_in_i;
wire [NUM_INPUTS - 1:0] spike_pattern_spike_in;
wire [NUM_INPUTS - 1:0] spike_pattern_spike_in_i;
wire [NUM_OUTPUTS - 1:0] spike_out;

wire [31 : 0] ext_mem_addr;
wire ext_mem_wen;
wire [31 : 0] ext_mem_data_in;
wire [31 : 0] ext_mem_data_out;
wire [1 : 0] ext_mem_sel;

wire [31 : 0] spike_gen_mem_addr;
wire spike_gen_mem_wen;
wire [31 : 0] spike_gen_mem_data_in;
wire [31 : 0] spike_gen_mem_data_out;

wire [31 : 0] synpase_weight_mem_addr;
wire synpase_weight_mem_wen;
wire [WEIGHT_SIZE - 1 : 0] synpase_weight_mem_data_in;
wire [WEIGHT_SIZE - 1 : 0] synpase_weight_mem_data_out;

wire [31:0] sim_time;

wire [31 : 0] spike_counter_out [NUM_OUTPUTS - 1 : 0];

wire network_rst;

wire network_en;

wire network_done;

wire [MAX_TIMESTEPS_BITS - 1:0] spike_pattern_mem_addr;
wire spike_pattern_mem_wen;
wire [SPIKES_PER_BATCH - 1 :0] spike_pattern_mem_data_in;
wire [SPIKES_PER_BATCH - 1 :0] spike_pattern_mem_data_out;
wire [SPIKE_PATTERN_BATCH_ADDR_WIDTH - 1:0] spike_pattern_batch_sel;

wire [MAX_TIMESTEPS_BITS - 1:0] spike_pattern_cntr;

wire [31:0] sim_time_cntr_out;

wire spike_en;

wire outputs_done = (output_cntr == NUM_OUTPUTS - 1);
wire output_cntr_rst;
wire output_cntr_en;
wire done;
wire [OUTPUT_SPIKE_ADDR_BITS - 1:0] output_cntr;

wire [OUTPUT_SPIKE_ADDR_BITS - 1 : 0] spike_output_count_mem_addr;
wire spike_output_count_mem_wen;
wire [31 : 0] spike_output_count_mem_data_in;
wire [31 : 0] spike_output_count_mem_data_out;


assign busy = ~done;

assign network_done = ( sim_time_cntr_out == (sim_time - 1) );

assign spike_pattern_spike_in = spike_en ? spike_pattern_spike_in_i : 0;
assign bernoulli_spike_in = spike_en ? bernoulli_spike_in_i : 0;

assign spike_in = ctrl[1] ? bernoulli_spike_in : spike_pattern_spike_in;

assign spike_gen_mem_addr = (ext_mem_sel == 2'b00) ? ext_mem_addr : 0;
assign spike_gen_mem_wen = (ext_mem_sel == 2'b00) ? ext_mem_wen : 0;
assign spike_gen_mem_data_in = ext_mem_data_in;

assign synpase_weight_mem_addr = (ext_mem_sel == 2'b01) ? ext_mem_addr : 0;
assign synpase_weight_mem_wen = (ext_mem_sel == 2'b01) ? ext_mem_wen : 0;
assign synpase_weight_mem_data_in = ext_mem_data_in;

assign spike_pattern_mem_addr = (network_en) ? spike_pattern_cntr : ( (ext_mem_sel == 2'b10) ? ext_mem_addr : 0) ;
assign spike_pattern_mem_wen = (ext_mem_sel == 2'b10) ? ext_mem_wen : 0;
assign spike_pattern_mem_data_in = ext_mem_data_in;

assign spike_output_count_mem_addr = (output_cntr_en) ? output_cntr : ( (ext_mem_sel == 2'b11) ? ext_mem_addr[OUTPUT_SPIKE_ADDR_BITS - 1 : 0] : 0) ;
assign spike_output_count_mem_wen = (output_cntr_en) ? output_cntr_en : ( (ext_mem_sel == 2'b11) ? ext_mem_wen : 0 );
assign spike_output_count_mem_data_in = (output_cntr_en) ? spike_counter_out[output_cntr] : ext_mem_data_in;

assign ext_mem_data_out =   (ext_mem_sel == 2'b00) ? spike_gen_mem_data_out : ( 
                            (ext_mem_sel == 2'b01) ? synpase_weight_mem_data_out : (
                            (ext_mem_sel == 2'b10) ? spike_pattern_mem_data_out : (
                            (ext_mem_sel == 2'b11) ? spike_output_count_mem_data_out : 0
                            )));



axi_cfg_regs 
#(
    .C_S_AXI_ACLK_FREQ_HZ(C_S_AXI_ACLK_FREQ_HZ),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .NUM_OUTPUTS(NUM_OUTPUTS)
)
axi_cfg_regs
(
    // Debug Register Output
    .debug(debug),
    // Control Register Output
    .ctrl(ctrl),
    // Simulation Time Register
    .sim_time(sim_time),
    // Spike Counter Registers
    .spike_counter_out(spike_counter_out),
    // Network Done Signal
    .done(done),
    // Network Busy Signal
    .network_busy(network_en),
    // Spike Generator RAM Signals
    .ext_mem_addr(ext_mem_addr),
    .ext_mem_wen(ext_mem_wen),
    .ext_mem_data_in(ext_mem_data_in),
    .ext_mem_data_out(ext_mem_data_out),
    .ext_mem_sel(ext_mem_sel),
    .spike_pattern_batch_sel(spike_pattern_batch_sel),
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


assign network_rst = ctrl[0] || rst;

if_network
#(
    .THRESH(THRESH),
    .RESET(RESET),
    .REFRAC(REFRAC),
    .WEIGHT_SIZE(WEIGHT_SIZE),
    .NUM_INPUTS(NUM_INPUTS),
    .NUM_LAYERS(NUM_LAYERS),
    .NUM_HIDDEN_LAYER_NEURONS(NUM_HIDDEN_LAYER_NEURONS),
    .LAYER_ADDR_WIDTH(32),
    .NEURON_ADDR_WIDTH(28),
    .WEIGHT_ADDR_WIDTH(10)
)
if_network
(
    .clk(S_AXI_ACLK),
    .rst(network_rst),
    .spike_in(spike_in),
    .spike_out(spike_out),
    .mem_addr(synpase_weight_mem_addr),
    .mem_din(synpase_weight_mem_data_in),
    .mem_wen(synpase_weight_mem_wen),
    .mem_dout(synpase_weight_mem_data_out)
);




spike_counter
#(
    .NUM_INPUTS(NUM_OUTPUTS),
    .COUNTER_SIZE(32)
)
spike_counter
(
    .spike_in(spike_out),
    .rst(network_rst),
    .counter_out(spike_counter_out)
);


bernoulli_spike_generator
# (
    .NUM_SPIKES(NUM_INPUTS),
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
)
spike_generator
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .en(spike_en),
    .mem_addr(spike_gen_mem_addr),
    .mem_wen(spike_gen_mem_wen),
    .mem_data_in(spike_gen_mem_data_in),
    .mem_data_out(spike_gen_mem_data_out),
    .spikes(bernoulli_spike_in_i)
);

spike_pattern_mem
# (
    .NUM_SPIKES(NUM_INPUTS),
    .TIMESTEP_ADDR_WIDTH(MAX_TIMESTEPS_BITS),
    .SPIKE_PATTERN_BATCH_ADDR_WIDTH(SPIKE_PATTERN_BATCH_ADDR_WIDTH),
    .SPIKES_PER_BATCH(32)
)
spike_pattern_mem
(
    .clk(S_AXI_ACLK),
    .mem_addr(spike_pattern_mem_addr),
    .mem_wen(spike_pattern_mem_wen),
    .mem_data_in(spike_pattern_mem_data_in),
    .mem_data_out(spike_pattern_mem_data_out),
    .batch_sel(spike_pattern_batch_sel[SPIKE_PATTERN_BATCH_ADDR_WIDTH - 1 : 0]),
    .spikes(spike_pattern_spike_in_i)
);

counter 
#(
    .DATA_WIDTH(MAX_TIMESTEPS_BITS)
)
spike_pattern_counter (
    .clk(S_AXI_ACLK),
    .rst(network_rst),
    .en(spike_en),
    .dout(spike_pattern_cntr)
);

counter 
#(
    .DATA_WIDTH(1)
)
spike_en_counter (
    .clk(S_AXI_ACLK),
    .rst(network_rst),
    .en(network_en),
    .dout(spike_en)
);


counter 
#(
    .DATA_WIDTH(32)
)
sim_time_cntr (
    .clk(S_AXI_ACLK),
    .rst(network_rst),
    .en(spike_en),
    .dout(sim_time_cntr_out)
);

counter 
#(
    .DATA_WIDTH(OUTPUT_SPIKE_ADDR_BITS)
)
output_counter 
(
    .clk(S_AXI_ACLK),
    .rst(output_cntr_rst),
    .en(output_cntr_en),
    .dout(output_cntr)
);

snn_core_controller snn_core_controller
(
.clk(S_AXI_ACLK),
.rst(rst),
.network_start(ctrl[0]),
.network_done(network_done),
.outputs_done(outputs_done),
.output_cntr_rst(output_cntr_rst),
.output_cntr_en(output_cntr_en),
.done(done),
.network_en(network_en)
);

ram
#(
    .ADDR_WIDTH(OUTPUT_SPIKE_ADDR_BITS),
    .DATA_WIDTH(32)
)
output_spike_counts_ram
(
    .clk(S_AXI_ACLK),
    .wen(spike_output_count_mem_wen),
    .addr(spike_output_count_mem_addr),
    .din(spike_output_count_mem_data_in),
    .dout(spike_output_count_mem_data_out)
);


endmodule