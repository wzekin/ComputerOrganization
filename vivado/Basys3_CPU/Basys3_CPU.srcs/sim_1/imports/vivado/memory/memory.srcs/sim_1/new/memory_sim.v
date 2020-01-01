`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/30 16:00:40
// Design Name: 
// Module Name: memory_sim
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


module memory_sim;
reg [15:0] mem_addr,val,pc;
reg R_W;
reg clock;
reg reset;
wire [15:0] m_out;
wire [31:0] pc_out;

memory mem_unit(
         .mem_addr(mem_addr),
         .pc(pc),
         .val(val),
         .R_W(R_W),
         .clock(clock),
         .reset(reset),
         .m_out(m_out),
         .pc_out(pc_out)
       );

always #10 clock = ~clock;
initial
begin
    mem_addr = 0;
    pc = 0;
    val = 0;
    R_W = 0;
    clock = 0;
    reset = 1;
    #100;
    reset = 0;
    pc = 2;
    mem_addr = 4;
    #20;
    R_W = 1;
    mem_addr = 2;
    val = 5;
    #40;
    $finish;
end

endmodule
