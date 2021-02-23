# Connect Outputs to LEDS for Debugging
set_property PACKAGE_PIN T22 [get_ports {spike_out}];  # "LD0"

# Connect Inputs to Switch 0
set_property PACKAGE_PIN F22 [get_ports {spike_in}];  # "SW0"