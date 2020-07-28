class my_sequencer extends uvm_sequencer #(my_transaction, my_transaction_rsp);

 

 `uvm_component_utils(my_sequencer);



  function new (string name="", uvm_component parent=null);

    super.new(name, parent);

  endfunction



endclass : my_sequencer
