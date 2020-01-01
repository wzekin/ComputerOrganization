`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/12/01 10:26:56
// Design Name:
// Module Name: pipe_controller
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


module pipe_controller(
         input [3:0] E_icode,D_icode,M_icode,
         input [3:0] E_dstM,d_srcA,d_srcB,
         input [2:0] W_stat,m_stat,
         input e_Cnd,
         output F_bubble,F_stall,
         output D_bubble,D_stall,
         output E_bubble,E_stall,
         output M_bubble,M_stall,
         output W_bubble,W_stall
       );
parameter I_HALT=4'h0;
parameter I_NOP=4'h1;
parameter I_IRMOVQ=4'h2;
parameter I_RRMOVQ=4'h3;
parameter I_MRMOVQ=4'h4;
parameter I_RMMOVQ=4'h5;
parameter I_OPQ=4'h6;
parameter I_JXX=4'h7;
parameter I_CALL=4'hA;
parameter I_RET=4'hB;
parameter I_PUSHQ=4'hC;
parameter I_POPQ=4'hD;
parameter I_IRET=4'hE;

parameter F_NONE=4'hF;

//寄存器常量
parameter REG_RSP=4'hE;
parameter REG_NONE=4'hF;

//机器状态指令
parameter STATE_GOOD=3'b000; //运行良好
parameter STATE_HALT=3'b001; //停机
parameter STATE_ADR=3'b010; //地址错误
parameter STATE_INS=3'b011; //指令错误
parameter STATE_BUB=3'b100; //冒泡

//跳转ifun常量
parameter JMP=4'h0;
parameter JE=4'h1;
parameter JNE=4'h2;
parameter JS=4'h3;
parameter JNS=4'h4;
parameter JG=4'h5;
parameter JGE=4'h6;
parameter JL=4'h7;
parameter JLE=4'h8;
parameter JA=4'h9;
parameter JAE=4'hA;
parameter JB=4'hB;
parameter JBE=4'hC;

//buble
assign F_bubble = 0;
assign F_stall =
       ((E_icode == I_MRMOVQ | E_icode == I_POPQ) & (E_dstM == d_srcA | E_dstM == d_srcB))
       | D_icode == I_RET | D_icode == I_IRET
       | E_icode == I_RET | E_icode == I_IRET
       | M_icode == I_RET | M_icode == I_IRET;
assign D_stall =
       (E_icode == I_MRMOVQ | E_icode == I_POPQ)
       & (E_dstM == d_srcA | E_dstM == d_srcB);
assign D_bubble = (E_icode == I_JXX & !e_Cnd)
       | (~ D_stall & (
            | D_icode == I_RET | D_icode == I_IRET
            | E_icode == I_RET | E_icode == I_IRET
            | M_icode == I_RET | M_icode == I_IRET
          ));
assign E_stall = 0;
assign E_bubble =
       (E_icode == I_JXX & !e_Cnd)
       | ((E_icode == I_MRMOVQ | E_icode == I_POPQ) & (E_dstM == d_srcA | E_dstM == d_srcB));
assign M_stall = 0;
assign M_bubble = m_stat == STATE_ADR
       | m_stat == STATE_INS
       | m_stat == STATE_HALT
       | W_stat == STATE_ADR
       | W_stat == STATE_INS
       | W_stat == STATE_HALT;
assign W_stall =
       W_stat == STATE_ADR
       | W_stat == STATE_INS
       | W_stat == STATE_HALT;
assign W_bubble = 0;
endmodule
