class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  virtual alu_if.MON vif;
  uvm_analysis_port #(sequence_item) item_collected_port;
  
  sequence_item received_item;
  
  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    received_item = new("received_item");
    item_collected_port = new("item_collected_port", this);
  endfunction
  
  task get_inp_from_if();
//     `uvm_info("MON INPUTS", $sformatf("rst = %0d, ce = %0d, opa = %0d, OPB = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", vif.RST, vif.mon_cb.CE, vif.mon_cb.OPA, vif.mon_cb.OPB, vif.mon_cb.CIN, vif.mon_cb.CMD, vif.mon_cb.MODE, vif.mon_cb.INP_VALID), UVM_NONE);
    received_item.OPA = vif.mon_cb.OPA;
    received_item.OPB = vif.mon_cb.OPB;
    received_item.CE = vif.mon_cb.CE;
    received_item.CMD = vif.mon_cb.CMD;
    received_item.MODE = vif.mon_cb.MODE;
    received_item.INP_VALID = vif.mon_cb.INP_VALID;
    received_item.CIN = vif.mon_cb.CIN;
  endtask
  
  task receive_outputs();
//    repeat(1) @(posedge vif.CLK);
//     `uvm_info("MON OUTPUTS", $sformatf("RES = %0d, ERR = %0d, COUT = %0d, oflow = %0d, g = %0b, l = %0b, e = %0b", vif.mon_cb.RES, vif.mon_cb.ERR, vif.mon_cb.COUT, vif.mon_cb.OFLOW, vif.mon_cb.G, vif.mon_cb.L, vif.mon_cb.E), UVM_LOW);  	
    received_item.RES = vif.mon_cb.RES;
    received_item.COUT = vif.mon_cb.COUT;
    received_item.ERR = vif.mon_cb.ERR;
    received_item.OFLOW = vif.mon_cb.OFLOW;
    received_item.G = vif.mon_cb.G;
    received_item.L = vif.mon_cb.L;
    received_item.E = vif.mon_cb.E;
  endtask
  
  task receive();
    repeat(1) @(posedge vif.CLK);
    get_inp_from_if();
    repeat(1) @(posedge vif.CLK);
    if(received_item.INP_VALID == 2'b11 || received_item.INP_VALID == 2'b00) begin
      if((received_item.CMD == `INC_MUL || received_item.CMD == `SHL1_MUL) && (received_item.MODE) && (received_item.INP_VALID == 2'b11))
        repeat(1) @(posedge vif.CLK);
    end
    else begin		//INP_VALID == 01 or 10
      if(((received_item.MODE == 1) && (received_item.CMD inside {[4:7]})) || ((received_item.MODE == 0) && (received_item.CMD inside {[6:11]}))) begin
        receive_outputs();
      end
      else begin
        bit found = 0;
        for(int cycle = 0; cycle < 16; cycle++) begin
          get_inp_from_if();
          repeat(1) @(posedge vif.CLK);
          if(received_item.INP_VALID == 2'b11) begin
            found = 1;
            if((received_item.CMD == `INC_MUL || received_item.CMD == `SHL1_MUL) && (received_item.MODE))
        	  repeat(1) @(posedge vif.CLK);
            break;
          end
        end
        if(!found) 
          `uvm_info("MONITOR LOOP", "Loop Timeout", UVM_NONE);
      end
    end
    receive_outputs();
    item_collected_port.write(received_item);
    repeat(1) @(posedge vif.CLK);
  endtask
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
       `uvm_fatal("ERR","Could not retrieve retrieve virtual interface in monitor");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    repeat(4) @(posedge vif.CLK);
    forever begin
      receive();
    end
  endtask
  
endclass
