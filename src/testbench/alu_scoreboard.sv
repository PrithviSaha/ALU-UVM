
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(sequence_item, scoreboard) item_collected_imp;
  sequence_item q[$];
  //int err[$];
  sequence_item dut_item, ref_item;
  virtual alu_if vif;
  int PASS, FAIL;
  
  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    item_collected_imp = new("item_collected_imp", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("SCORE ERR", "Cannot retrieve virtual interface");
  endfunction
  
  virtual function void write(sequence_item pkt);
    q.push_back(pkt);
  endfunction
  
//   virtual function void put(int e);
//     err.push_back(e);
//   endfunction
  
  task alu_ops(sequence_item pkt, sequence_item pkt2);
//     `uvm_info("SCOREBOARD", "Scoreboard Calculating Results", UVM_LOW);
	if(vif.RST)begin
      pkt2.RES = 0;
      pkt2.OFLOW = 0;
      pkt2.COUT = 0;
      pkt2.G = 0;
      pkt2.L = 0;
      pkt2.E = 0;
      pkt2.ERR = 0;
      $display("Reset");
    end
    else if (pkt.CE)begin
    //reseting the outputs
      pkt2.RES = 9'bz;
      pkt2.OFLOW = 1'bz;
      pkt2.COUT = 1'bz;
      pkt2.G = 1'bz;
      pkt2.L = 1'bz;
      pkt2.E = 1'bz;
      pkt2.ERR = 1'bz;
      if(pkt.MODE == 1)begin //arithmetic
        case(pkt.INP_VALID)
          2'b00:begin
            pkt2.ERR = 1;
          end
          2'b01:begin //only a valid
            case(pkt.CMD)
              4'b0100:begin //inc_a
                pkt2.RES = pkt.OPA + 1;
              end
              4'b0101:begin //dec_a
                pkt2.RES = pkt.OPA - 1;
              end
              default : pkt2.ERR = 1;
            endcase
          end
          2'b10:begin //only a valid
            case(pkt2.CMD)
              4'b0110:begin //inc_a
                pkt2.RES = pkt.OPB + 1;
              end
              4'b0111:begin //dec_a
                pkt2.RES = pkt.OPB - 1;
              end
              default : pkt2.ERR = 1;
            endcase
          end
          2'b11:begin
            case(pkt.CMD)
              4'b0000:begin //add
                pkt2.RES = pkt.OPA + pkt.OPB;
                pkt2.COUT = pkt.RES[8];
              end
              4'b0001:begin //sub
                pkt2.RES = pkt.OPA - pkt.OPB;
                pkt2.OFLOW = (pkt.OPA < pkt.OPB);
              end
              4'b0010:begin //add_cin
                pkt2.RES = pkt.OPA + pkt.OPB + pkt.CIN;
                pkt2.COUT = pkt.RES[8];
              end
              4'b0011:begin //sub_cin
                pkt2.RES = pkt.OPA - pkt.OPB - pkt.CIN;
                pkt2.OFLOW = ((pkt.OPA <  pkt.OPB + pkt.CIN));
              end
              4'b0100:begin //inc_a
                pkt2.RES = pkt.OPA + 1;
                pkt2.COUT = pkt.RES[8];
              end
              4'b0101:begin //dec_a
                pkt2.RES = pkt.OPA - 1;
                pkt2.OFLOW = (pkt.OPA < 1);
              end
              4'b0110:begin //inc_a
                pkt2.RES = pkt.OPB + 1;
              end
              4'b0111:begin //dec_a
                pkt2.RES = pkt.OPB - 1;
                pkt2.OFLOW = (pkt.OPB < 1);
              end
              4'b1000:begin //cmp
                pkt2.G = (pkt.OPA > pkt.OPB) ? 1 : 1'bz;
                pkt2.L = (pkt.OPA < pkt.OPB) ? 1 : 1'bz;
                pkt2.E = (pkt.OPA == pkt.OPB) ? 1 : 1'bz;
              end
              4'b1001:begin //inc_mult
                pkt2.RES = (pkt.OPA + 1) * (pkt.OPB + 1);
              end
              4'b1010:begin //shift_a_mult
                pkt2.RES = (pkt.OPA << 1) * pkt.OPB;
              end
              default : pkt2.ERR = 1;
            endcase
          end
        endcase
      end
      else begin
        case(pkt.INP_VALID)
          2'b00: pkt2.ERR = 1;
          2'b01:begin //only a valid
            case(pkt.CMD)
              4'b0110:begin //not_a
                pkt2.RES = {1'b0, ~pkt.OPA};
              end
              4'b1000:begin //shr1_a
                pkt2.RES = {1'b0, pkt.OPA >> 1};
              end
              4'b1001:begin //shl1_a
                pkt2.RES = {1'b0, pkt.OPA << 1};
              end
              default: pkt2.ERR = 1;
            endcase
           end
           2'b10:begin //only b valid
             case(pkt.CMD)
               4'b0111:begin
                 pkt2.RES = {1'b0, ~pkt.OPB};
               end
               4'b1010:begin
                 pkt2.RES = {1'b0, pkt.OPB >> 1};
               end
               4'b1011:begin
                 pkt2.RES = {1'b0, pkt.OPB << 1};
               end
               default: pkt2.ERR = 1;
             endcase
           end
           2'b11:begin
             case(pkt.CMD)
               4'b0000:begin
                 pkt2.RES = pkt.OPA & pkt.OPB;
                 //$display("Enter inside add");
               end
               4'b0001:begin
                 pkt2.RES = {1'b0, ~(pkt.OPA & pkt.OPB)};
                 $display("Enter inside nand");
               end
               4'b0010:begin
                 pkt2.RES = pkt.OPA | pkt.OPB;
               end
               4'b0011:begin
                 pkt2.RES = {1'b0, ~(pkt.OPA | pkt.OPB)};
               end
               4'b0100:begin
                 pkt2.RES = pkt.OPA ^ pkt.OPB;
               end
               4'b0101:begin
                 pkt2.RES = {1'b0, ~(pkt.OPA ^ pkt.OPB)};
               end
               4'b0110:begin //not_a
                 pkt2.RES = {1'b0, ~pkt.OPA};
               end
               4'b0111:begin
                 pkt2.RES = {1'b0, ~pkt.OPB};
               end
               4'b1000:begin //shr1_a
                 pkt2.RES = {1'b0, pkt.OPA >> 1};
               end
               4'b1001:begin //shl1_a
                 pkt2.RES = {1'b0, pkt.OPA << 1};
               end
               4'b1010:begin
                 pkt2.RES = {1'b0, pkt.OPB >> 1};
               end
               4'b1011:begin
                 pkt2.RES = {1'b0, pkt.OPB << 1};
               end
               4'b1100:begin
                 if( |(pkt.OPB[`WIDTH - 1 : `SHIFT_WIDTH + 1]))begin
                   pkt2.ERR = 1;
                 end
                 else begin
                   pkt2.RES = (pkt.OPA << pkt.OPB[`SHIFT_WIDTH - 1 : 0]) | (pkt.OPA >> (`WIDTH - pkt.OPB[`SHIFT_WIDTH - 1 : 0]));
                   pkt.RES[8] = 0;
                 end
               end
               4'b1101:begin
                 if(|pkt.OPB[`WIDTH-1: `SHIFT_WIDTH + 1])begin
                   pkt2.ERR = 1;
                 end
                 else begin
                   pkt2.RES = (pkt.OPA >> pkt.OPB[`SHIFT_WIDTH - 1:0]) | (pkt.OPA << (`WIDTH - pkt.OPB[`SHIFT_WIDTH - 1: 0]));
                   pkt2.RES[8] = 0;
                 end
               end
               default : pkt2.ERR = 1;
            endcase
          end
        endcase
      end
    end    
  endtask
  
  
  task run_phase(uvm_phase phase);
//    int ERR;
    forever begin
      wait(q.size() > 0);
//       $display("[%0t] Arriving at scoreboard", $time);
      dut_item = q.pop_front();
      ref_item = sequence_item::type_id::create("ref_item", this);
      ref_item.copy(dut_item);
      alu_ops(dut_item, ref_item);
      //uvm_config_db#(int)::get(this, "", "ERR", ERR);
//       if(ERR == 1)begin
//         ref_item.ERR = ERR;
//       end
      `uvm_info("MON OUTPUTS IN SCB", $sformatf("cmd = %0d, res = %0d, err = %0d, cout = %0d, oflow = %0d, g = %0b, l = %0b, e = %0b", dut_item.CMD, dut_item.RES, dut_item.ERR, dut_item.COUT, dut_item.OFLOW, dut_item.G, dut_item.L, dut_item.E), UVM_LOW); 
      `uvm_info("REF OUTPUTS IN SCB", $sformatf("cmd = %0d, res = %0d, err = %0d, cout = %0d, oflow = %0d, g = %0b, l = %0b, e = %0b", ref_item.CMD, ref_item.RES, ref_item.ERR, ref_item.COUT, ref_item.OFLOW, ref_item.G, ref_item.L, ref_item.E), UVM_LOW);  	
      if(dut_item.compare(ref_item))begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        PASS++;
      end
      else begin
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        `uvm_info(get_type_name(), "----           TEST FAIL           ----", UVM_NONE)
        `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        FAIL++;
      end
      $display("--------------------------------------------------------------------------------------------------------------------------------------");
    end
    
    
  endtask 
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    $display("Passes = %0d | Fails = %0d", PASS, FAIL);
  endfunction
  
  
endclass
