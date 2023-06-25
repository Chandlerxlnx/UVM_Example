`include "uvm_macros.svh"

class my_driver extends uvm_driver #(my_transaction); //a parameterized class, define the transaction type that driver processed

	`uvm_component_utils(my_driver)
//need specify the parent object during initiation
	function new(string name = "my_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual task run_phase(uvm_phase phase); // key method. driver get the transaction from sequncer and interpret the them. driving DUT
	forever begin
		seq_item_port.get_next_item(req);
		`uvm_info("DRV_RUN_PHASE",req.sprint(),UVM_MEDIUM)
		#100;
		seq_item_port.item_done();
	end
	endtask

endclass
