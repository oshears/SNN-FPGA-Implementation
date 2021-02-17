# usage: vivado -mode tcl -source createSNNCoreProject.tcl

set_param general.maxThreads 8

create_project snn_core_project ./snn_core_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/src/counter.v 
    ../rtl/src/binary_spike_gen.v 
    ../rtl/src/spike_counter.v 
    ../rtl/src/if_neuron.v 
    ../rtl/src/if_layer.v 
    ../rtl/src/if_network.v 
    ../rtl/src/axi_cfg_regs.v 
    ../rtl/src/snn_core_top.v 
    ../rtl/tb/snn_core_top_tb.v
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/snn_core_top_tb.v]
add_files -fileset sim_1 -norecurse ../rtl/tb/neuron.txt
add_files -fileset sim_1 ../rtl/tb/neuron_weights/

set_property top snn_core_top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

launch_simulation

add_wave {{/snn_core_top_tb/uut}} 
