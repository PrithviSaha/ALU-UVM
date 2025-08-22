class environment extends uvm_env;
  `uvm_component_utils(environment)
  
  agent ag;
  scoreboard scb;
  subscriber sub;
  
  function new(string name = "environment", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag = agent::type_id::create("ag", this);
    scb = scoreboard::type_id::create("scb", this);
    sub = subscriber::type_id::create("sub", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ag.mon.item_collected_port.connect(scb.item_collected_imp);
    ag.mon.item_collected_port.connect(sub.mon_port);
    ag.drv.item_collected_port.connect(sub.drv_port);
  endfunction
  
endclass
