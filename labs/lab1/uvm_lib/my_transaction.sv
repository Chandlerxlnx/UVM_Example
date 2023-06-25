// You can insert code here by setting file_header_inc in file common.tpl

//=============================================================================
// Project  : generated_tb
//
// File Name: clkndata_seq_item.sv
//
//
// Version:   1.0
//
// Code created by Easier UVM Code Generator version 2017-01-19 on Sun Jun 25 11:46:49 2023
//=============================================================================
// Description: Sequence item for clkndata_sequencer
//=============================================================================

`ifndef MY_TRANSACTION_SV
`define MY_TRANSACTION_SV

// You can insert code here by setting trans_inc_before_class in file clkndata.tpl

class my_transaction extends uvm_sequence_item; 

  `uvm_object_utils(my_transaction)

  // To include variables in copy, compare, print, record, pack, unpack, and compare2string, define them using trans_var in file clkndata.tpl
  // To exclude variables from compare, pack, and unpack methods, define them using trans_meta in file clkndata.tpl

  // Transaction variables
  rand byte data;


  extern function new(string name = "");

  // You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_inside_class = no in file clkndata.tpl
  extern function void do_copy(uvm_object rhs);
  extern function bit  do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function void do_print(uvm_printer printer);
  extern function void do_record(uvm_recorder recorder);
  extern function void do_pack(uvm_packer packer);
  extern function void do_unpack(uvm_packer packer);
  extern function string convert2string();

  // You can insert code here by setting trans_inc_inside_class in file clkndata.tpl

endclass : my_transaction 


function my_transaction::new(string name = "");
  super.new(name);
endfunction : new


// You can remove do_copy/compare/print/record and convert2string method by setting trans_generate_methods_after_class = no in file clkndata.tpl

function void my_transaction::do_copy(uvm_object rhs);
  my_transaction rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  super.do_copy(rhs);
  data = rhs_.data;
endfunction : do_copy


function bit my_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit result;
  my_transaction rhs_;
  if (!$cast(rhs_, rhs))
    `uvm_fatal(get_type_name(), "Cast of rhs object failed")
  result = super.do_compare(rhs, comparer);
  result &= comparer.compare_field("data", data, rhs_.data, $bits(data));
  return result;
endfunction : do_compare


function void my_transaction::do_print(uvm_printer printer);
  if (printer.knobs.sprint == 0)
    `uvm_info(get_type_name(), convert2string(), UVM_MEDIUM)
  else
    printer.m_string = convert2string();
endfunction : do_print


function void my_transaction::do_record(uvm_recorder recorder);
  super.do_record(recorder);
  // Use the record macros to record the item fields:
  `uvm_record_field("data", data)
endfunction : do_record


function void my_transaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
  `uvm_pack_int(data) 
endfunction : do_pack


function void my_transaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  `uvm_unpack_int(data) 
endfunction : do_unpack


function string my_transaction::convert2string();
  string s;
  $sformat(s, "%s\n", super.convert2string());
  $sformat(s, {"%s\n",
    "data = 'h%0h  'd%0d\n"},
    get_full_name(), data, data);
  return s;
endfunction : convert2string


// You can insert code here by setting trans_inc_after_class in file clkndata.tpl

`endif // MY_TRANSACTION_SV

