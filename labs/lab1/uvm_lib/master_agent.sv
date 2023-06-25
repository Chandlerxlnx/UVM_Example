
class master_agent extends uvm_agent;
	`uvm_component_utils(master_agent)

	//handlers
	my_sequencer 	m_seqr;
	my_driver	m_drvr;
	my_monitor	m_mont;

	function new(string name = "", uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(is_active == UVM_ACTIVE) begin
			m_seqr = my_sequencer::type_id::create("m_seqr",this);
			m_drvr = my_driver::type_id::create("m_drvr", this);
		end
		m_mont = my_monitor::type_id::create("m_mont",this);
	endfunction

	//connect_phase: connect the seq_item_port of driver with seq_item_export of sequencer
	virtual function void connect_phase(uvm_phase phase);
		if(is_active ==UVM_ACTIVE)
			m_drvr.seq_item_port.connect(m_seqr.seq_item_export);
	endfunction

endclass
