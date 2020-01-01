`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/11/29 23:14:25
// Design Name:
// Module Name: register
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module register(
         input clk,
         input reset,
         input block,
         input store,
         input reverse,
         input [15:0] M,E,
         input [3:0] srcA,srcB,dstM,dstE,
         output [15:0] valA,valB
       );

reg [15:0] r[14:0],r_backup[14:0];
reg [15:0] v_A,v_B;

assign valA = v_A;
assign valB = v_B;

integer i;
always@(posedge clk)
  begin
    if(clk & store)
      begin
        for(i = 0;i<15; i= i + 1)
          r_backup[i] <= r[i];
      end
    else if(clk & reverse)
      begin
        for(i = 0;i<15; i= i + 1)
          r[i] <= r_backup[i];
      end
    if (reset)
      begin
        for(i = 0;i<15; i= i + 1)
          r[i] <= 0;
        v_A <= 0;
        v_B <= 0;
      end
    else if(clk & ~block)
      begin
        if (dstM != 4'hF)
          r[dstM] <= M;
        if (dstE != 4'hF)
          r[dstE] <= E;
        if (srcA != 4'hF)
          v_A <= r[srcA];
        if (srcB != 4'hF)
          v_B <= r[srcB];
      end

  end

endmodule
