`timescale 1ns / 1ps
module axi_cfg_regs
#(
parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_S_AXI_DATA_WIDTH = 32,
parameter C_S_AXI_ADDR_WIDTH = 9,
parameter NUM_OUTPUTS = 1
)
(
    
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

    input [31 : 0] ext_mem_data_out,

    input [31 : 0] spike_counter_out [NUM_OUTPUTS - 1 : 0],

    input network_done,

    output reg S_AXI_AWREADY = 0, 
    output reg S_AXI_ARREADY = 0, 
    output reg S_AXI_WREADY = 0,  
    output reg [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA = 0,
    output reg [1:0] S_AXI_RRESP = 0,
    output reg S_AXI_RVALID = 0,  
    output reg [1:0] S_AXI_BRESP = 0,
    output reg S_AXI_BVALID = 0,    

    output [31:0] debug,
    output [31:0] ctrl,
    output [31:0] sim_time,

    output [31 : 0] ext_mem_addr,
    output ext_mem_wen,
    output [31 : 0] ext_mem_data_in,
    output [1:0] ext_mem_sel
);


reg [31:0] debug_reg = 0;
reg  debug_reg_addr_valid = 0;

reg ctrl_reg_addr_valid = 0;
reg [31:0] ctrl_reg = 0;

reg sim_time_reg_addr_valid = 0;
reg [31:0] sim_time_reg = 0;

reg mem_cfg_reg_addr_valid = 0;
reg [31:0] mem_cfg_reg = 0;

reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

reg [15:0] local_address = 0;
reg local_address_valid = 0;

wire [1:0] combined_S_AXI_AWVALID_S_AXI_ARVALID;

reg write_enable_registers = 0;
reg send_read_data_to_AXI = 0;

reg ext_mem_addr_valid = 0;

wire Local_Reset;


localparam reset = 0, idle = 1, read_transaction_in_progress = 2, write_transaction_in_progress = 3, complete = 4;

assign Local_Reset = ~S_AXI_ARESETN;
assign combined_S_AXI_AWVALID_S_AXI_ARVALID = {S_AXI_AWVALID, S_AXI_ARVALID};
assign debug = debug_reg;

always @ (posedge S_AXI_ACLK or posedge Local_Reset) begin
    if (Local_Reset)
        current_state <= reset;
    else
        current_state <= next_state;

end

// main AXI state machine
always @ (current_state, combined_S_AXI_AWVALID_S_AXI_ARVALID, S_AXI_ARVALID, S_AXI_RREADY, S_AXI_AWVALID, S_AXI_WVALID, S_AXI_BREADY, local_address, local_address_valid) begin
    S_AXI_ARREADY = 0;
    S_AXI_RRESP = 2'b00;
    S_AXI_RVALID = 0;
    S_AXI_WREADY = 0;
    S_AXI_BRESP = 2'b00;
    S_AXI_BVALID = 0;
    S_AXI_WREADY = 0;
    S_AXI_AWREADY = 0;
    write_enable_registers = 0;
    send_read_data_to_AXI = 0;
    next_state = current_state;

    case (current_state)
        reset:
            next_state = idle;
        idle:
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID)
                2'b01:
                    next_state = read_transaction_in_progress;
                2'b10:
                    next_state = write_transaction_in_progress;
            endcase
        end
        read_transaction_in_progress:
        begin
            next_state = read_transaction_in_progress;
            S_AXI_ARREADY = S_AXI_ARVALID;
            S_AXI_RVALID = 1;
            S_AXI_RRESP = 2'b00;
            send_read_data_to_AXI = 1;
            if (S_AXI_RREADY == 1) 
                next_state = complete;
        end
        write_transaction_in_progress:
        begin
            next_state = write_transaction_in_progress;
			write_enable_registers = 1;
            S_AXI_AWREADY = S_AXI_AWVALID;
            S_AXI_WREADY = S_AXI_WVALID;
            S_AXI_BRESP = 2'b00;
            S_AXI_BVALID = 1;
			if (S_AXI_BREADY == 1)
			    next_state = complete;
        end
        complete:
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID) 
				2'b00:
                     next_state = idle;
				default:
                    next_state = complete;
			endcase;
        end
    endcase
end

// send data to AXI RDATA
always @(
    send_read_data_to_AXI, 
    local_address, 
    local_address_valid, 
    debug_reg,
    ctrl_reg,
    sim_time_reg,
    mem_cfg_reg,
    ext_mem_data_out
    )
begin
    S_AXI_RDATA = 32'b0;

    if (local_address_valid == 1 && send_read_data_to_AXI == 1)
    begin
        case(local_address)
            4'h0000_0000:
                S_AXI_RDATA = ctrl_reg;
            4'h0000_0004:
                S_AXI_RDATA = sim_time_reg;
            4'h0000_0008:
                S_AXI_RDATA = mem_cfg_reg;
            4'h0000_000C:
                S_AXI_RDATA = debug_reg;
            default:
                S_AXI_RDATA = 32'b0;
        endcase;     
    end
end

// local address capture
always  @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        local_address = 0;
    else
    begin
        if (local_address_valid == 1)
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID)
                2'b10:
                    local_address = S_AXI_AWADDR[15:0];
                2'b01:     
                    local_address = S_AXI_ARADDR[15:0];
            endcase
        end
    end
end

// write data address analysis
always @(local_address,write_enable_registers)
begin
    debug_reg_addr_valid = 0;
    ext_mem_addr_valid = 0;
    ctrl_reg_addr_valid = 0;
    mem_cfg_reg_addr_valid = 0;
    sim_time_reg_addr_valid = 0;
    local_address_valid = 1;

    if (write_enable_registers)
    begin
        case (local_address)
            16'h0000_0000:
                ctrl_reg_addr_valid = 1;
            16'h0000_0004:
                sim_time_reg_addr_valid = 1;
            16'h0000_0008:
                mem_cfg_reg_addr_valid = 1;
            16'h0000_000C:
                debug_reg_addr_valid = 1;
            default:
            begin
                ext_mem_addr_valid = 1;
                local_address_valid = 1;
            end
        endcase
    end
end

// debug_reg
always @(posedge S_AXI_ACLK, posedge Local_Reset)
begin
    if (Local_Reset)
        debug_reg = 0;
    else
    begin
        // LED Controls
        // BIT 0: IF ACTIVE, then display char information on LEDs, ELSE display network output on LEDS
        // BIT 1: IF ACTIVE, then display direct_ctrl_reg values on LEDS, ELSE display char_pwm_gen outputs on LEDS 
        // Output Controls
        // BIT 2: Use direct_ctrl_reg value as digit outputs ELSE use char_pwm_gen
        // BIT 3: Use slow 1HZ Clock
        // BIT 4: Use 1-Hot Encoding for XADC Multiplexer
        // BIT 5: debug_reg[5] output on XADC header GPIO3
        if(debug_reg_addr_valid)
            debug_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK, posedge Local_Reset) begin
    if (Local_Reset)
        ctrl_reg = 0;
    else begin
        if(ctrl_reg_addr_valid)
            ctrl_reg = {S_AXI_WDATA[31:3],network_done,S_AXI_WDATA[1:0]};
        else begin
            ctrl_reg[0] = 0;
            ctrl_reg[2] = network_done;
        end
    end
end

always @(posedge S_AXI_ACLK, posedge Local_Reset) begin
    if (Local_Reset)
        mem_cfg_reg = 0;
    else begin
        if(mem_cfg_reg_addr_valid)
            mem_cfg_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK, posedge Local_Reset) begin
    if (Local_Reset)
        sim_time_reg = 100;
    else begin
        if(sim_time_reg_addr_valid)
            sim_time_reg = S_AXI_WDATA;
    end
end

assign ext_mem_addr = {mem_cfg_reg[31:8],local_address[7:0]};
assign ext_mem_data_in = S_AXI_WDATA;
assign ext_mem_wen = write_enable_registers && ext_mem_addr_valid && (local_address[15:8] > 0);
assign ext_mem_sel = mem_cfg_reg[1:0];

assign ctrl = ctrl_reg;

assign sim_time = sim_time_reg;

endmodule