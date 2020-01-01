`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Varun Kondagunturi
//
// Create Date:    17:08:26 06/12/2014
// Design Name:
// Module Name:    Abacus_Top_Module
// Project Name:
// Target Devices:
// Tool versions:
//
//
// Description:
//This is the Top-Level Source file for the Abacus Project.
//Slide switches provide two 8-bit binary inputs A and B.
//Slide Switches [15 down to 8] is input A.
//Slide Switches [7 down to 0] is input B.
//Inputs from the Push Buttons ( btnU, btnD, btnR, btnL) will allow the user to select different arithmetic operations that will be computed on the inputs A and B.
//btnU: Subtraction/Difference. Result will Scroll
//When A>B, difference is positive.
//When A<B, difference is negative. If the button is not held down but just pressed once, the result will scroll. To find out if the result is negative, press and hold onto the push button btnU. This will show the negative sign.
//btnD: Multiplication/Product. Result will Scroll
//btnR: Quotient(Division Operation). Press and Hold the button to display result
//btnL: Remainder ( Division Operation). Press and Hold the button to display result
//Output is displayed on the 7 segment LED display.
//
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Basys3_Abacus_Top(

         //CLK Input
         input clk,

         //Push Button Inputs
         input btnC,
         input btnU,
         input btnD,
         input btnR,
         input btnL,

         // Slide Switch Inputs
         // Input A = sw[15:8]
         //Input B = sw[7:0]
         input [15:0] sw,

         // LED Outputs
         output [15:0] led,

         // Seven Segment Display Outputs
         output [6:0] seg,
         output [3:0] an,
         output dp,

         input         PS2Data,
         input         PS2Clk,
         output        tx

       );
reg clk50;
always@(posedge clk)
  begin
    clk50 = ~clk50;
  end

wire t1,t2,t3;
wire [2:0] Stat;
wire [15:0] m_valM,mem_addr,f_pc,mem_m_out,keycode;
wire [31:0] mem_out;
wire [15:0] out;
wire        tready;
wire        ready;
wire        tstart;
wire [31:0] tbuf;
wire [ 7:0] tbus;
wire out_ready;
wire mem_write;
wire flag;
reg  [15:0] keycodev;
reg  [ 2:0] bcount;
reg         cn;
reg         start;
wire [1:0] interupt;
cpu cpu_unit (
      .t1(t1),                // input wire t1
      .t2(t2),                // input wire t2
      .t3(t3),                // input wire t3
      .reset(btnL),          // input wire reset
      .block(btnD),          // input wire block
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
         .reset(btnL),        // input wire reset
         .m_out(mem_m_out),        // output wire [15 : 0] m_out
         .pc_out(mem_out)      // output wire [31 : 0] pc_out
       );

counter counter (
          .clk(clk50),      // input wire clk
          .reset(btnC),  // input wire reset
          .block(btnD),  // input wire block
          .t1(t1),        // output wire t1
          .t2(t2),        // output wire t2
          .t3(t3)        // output wire t3
        );

PS2Receiver uut (
              .clk(t1),
              .kclk(PS2Clk),
              .kdata(PS2Data),
              .keycode(keycode),
              .oflag(flag)
            );

bin2ascii #(
            .NBYTES(2)
          ) conv (
            .I(out),
            .O(tbuf)
          );

uart_buf_con tx_con (
               .clk    (clk),
               .bcount (3'd5),
               .tbuf   (tbuf),
               .start  (out_ready ),
               .ready  (ready ),
               .tstart (tstart),
               .tready (tready),
               .tbus   (tbus  )
             );

uart_tx get_tx (
          .clk    (clk),
          .start  (tstart),
          .tbus   (tbus),
          .tx     (tx),
          .ready  (tready)
        );

always@(keycode)
  if (keycode[7:0] == 8'hf0)
    begin
      cn <= 1'b0;
      bcount <= 3'd0;
    end
  else if (keycode[15:8] == 8'hf0)
    begin
      cn <= 0;
      bcount <= 3'd5;
    end
  else
    begin
      cn <= keycode[7:0] != keycodev[7:0] || keycodev[15:8] == 8'hf0;
      bcount <= 3'd2;
    end


reg btnR_,btnR_cn;
always@(posedge t2)
begin
  if (flag == 1'b1 && cn == 1'b1)
    begin
      start <= 1'b1;
      keycodev <= keycode;
    end
  else
    start <= 1'b0;
  
  btnR_ <= btnR && btnR_cn; 
  btnR_cn <= ~btnR;
end

assign interupt[0] = start;
assign interupt[1] = btnR_;
assign m_valM = mem_addr == 1024 ? {8'h00,keycodev[7:0]} : mem_m_out;
assign led = keycodev;
endmodule
