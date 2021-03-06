# usage: vivado -mode tcl -source createBridgeProject.tcl

set_param general.maxThreads 8

create_project if_neuron_project ./if_neuron_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/tb/if_neuron_tb.sv
    ../rtl/tb/if_network_tb.sv
    ../rtl/tb/if_network_test_tb.sv
    ../rtl/tb/snn_fpga_top_tb.sv
    ../rtl/src/spike_accumulator.sv
    ../rtl/src/if_neuron.sv 
    ../rtl/src/if_layer.sv 
    ../rtl/src/if_layer_controller.sv 
    ../rtl/src/if_network.sv 
    ../rtl/src/snn_fpga_top.sv
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/if_neuron_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/if_network_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/if_network_test_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/snn_fpga_top_tb.sv]
add_files -fileset sim_1 -norecurse ../rtl/tb/neuron.txt
add_files -fileset sim_1 ../rtl/tb/neuron_weights/
# add_files -fileset sim_1 ../rtl/tb/neuron_test_weights/

# set_property top if_neuron_tb [get_filesets sim_1]
# set_property top if_network_tb [get_filesets sim_1]
set_property top snn_fpga_top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property top snn_fpga_top [current_fileset]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Load Constraints
read_xdc ../xdc/snn_fpga_top.xdc

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
set_property PROGRAM.FILE {/home/oshears/Documents/vt/research/code/verilog/snn_fpga/vivado/if_neuron_project/if_neuron_project.runs/impl_1/snn_fpga_top.bit} [get_hw_devices xc7z020_1]
current_hw_device [get_hw_devices xc7z020_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z020_1] 0]
set_property PROBES.FILE {} [get_hw_devices xc7z020_1]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7z020_1]
set_property PROGRAM.FILE {/home/oshears/Documents/vt/research/code/verilog/snn_fpga/vivado/if_neuron_project/if_neuron_project.runs/impl_1/snn_fpga_top.bit} [get_hw_devices xc7z020_1]
program_hw_devices [get_hw_devices xc7z020_1]
refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]