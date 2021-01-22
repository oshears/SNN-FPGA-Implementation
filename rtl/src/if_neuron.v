`timescale 1ns / 1ps
module if_neuron 
#(
    parameter THRESH=10,
    parameter RESET=0,
    parameter REFRAC=0,
    parameter WEIGHT_SIZE=32,
    parameter NUM_INPUTS=4,
    parameter WEIGHT_FILENAME="neuron.txt"
)
(
    input clk,
    input rst,
    input [NUM_INPUTS-1:0] spike_in,
    output spike_out
);

reg [WEIGHT_SIZE - 1:0] potential;

integer input_index;

assign spike_out = (potential >= THRESH) ? 1 : 0;

reg [WEIGHT_SIZE-1:0] weight_mem [NUM_INPUTS-1:0];

integer weight_file;
reg [WEIGHT_SIZE-1:0] weight_file_input;

reg [31:0] refrac_counter = 0;
reg refrac_en = 0;
wire refrac_done = 0;
reg refrac_rst = 0;
reg [1:0] current_state = 0;
reg [1:0] next_state = 0;
reg accumulator_en = 0;

localparam NORMAL_STATE = 0;
localparam REFRACTORY_STATE = 1;

assign refrac_done = (refrac_counter >= REFRAC) ? 1 : 0;

// initialize weight memory
initial begin
    
    weight_file = $fopen(WEIGHT_FILENAME,"r");

    for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
        $fscanf(weight_file,"%h\n",weight_file_input);
        weight_mem[input_index] = weight_file_input;
    end
    
    $fclose(weight_file);
end

// add all inputs that have a spike present
always @(posedge clk, posedge rst)
begin
    if (rst) begin
        potential = RESET;
    end
    else
    begin
        if(potential < THRESH && accumulator_en)
            for(input_index = 0; input_index < NUM_INPUTS; input_index = input_index + 1) begin
                if(spike_in[input_index])
                    potential = potential + weight_mem[input_index];
            end
            //potential = potential + 1;
        else
            potential = RESET;
    end
end

always @(posedge clk, posedge rst) begin
    if(rst)
        current_state <= NORMAL_STATE;
    else
        current_state <= next_state;
end

always @(posedge clk, posedge refrac_rst) begin
    if (refrac_rst) begin
        refrac_counter = 0;
    end
    else if (refrac_en) begin
        refrac_counter = refrac_counter + 1;
    end

end

always @(current_state,potential,refrac_counter) begin
    refrac_rst = 0;
    refrac_en = 0;
    accumulator_en = 0;
    case(current_state)
        NORMAL_STATE:
        begin
            accumulator_en = 1;
            if(potential >= THRESH) begin
                next_state = REFRACTORY_STATE;
            end
        end
        REFRACTORY_STATE:
        begin
            
            if(refrac_counter >= REFRAC - 1) begin
                next_state = NORMAL_STATE;
                refrac_rst = 1;
            end
            else
                refrac_en = 1;
        end
        default:
            next_state = NORMAL_STATE;
    endcase
end

endmodule