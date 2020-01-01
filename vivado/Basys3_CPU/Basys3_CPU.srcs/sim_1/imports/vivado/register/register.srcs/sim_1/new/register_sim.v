`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/29 23:24:43
// Design Name: 
// Module Name: register_sim
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


module register_sim;
reg clk,reset,block,store,reverse;
reg [15:0] M,E;
reg [3:0] srcA,srcB,dstM,dstE;
wire [15:0] valA,valB;
register reg_unit(
  .clk(clk),
  .reset(reset),
  .block(block),
  .store(store),
  .reverse(reverse),
  .M(M),
  .E(E),
  .srcA(srcA),
  .srcB(srcB),
  .dstM(dstM),
  .dstE(dstE),
  .valA(valA),
  .valB(valB)
);

always #1 clk = ~clk;
initial 
  begin
    clk = 0;
    reset = 1;
    store = 0;
    reverse = 0;
    block = 0;
    dstM = 4'hF;
    dstE = 4'hF;
    srcA = 3;
    srcB = 3;
    M = 4;
    E = 2;
    #200;
    reset = 0;
    #2
    store = 1;
    #2;
    store = 0;
    M = 1;
    dstM = 4'h2;
    #2;
    srcA = 2;
    dstM = 4'hF;
    #2;
    reverse = 1;
    #2
    reverse = 0;
    block = 1;
    #2;
    srcB = 4;
    #2;
    $finish;
  end
endmodule
