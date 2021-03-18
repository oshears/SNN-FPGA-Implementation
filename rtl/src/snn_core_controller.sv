`timescale 1ns / 1ps

module snn_core_controller
(
    input wire clk,
    input wire rst,
    input wire network_start,
    input wire network_done,
    input wire outputs_done,
    input wire sim_time_done,

    output reg output_cntr_rst = 0,
    output reg output_cntr_en = 0,
    output reg done = 0,
    output reg network_en = 0
);

localparam IDLE_STATE = 0;
localparam NETWORK_STATE = 1;
localparam OUTPUT_STORE_STATE = 2;

reg [1:0] current_state = 0;
reg [1:0] next_state = 0;

always @(posedge clk, posedge rst) begin
    if (rst)
        current_state <= IDLE_STATE;
    else
        current_state <= next_state;
end

always @(
    network_start,
    network_done,
    outputs_done,
    sim_time_done,
    current_state
    )
    begin
    
    output_cntr_en = 0;
    output_cntr_rst = 0;
    done = 0;
    network_en = 0;

    case (current_state)
    IDLE_STATE:
    begin
        done = 1;
        if (network_start)
            next_state = NETWORK_STATE;
    end
    NETWORK_STATE:
    begin
        done = 0;
        if (network_done) begin
            next_state = OUTPUT_STORE_STATE;
            output_cntr_rst = 1;
        end
        else
            network_en = 1;
    end
    OUTPUT_STORE_STATE:
    begin
        done = 0;
        output_cntr_en = 1;
        if (outputs_done)
            next_state = IDLE_STATE;
    end
    default:
    begin
        output_cntr_en = 0;
        output_cntr_rst = 0;
        done = 1;
        next_state = IDLE_STATE;
    end

    endcase
end

endmodule