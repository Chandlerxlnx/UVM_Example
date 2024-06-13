#xvlog -f file.f -sv -L work --include ../uvm_lib --include ../test ../uvm_lib/my_transaction.sv ../test/my_test.sv ../uvm_lib/my_env.sv ../uvm_lib/my_sequence.sv ../uvm_lib/my_sequence.sv 
xvlog -f file.f -sv -L work 
xelab --incr -timescale 1ns/1ps -L work -L unisims_ver -L xpm -L unimacro_ver -L secureip -L UVM test
xsim test -R -testplusarg UVM_TESTNAME=my_test 

