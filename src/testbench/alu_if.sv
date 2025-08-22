`include "defines.sv"

interface alu_if(input logic CLK, RST);
  bit 			     CE;
  bit 				 MODE;
  bit [1:0] 		 INP_VALID;
  bit [`C_WIDTH-1:0] CMD;
  bit [`WIDTH-1:0] 	 OPA;
  bit [`WIDTH-1:0] 	 OPB;
  bit 				 CIN;
  bit [`RES_WIDTH-1:0] RES;
  bit 				 COUT, OFLOW, G, L, E;
  bit 				 ERR;
  
  clocking drv_cb @(posedge CLK);
    default input #0 output #0;
    output CE, MODE, INP_VALID, CMD, OPA, OPB, CIN;
  endclocking
  
  clocking mon_cb @(posedge CLK);
    default input #0 output #0;
    input CE, MODE, INP_VALID, CMD, OPA, OPB, CIN, RES, COUT, OFLOW, G, L, E, ERR;
  endclocking
  
  modport DRV (clocking drv_cb, input CLK, RST);
  modport MON (clocking mon_cb, input CLK, RST);
  
endinterface
