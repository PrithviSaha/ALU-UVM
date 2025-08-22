class driver extends uvm_driver #(sequence_item);
  `uvm_component_utils(driver)

  virtual alu_if.DRV vif;
  uvm_analysis_port #(sequence_item) item_collected_port;	//port for coverage
  
  int COUNT;	//for no. of driver trans checking
  
  function new(string name = "driver", uvm_component parent = null);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("ERR", "Could not retrieve virtual interface in driver");
  endfunction

  task send_to_interface();
//     `uvm_info("DRIVER DRIVING DATA", $sformatf("ce = %0d, opa = %0d, opb = %0d, cin = %0d, cmd = %0d, mode = %0d, inp_valid = %0d", req.CE, req.OPA, req.OPB, req.CIN, req.CMD, req.MODE, req.INP_VALID), UVM_NONE);
    vif.drv_cb.CE <= req.CE;
    vif.drv_cb.INP_VALID <= req.INP_VALID;
    vif.drv_cb.MODE <= req.MODE;
    vif.drv_cb.CMD <= req.CMD;
    vif.drv_cb.OPA <= req.OPA;
    vif.drv_cb.OPB <= req.OPB;
    vif.drv_cb.CIN <= req.CIN;
    //repeat(1) @(posedge vif.CLK);
  endtask
  
  task drive();
    COUNT++;
    $display("[%0t] COUNT = %0d", $time, COUNT);
    if(req.INP_VALID == 2'b11 || req.INP_VALID == 2'b00) begin
      send_to_interface();
      repeat(1) @(posedge vif.CLK);
    end
    else begin		//INP_VALID == 01 or 10
      if(((req.MODE == 1) && (req.CMD inside {[4:7]})) || ((req.MODE == 0) && (req.CMD inside {[6:11]}))) begin
        send_to_interface();  
        repeat(1) @(posedge vif.CLK);
      end
      else begin
        send_to_interface();
        req.MODE.rand_mode(0);
        req.CE.rand_mode(0);
        req.CMD.rand_mode(0);
        for(int cycle = 0; cycle < 16; cycle++) begin
          repeat(1) @(posedge vif.CLK);
          assert(req.randomize());
          send_to_interface();
          if(req.INP_VALID == 2'b11) begin
//             send_to_interface();
            req.MODE.rand_mode(1);
            req.CE.rand_mode(1);
            req.CMD.rand_mode(1);
            repeat(1) @(posedge vif.CLK);
            break;
          end
        end
      end
    end
    if((req.CMD == `INC_MUL || req.CMD == `SHL1_MUL) && (req.MODE) && (req.INP_VALID == 2'b11))
      repeat(1) @(posedge vif.CLK);
    
    repeat(2) @(posedge vif.CLK);
    //repeat(2) @(posedge vif.CLK);	//drain_time
    item_collected_port.write(req);
  endtask
  
    
  task run_phase(uvm_phase phase);
    repeat(3) @(posedge vif.CLK);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
//       $display("TRANSFER DONE");
    end
  endtask
  
endclass
