`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 14:42:14
// Design Name: 
// Module Name: alu_sim
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


module alu_sim;
reg [15:0] aluA,aluB;
reg [3:0] ifun;
reg clk;
wire cf,zf,sf,of;
wire [15:0] valE;

alu alu_unit(
     .aluA(aluA),
     .aluB(aluB),
     .ifun(ifun),
     .clock(clk),
     .cf(cf),
     .zf(zf),
     .sf(sf),
     .of(of),
     .valE(valE)
 );

always #16 clk = ~clk;
initial
begin
  clk = 1;
  aluA = 0;
  aluB = 0;
  ifun = 0;
  #176;
  aluA = 16'hFFFF;
  aluB = 2;
  ifun = 1;
  #32;
  aluA = 1;
  aluB = 1;
  ifun = 2;
  #32;
  aluA = -10;
  aluB = -30;
  ifun = 1;
  #32;
  aluA = 16'h7FFF;
  aluB = 16'h7FFF;
  ifun = 1;
  #50;
  $finish;
end
endmodule
