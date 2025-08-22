`uvm_analysis_imp_decl(_mon_cg)
`uvm_analysis_imp_decl(_drv_cg)

class subscriber extends uvm_component;
  `uvm_component_utils(subscriber)
  
  uvm_analysis_imp_mon_cg #(sequence_item, subscriber) mon_port;
  uvm_analysis_imp_drv_cg #(sequence_item, subscriber) drv_port;
  
  sequence_item drv_txn, mon_txn;
  
  real drv_cov, mon_cov;
  
  //INPUT FUNCTIONAL COVERAGE
  covergroup drv_cg;
    MODE_CP      : coverpoint drv_txn.MODE { bins mode_bins[] = {0,1}; }
    CMD_CP       : coverpoint drv_txn.CMD { bins cmd_bins[] = {[0:13]}; }
    INP_VALID_CP : coverpoint drv_txn.INP_VALID { bins ip_valid_bins[] = {[0:3]}; }
    CIN_CP       : coverpoint drv_txn.CIN { bins cin[] = {0,1}; }
    CE_CP        : coverpoint drv_txn.CE { bins ce_bins[] = {0,1}; }

    MODE_CP_X_CMD_CP : cross MODE_CP, CMD_CP;
    CMD_CP_X_INP_VALID_CP : cross CMD_CP, INP_VALID_CP;
    MODE_CP_X_INP_VALID_CP : cross MODE_CP, INP_VALID_CP;
  endgroup
  
  //DUV OUTPUT COVERAGE
  covergroup mon_cg;
    COUT_CHECK  : coverpoint mon_txn.COUT { bins cout_bins[] = {0,1}; }
    ERR_CHECK   : coverpoint mon_txn.ERR { bins err_bins[] = {0,1}; }
    OFLOW_CHECK : coverpoint mon_txn.OFLOW { bins oflow_bins[] = {0,1}; }

    G_CHECK     : coverpoint mon_txn.G {
                        wildcard bins g_bins = {'z,1};
                        ignore_bins i_zero1 = {0};
                  }
    L_CHECK     : coverpoint mon_txn.L {
                        wildcard bins l_bins = {'z,1};
                        ignore_bins i_zero2 = {0};
                  }

    RES_CHECK   : coverpoint mon_txn.RES {
                        bins res1 = {0};
                        bins res2 = { {(`WIDTH){1'b1}} };
                        bins res3 = default;
                  }
  endgroup
  
  function new(string name = "subscriber", uvm_component parent = null);
    super.new(name, parent);
    drv_cg = new();
    mon_cg = new();
    mon_port = new("mon_port", this);
    drv_port = new("drv_port", this);
  endfunction
  
  function void write_drv_cg(sequence_item t);
    drv_txn = t;
    drv_cg.sample();
  endfunction
  
  function void write_mon_cg(sequence_item t);
    mon_txn = t;
    mon_cg.sample();
  endfunction
  
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    drv_cov = drv_cg.get_coverage();
    mon_cov = mon_cg.get_coverage();
  endfunction
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name, $sformatf("[DRIVER] Coverage ------> %0.2f%%,", drv_cov), UVM_MEDIUM);
    `uvm_info(get_type_name, $sformatf("[MONITOR] Coverage ------> %0.2f%%", mon_cov), UVM_MEDIUM);
  endfunction
  
endclass
