class base_test extends uvm_test;
  `uvm_component_utils(base_test);
  environment env;
  
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = environment::type_id::create("env", this);
  endfunction
  
  virtual function void end_of_elaboration();
    print();
  endfunction
  
endclass

///////////////////////////////////////////////////////////////////////////

class ar_single_op_test extends base_test;

  `uvm_component_utils(ar_single_op_test)

  function new(string name = "ar_single_op_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    as_seq seq;
    phase.raise_objection(this);
    seq = as_seq::type_id::create("seq");
    seq.start(env.ag.seqr);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endtask

endclass

///////////////////////////////////////////////////////////////////////////

class ar_both_op_test extends base_test;

  `uvm_component_utils(ar_both_op_test)

  function new(string name = "ar_both_op_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    a_bothvalid_seq seq;
    phase.raise_objection(this);
    seq = a_bothvalid_seq::type_id::create("seq");
    seq.start(env.ag.seqr);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endtask

endclass

///////////////////////////////////////////////////////////////////////////

class log_single_op_test extends base_test;

  `uvm_component_utils(log_single_op_test)

  function new(string name = "log_single_op_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    ls_seq seq;
    phase.raise_objection(this);
    seq = ls_seq::type_id::create("seq");
    seq.start(env.ag.seqr);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endtask

endclass

///////////////////////////////////////////////////////////////////////////

class log_both_op_test extends base_test;

  `uvm_component_utils(log_both_op_test)

  function new(string name = "log_both_op_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    l_bothvalid_seq seq;
    phase.raise_objection(this);
    seq = l_bothvalid_seq::type_id::create("seq");
    seq.start(env.ag.seqr);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endtask

endclass

///////////////////////////////////////////////////////////////////////////

class regression_test extends base_test;
  
  `uvm_component_utils(regression_test)
  
  function new(string name = "regression_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection phase_done = phase.get_objection();
    regression_seq seq;
    phase.raise_objection(this);
    seq = regression_seq::type_id::create("seq");
    seq.start(env.ag.seqr);
    phase.drop_objection(this);
    phase_done.set_drain_time(this,20);
  endtask
endclass
