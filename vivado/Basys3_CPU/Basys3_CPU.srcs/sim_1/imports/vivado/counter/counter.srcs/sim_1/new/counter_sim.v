`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/01 09:59:23
// Design Name: 
// Module Name: counter_sim
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


module counter_sim(

    );
    reg clk,reset,block;
    wire clk_out;
counter c(
         .clk(clk),
         .reset(reset),
         .block(block),
         .t1(t1),
         .t2(t2),
         .t3(t3)
       );
always #10 clk = ~clk;
initial 
begin
    clk = 0;
    reset = 1;
    block = 1;
    #200;
    reset = 0;
    #30;
    block = 0;
    #100;
    $finish;
end
endmodule
