create_fileset -simset lab1_step3
set_property SOURCE_SET sources_1 [get_filesets lab1_step3]
add_files -fileset lab1_step3 -norecurse -scan_for_includes /home/czhao/axi_vip/labs/lab1/src/lab1_step3_simple_tb.sv
update_compile_order -fileset lab1_step3

