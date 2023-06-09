create_project -force proj_lab proj_lab -part xc7s25csga225-1Q
source ../script/crt_bd_ex_sim.tcl
update_compile_order -fileset sources_1
make_wrapper -files [get_files ex_sim.bd] -top -import
create_fileset -simset lab_step1
set_property SOURCE_SET sources_1 [get_filesets lab_step1]
add_files -fileset lab_step1 -norecurse ../src/lab2_step1_memory_tb.sv
update_compile_order -fileset lab_step1
#set_property used_in_synthesis false [get_files  ../src/lab_simple_tb.sv]
#set_property used_in_implementation false [get_files  ../src/lab_simple_tb.sv]
#set_property simulator_language Verilog [current_project]
#set_property dataflow_viewer_settings "min_width=16"   [current_fileset]
current_fileset -simset [ get_filesets lab_step1 ]

generate_target Simulation [get_files ex_sim.bd]
export_ip_user_files -of_objects [get_files ex_sim.bd] -no_script -sync -force -quiet
#export_simulation -of_objects [get_files ex_sim.bd] -use_ip_compiled_libs -force -quiet
export_simulation  -use_ip_compiled_libs -force -quiet
launch_simulation
