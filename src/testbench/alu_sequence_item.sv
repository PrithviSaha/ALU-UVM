`include "uvm_macros.svh"
`include "defines.sv"
import uvm_pkg::*;

class sequence_item extends uvm_sequence_item;
  //`uvm_object_utils(sequence_item)
  //input signals
  rand bit 					CE;
  rand bit 					MODE;
  rand bit [1:0] 			INP_VALID;
  rand bit [`C_WIDTH-1:0] 	CMD;
  rand bit [`WIDTH-1:0] 	OPA;
  rand bit [`WIDTH-1:0] 	OPB;
  rand bit 					CIN;
  //output signals
  bit [`RES_WIDTH-1:0]	RES;
  bit COUT, OFLOW;
  bit G, L, E;
  bit ERR;
  
  `uvm_object_utils_begin(sequence_item)
  `uvm_field_int(OPA, UVM_ALL_ON)
  `uvm_field_int(OPB, UVM_ALL_ON)
  `uvm_field_int(CMD, UVM_ALL_ON)
  `uvm_field_int(MODE, UVM_ALL_ON)
  `uvm_field_int(CIN, UVM_ALL_ON)
  `uvm_field_int(INP_VALID, UVM_ALL_ON)
  `uvm_field_int(RES, UVM_ALL_ON)
  `uvm_field_int(OFLOW, UVM_ALL_ON)
  `uvm_field_int(COUT, UVM_ALL_ON)
  `uvm_field_int(G, UVM_ALL_ON)
  `uvm_field_int(L, UVM_ALL_ON)
  `uvm_field_int(E, UVM_ALL_ON)
  `uvm_field_int(ERR, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "sequence_item");
    super.new(name);
  endfunction
  
  constraint cmd_range { 
    if(MODE) CMD inside {[0:10]};
    else CMD inside {[0:13]};
    
    solve MODE before CMD;
  }
  
  constraint ce_cons {
    CE dist { 0 := 1, 1 := 9}; //INP_VALID == 3;
  }
  
endclass
