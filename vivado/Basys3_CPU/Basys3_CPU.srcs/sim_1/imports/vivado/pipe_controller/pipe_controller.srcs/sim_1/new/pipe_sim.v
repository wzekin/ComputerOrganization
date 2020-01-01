`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/01 10:39:49
// Design Name: 
// Module Name: pipe_sim
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


module pipe_sim(

    );
    reg [3:0] E_icode,D_icode,M_icode,E_dstM,d_srcA,d_srcB,W_stat,m_stat,e_Cnd;
    pipe_controller pipe_unit(
        .E_icode(E_icode),
        .D_icode(D_icode),
        .M_icode(M_icode),
        .E_dstM(E_dstM),
        .d_srcA(d_srcA),
        .d_srcB(d_srcB),
        .W_stat(W_stat),
        .m_stat(m_stat),
        .e_Cnd(e_Cnd),
        .F_bubble(F_bubble),
        .F_stall(F_stall),
        .D_bubble(D_bubble),
        .D_stall(D_stall),
        .E_bubble(E_bubble),
        .E_stall(E_stall),
        .M_bubble(M_bubble),
        .M_stall(M_stall),
        .W_bubble(W_bubble),
        .W_stall(W_stall)
    );
endmodule
