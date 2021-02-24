set_property PACKAGE_PIN T22 [get_ports {spike_out}];  # "LD0"
set_property PACKAGE_PIN F22 [get_ports {spike_in}];  # "SW0"
set_property PACKAGE_PIN G22 [get_ports {rst}];  # "SW1"
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"

set_property IOSTANDARD LVCMOS18 [get_ports {spike_out}];
set_property IOSTANDARD LVCMOS18 [get_ports {spike_in}];
set_property IOSTANDARD LVCMOS18 [get_ports {clk}];
set_property IOSTANDARD LVCMOS18 [get_ports {rst}];

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets spike_in_IBUF]