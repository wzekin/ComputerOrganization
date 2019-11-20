// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

//module alu(X,Y,S,Out,CF,ZF,SF,OF);
module controller(
         input [63:0] pc,
         input w1,w2,w3,w4,w5,w6,
         input cf,zf,sf,of,
         input [3:0] code,ifun,rA,rB,
         output abus,mbus,rbus,pbus,cbus,
         output mem_R_W,reg_R_W,
         output pc_update,icode_update,
         output mem_loc_valA,mem_loc_valE,
         output need_valC,need_add_eight,need_sub_eight,
         output [3:0] ALU_Sel, regA,regB
       );

wire cc;



//常量定义
//icode常量
parameter HALT=8'h0;
parameter NOP=8'h1;
parameter IRMOVQ=8'h2;
parameter RRMOVQ=8'h3;
parameter MRMOVQ=8'h4;
parameter RMMOVQ=8'h5;
parameter OPQ=8'h6;
parameter JXX=8'h7;
parameter CALL=8'hA;
parameter RET=8'hB;

//跳转ifun常量
parameter JMP=8'h0;
parameter JE=8'h1;
parameter JNE=8'h2;
parameter JS=8'h3;
parameter JNS=8'h4;
parameter JG=8'h5;
parameter JGE=8'h6;
parameter JL=8'h7;
parameter JLE=8'h8;
parameter JA=8'h9;
parameter JAE=8'hA;
parameter JB=8'hB;
parameter JBE=8'hC;

//机器状态指令
parameter GOOD=2'b00;
parameter SHALT=2'b01;
parameter ERROR=2'b10;

parameter RSP=4'hE;

assign regB = ((w2 & (code == OPQ | code == RMMOVQ))
               | (w5 & ( code == OPQ | code == MRMOVQ | code == IRMOVQ | code == RRMOVQ))) ? rB :
       ((w2 | w5)& (code == CALL | code == RET)) ? RSP :
       (w5 & code == MRMOVQ) ? rA : 8'hF;
assign regA = (w2 & (code == OPQ | code == MRMOVQ | code == RRMOVQ | code == RMMOVQ )) ? rA :
       (w2 & code == RET) ? RSP : 8'hF;
assign reg_R_W = (w5 & (code == OPQ | code == MRMOVQ | code == IRMOVQ | code == RRMOVQ | code == CALL | code == RET));
assign mem_R_W = (w4 & (code == CALL | code == RMMOVQ));
assign icode_update = w1;
assign pc_update = w6;
assign ALU_Sel = (code == OPQ) ? ifun :
       (code == CALL | code == RET| code == MRMOVQ | code == RMMOVQ) ? 4'h1 : 4'h0;

assign need_valC = code == IRMOVQ | code == RMMOVQ;
assign need_add_eight = code == RET;
assign need_sub_eight = code == CALL;

assign mem_loc_valA = code == RET;
assign mem_loc_valE = code == RMMOVQ & code == MRMOVQ & code == CALL;

assign cc = ifun == JMP |
       (ifun == JE & zf) |
       (ifun == JNE & ~zf) |
       (ifun == JS & sf) |
       (ifun == JNS & ~sf) |
       (ifun == JG & (~ (sf ^ of) & ~zf)) |
       (ifun == JGE & ~(sf ^ of)) |
       (ifun == JL & sf ^ of) |
       (ifun == JLE & (sf ^ of | zf)) |
       (ifun == JA & (~cf & ~zf)) |
       (ifun == JAE & ~cf) |
       (ifun == JB & cf) |
       (ifun == JBE & (cf | zf));

assign rbus = w4 & code == RMMOVQ;
assign pbus = (w4 & code == CALL) | (w6 & (code == NOP | code == OPQ | code == MRMOVQ | code == RRMOVQ | code == IRMOVQ | code == RMMOVQ | (code == JXX) &  ~cc));
assign abus = w5 & (code == CALL | code == RET | code == OPQ | code == IRMOVQ | code == RRMOVQ);
assign mbus = (w5 & code == MRMOVQ) | (w6 & code == RET);
assign cbus = w6 & (code == CALL | (code == JXX ) & cc);
endmodule
