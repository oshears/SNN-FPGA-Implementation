# usage: vivado -mode tcl -source createBridgeProject.tcl

set_param general.maxThreads 8

create_project if_neuron_project ./if_neuron_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/tb/if_neuron_tb.sv
    ../rtl/tb/if_network_tb.sv
    ../rtl/tb/if_network_test_tb.sv
    ../rtl/tb/if_recurrent_network_tb.sv
    ../rtl/src/spike_accumulator.sv
    ../rtl/src/if_neuron.sv 
    ../rtl/src/if_layer.sv 
    ../rtl/src/if_layer_controller.sv 
    ../rtl/src/if_network.sv 
    ../rtl/src/if_recurrent_network.sv 
    ../rtl/src/snn_fpga_top.sv
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/if_neuron_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/if_network_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/if_network_test_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/if_recurrent_network_tb.sv]
add_files -fileset sim_1 -norecurse ../rtl/tb/neuron.txt
add_files -fileset sim_1 ../rtl/tb/neuron_weights/
# add_files -fileset sim_1 ../rtl/tb/neuron_test_weights/

# set_property top if_neuron_tb [get_filesets sim_1]
# set_property top if_network_tb [get_filesets sim_1]
# set_property top if_network_test_tb [get_filesets sim_1]
set_property top if_recurrent_network_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

launch_simulation

# add_wave {{/if_network_tb/uut}} 
