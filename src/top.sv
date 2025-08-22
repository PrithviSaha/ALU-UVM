//`include "uvm_pkg.sv"
`include "uvm_macros.svh"
`include "alu_pkg.sv"
`include "alu_if.sv"
`include "design.sv"
`include "alu_assertions.sv"

module top;
  import uvm_pkg::*;  
  import alu_pkg::*;
  
  bit CLK, RST;
  //int ERR;
  initial begin
  	forever #5 CLK = ~CLK;
  end
  
  alu_if vif(CLK, RST);

  ALU_DESIGN dut(.CE(vif.CE), .INP_VALID(vif.INP_VALID), .OPA(vif.OPA), .OPB(vif.OPB), .CIN(vif.CIN), .CLK(CLK), .RST(RST), .CMD(vif.CMD), .MODE(vif.MODE), .COUT(vif.COUT), .OFLOW(vif.OFLOW), .RES(vif.RES), .G(vif.G), .E(vif.E), .L(vif.L), .ERR(vif.ERR));
  
  //Bind assertions
  bind ALU_DESIGN alu_assertions alu_ass(
        .CLK(CLK),
        .RST(RST),
        .CE(vif.CE),
        .MODE(vif.MODE),
        .CMD(vif.CMD),
        .INP_VALID(vif.INP_VALID),
        .CIN(vif.CIN),
        .OPA(vif.OPA),
        .OPB(vif.OPB),
        .RES(vif.RES),
        .COUT(vif.COUT),
        .OFLOW(vif.OFLOW),
        .G(vif.G),
        .L(vif.L),
        .E(vif.E),
        .ERR(vif.ERR)
  );
  
  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif", vif);
    //uvm_config_db#(int)::set(null, "*", "ERR", ERR);
    run_test("regression_test");
    #10;
    $finish;
  end
  initial begin
    repeat(1)@(posedge CLK);
    RST <= 1;
    @(posedge CLK);
    RST <= 0;
  end
  initial begin
    CLK = 0;
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
