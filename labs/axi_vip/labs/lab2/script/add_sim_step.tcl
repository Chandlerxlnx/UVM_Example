proc add_sim_step {{step 1}} {
    
     create_fileset -simset lab1_step${step}
     set_property SOURCE_SET sources_1 [get_filesets lab1_step${step}]
     add_files -fileset lab1_step${step} -norecurse -scan_for_includes ../src/lab1_step${step}_simple_tb.sv
     #update_compile_order -fileset lab1_step${step}
     current_fileset -simset [ get_filesets lab1_step${step} ]
     
  }
