`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/12/01 14:34:38
// Design Name:
// Module Name: cpu_sim
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


module cpu_sim(

       );
reg clk,reset,block;
reg reset1;
reg [1:0] interupt;
wire [15:0] out;
wire out_ready;
wire [2:0] Stat;
wire [15:0] m_valM,mem_addr,f_pc,mem_m_out;
wire [31:0] mem_out;
wire t1,t2,t3;
wire mem_write;

cpu cpu_unit (
      .t1(t1),                // input wire t1
      .t2(t2),                // input wire t2
      .t3(t3),                // input wire t3
      .reset(reset),          // input wire reset
      .block(block),          // input wire block
      .interupt(interupt),    // input wire interupt
      .mem_out(mem_out),      // input wire [31 : 0] mem_out
      .m_valM(m_valM),        // input wire [15 : 0] m_valM
      .mem_write(mem_write),  // output wire mem_write
      .out_ready(out_ready),  // output wire out_ready
      .out(out),              // output wire [15 : 0] out
      .f_pc(f_pc),            // output wire [15 : 0] f_pc
      .mem_addr(mem_addr),    // output wire [15 : 0] mem_addr
      .Stat(Stat)            // output wire [2 : 0] Stat
    );

memory mem_unit (
         .mem_addr(mem_addr),  // input wire [15 : 0] mem_addr
         .pc(f_pc),              // input wire [15 : 0] pc
         .val(out),            // input wire [15 : 0] val
         .R_W(mem_write),            // input wire R_W
         .clock(t3),        // input wire clock
         .reset(reset),        // input wire reset
         .m_out(mem_m_out),        // output wire [15 : 0] m_out
         .pc_out(mem_out)      // output wire [31 : 0] pc_out
       );

counter counter (
          .clk(clk),      // input wire clk
          .reset(reset1),  // input wire reset
          .block(block),  // input wire block
          .t1(t1),        // output wire t1
          .t2(t2),        // output wire t2
          .t3(t3)        // output wire t3
        );


reg [15:0] keyboard_input;
reg [15:0] out_reg;

assign m_valM = mem_addr == 1024 ? keyboard_input : mem_m_out;

always #5 clk = ~clk;

always@(posedge out_ready)
begin
    $display(out);
end


initial
  begin
    clk = 0;
    reset = 1;
    reset1 = 1;
    block = 0;
    interupt = 0;
    #100;
    reset1 = 0;
    #100;
    reset = 0;
    #300;
    keyboard_input = 100;
    interupt = 1;
    #60;
    interupt = 0;
    #1000;
     keyboard_input = 200;
     interupt = 1;
     #60;
     interupt = 0;
     #1000;
     keyboard_input = 300;
     interupt = 1;
     #60;
     interupt = 0;
     #1000;
     interupt = 2;
     #60;
     interupt = 0;
     #1000;
    $finish;
  end
endmodule
