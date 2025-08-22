`include "defines.sv"

class base_seq extends uvm_sequence #(sequence_item);
  `uvm_object_utils(base_seq)
  
   function new(string name = "base_seq");
     super.new(name);
   endfunction
    
   virtual task body();
     repeat(4) begin
       req = sequence_item::type_id::create("req");
       wait_for_grant();
       req.randomize();
       send_request(req);
       wait_for_item_done();
     end
   endtask
    
endclass

///////////////////////////////////////////////////////////////////////////

class as_seq extends uvm_sequence #(sequence_item);
  
  `uvm_object_utils(as_seq)
   
  function new(string name = "as_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat (`N) begin
    `uvm_do_with(req, {req.MODE == 1; req.CMD inside {4, 5, 6, 7};})
    end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////

class a_bothvalid_seq extends uvm_sequence #(sequence_item);
  
  `uvm_object_utils(a_bothvalid_seq)
   
  function new(string name = "a_bothvalid_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(`N) begin
//       `uvm_info("SEQUENCE", "Entered seq body", UVM_LOW)
      `uvm_do_with(req, { req.MODE == 1; req.CMD inside {1,2,3,8,9,10}; })
    end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////

class ls_seq extends uvm_sequence #(sequence_item);
  
  `uvm_object_utils(ls_seq)
   
  function new(string name = "ls_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat (`N) begin
      `uvm_do_with(req, {req.MODE == 0; req.CMD inside {[6:11]};})
    end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////

class l_bothvalid_seq extends uvm_sequence #(sequence_item);
  
  `uvm_object_utils(l_bothvalid_seq)
   
  function new(string name = "l_bothvalid_seq");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(`N) begin
//       `uvm_info("SEQUENCE", "Entered seq body", UVM_LOW)
      `uvm_do_with(req, { req.MODE == 1; req.CMD inside {1,2,3,4,5,12,13}; })
    end
  endtask
endclass

///////////////////////////////////////////////////////////////////////////

class regression_seq extends uvm_sequence #(sequence_item);
  
  `uvm_object_utils(regression_seq);
  
  as_seq 			a_single_seq_1;
  a_bothvalid_seq 	a_both_seq_1;
  ls_seq 			l_single_seq_1;
  l_bothvalid_seq 	l_both_seq_1;
  
  function new(string name = "regression_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_do(a_single_seq_1);
    `uvm_do(a_both_seq_1);
    `uvm_do(l_single_seq_1);
    `uvm_do(l_both_seq_1);
  endtask
endclass
