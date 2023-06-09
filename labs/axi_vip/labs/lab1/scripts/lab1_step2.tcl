create_fileset -simset lab1_step2
set_property SOURCE_SET sources_1 [get_filesets lab1_step2]
add_files -fileset lab1_step2 -norecurse ../src/lab1_step2_simple_tb.sv
update_compile_order -fileset lab1_step2
current_fileset -simset [ get_filesets lab1_step2 ]

