`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/12/01 10:55:46
// Design Name:
// Module Name: cpu
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


module cpu(
         input t1,
         input t2,
         input t3,
         input reset,
         input block,
         input [1:0] interupt,
         input [31:0] mem_out,
         input [15:0] m_valM,
         output mem_write,
         output out_ready,
         output [15:0] out,
         output [15:0] f_pc,
         output [15:0] mem_addr,
         output [2:0] Stat
       );

//icode常量
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
parameter I_OUT=4'h8;


parameter F_NONE=8'hF;

//寄存器常量
parameter REG_RSP=8'hE;
parameter REG_NONE=8'hF;

//机器状态指令
parameter STATE_GOOD=3'b000; //运行良好
parameter STATE_HALT=3'b001; //停机
parameter STATE_ADR=3'b010; //地址错误
parameter STATE_INS=3'b011; //指令错误
parameter STATE_BUB=3'b100; //冒泡
parameter STATE_INT=3'b101; //冒泡

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

// interupt
reg [15:0] pc_interupt;
reg interupt_state;

// part 1
reg f_int;
reg [15:0] F_predPC = 0;
wire [15:0] f_pred_PC,f_valC,f_valP;
wire [3:0] f_icode,f_ifun,f_rA,f_rB;
wire imem_error,instr_valid,need_regids,need_valC;
wire [2:0] f_stat;


// part 2
reg [2:0] D_stat;
reg [3:0] D_icode,D_ifun,D_rA,D_rB;
reg [15:0] D_valP,D_valC;
wire [3:0] d_srcA,d_srcB,d_dstE,d_dstM;
wire [15:0] d_rvalA,d_rvalB;
wire [15:0] d_valA,d_valB;

//part 3
reg cc;
reg [2:0] E_stat;
reg [3:0] E_icode,E_ifun,E_srcA,E_srcB,E_dstE,E_dstM;
reg [15:0] E_valC,E_valA,E_valB;
wire [15:0] aluA,aluB,e_valA,e_valE;
wire [3:0] alufun,e_dstE;
wire set_cc,e_Cnd;
wire cf,zf,sf,of;
reg e_cf,e_zf,e_sf,e_of;

//part 4
reg [2:0] M_stat;
reg [3:0] M_icode,M_ifun,M_dstE,M_dstM;
reg [15:0] M_valA,M_valE;
reg M_Cnd;
wire [2:0] m_stat;
wire dmem_error;

//part 5
reg [2:0] W_stat;
reg [3:0] W_icode,W_dstE,W_dstM;
reg [15:0] W_valE,W_valM;

//bubble
wire F_bubble,F_stall,D_bubble,D_stall,E_bubble,E_stall,M_stall,M_bubble,W_stall,W_bubble;

// interupt
wire reg_store,reg_reverse;

assign reg_store = W_stat == STATE_INT;
assign reg_reverse = W_icode == I_IRET;
assign out = M_valA;
assign out_ready = M_icode == I_OUT;

register reg_unit (
           .clk(t3),      // input wire clk
           .reset(reset),  // input wire reset
           .block(block),  // input wire block
           .M(W_valM),          // input wire [15 : 0] M
           .E(W_valE),          // input wire [15 : 0] E
           .srcA(d_srcA),    // input wire [3 : 0] srcA
           .srcB(d_srcB),    // input wire [3 : 0] srcB
           .dstM(W_dstM),    // input wire [3 : 0] dstM
           .dstE(W_dstE),    // input wire [3 : 0] dstE
           .valA(d_rvalA),    // output wire [15 : 0] valA
           .valB(d_rvalB),    // output wire [15 : 0] valB
           .store(reg_store),      // input wire store
           .reverse(reg_reverse)  // input wire reverse
         );

alu alu_unit (
      .aluA(aluA),    // input wire [15 : 0] aluA
      .aluB(aluB),    // input wire [15 : 0] aluB
      .ifun(alufun),    // input wire [3 : 0] ifun
      .clock(t3),  // input wire clock
      .cf(cf),        // output wire cf
      .zf(zf),        // output wire zf
      .sf(sf),        // output wire sf
      .of(of),        // output wire of
      .valE(e_valE)    // output wire [15 : 0] valE
    );

pipe_controller pipe_unit (
                  .E_icode(E_icode),    // input wire [3 : 0] E_icode
                  .D_icode(D_icode),    // input wire [3 : 0] D_icode
                  .M_icode(M_icode),    // input wire [3 : 0] M_icode
                  .E_dstM(E_dstM),      // input wire [3 : 0] E_dstM
                  .d_srcA(d_srcA),      // input wire [3 : 0] d_srcA
                  .d_srcB(d_srcB),      // input wire [3 : 0] d_srcB
                  .W_stat(W_stat),      // input wire [2 : 0] W_stat
                  .m_stat(m_stat),      // input wire [2 : 0] m_stat
                  .e_Cnd(e_Cnd),        // input wire e_Cnd
                  .F_bubble(F_bubble),  // output wire F_bubble
                  .F_stall(F_stall),    // output wire F_stall
                  .D_bubble(D_bubble),  // output wire D_bubble
                  .D_stall(D_stall),    // output wire D_stall
                  .E_bubble(E_bubble),  // output wire E_bubble
                  .E_stall(E_stall),    // output wire E_stall
                  .M_bubble(M_bubble),  // output wire M_bubble
                  .M_stall(M_stall),    // output wire M_stall
                  .W_bubble(W_bubble),  // output wire W_bubble
                  .W_stall(W_stall)    // output wire W_stall
                );
//part 1
always@(posedge t2)
  begin
    if (reset)
      begin
        interupt_state <= 0;
        pc_interupt <= 0;
        f_int <= 0;
        F_predPC <= 0;
      end
    else if ((interupt[0] | interupt[1]) & ~interupt_state)
      begin
        interupt_state <= 1;
        pc_interupt <= F_predPC;
        if (interupt[0])
        F_predPC <= 350;
        else if(interupt[1])
        F_predPC <= 300;
        f_int <= 1;
      end
    else if (D_icode == I_IRET)
      begin
        f_int <= 0;
        F_predPC <= pc_interupt;
        interupt_state <= 0;
      end
    else if (~F_stall & ~block & Stat == STATE_GOOD)
      begin
        F_predPC <= f_pred_PC;
        f_int <= 0;
      end
  end

assign imem_error = 0;
assign f_stat =
       imem_error ? STATE_ADR :
       f_int ? STATE_INT :
       (~instr_valid) ? STATE_INS :
       f_icode == I_HALT ? STATE_HALT :
       STATE_GOOD;

assign need_regids = f_icode == I_RRMOVQ
       | f_icode == I_OPQ
       | f_icode == I_PUSHQ
       | f_icode == I_POPQ
       | f_icode == I_IRMOVQ
       | f_icode == I_RMMOVQ
       | f_icode == I_MRMOVQ
       | f_icode == I_OUT;


assign need_valC = f_icode == I_IRMOVQ
       | f_icode == I_RMMOVQ
       | f_icode == I_MRMOVQ
       | f_icode == I_JXX
       | f_icode == I_CALL;

assign f_icode = mem_out[7:4];
assign f_ifun = mem_out[3:0];
assign f_valC = need_valC & need_regids ? mem_out[31:16] :
       need_valC ? mem_out[23:8] : 0;
assign f_valP = (f_icode == I_JXX | f_icode == I_CALL) ? f_pc + 3 :
       (f_icode == I_RET | f_icode == I_NOP) ? f_pc + 1 :
       (f_icode == I_OPQ | f_icode == I_RRMOVQ | f_icode == I_OUT) ? f_pc + 2 :
       (f_icode == I_MRMOVQ | f_icode == I_RMMOVQ | f_icode == I_IRMOVQ) ? f_pc + 4 : f_pc;
assign f_rA = need_regids ? mem_out[15:12] : 4'hF;
assign f_rB = need_regids ? mem_out[11:8] : 4'hF;

assign instr_valid = f_icode != 4'h9 & f_icode != 4'hF;
assign f_pc = (M_icode == I_JXX & !M_Cnd) ? M_valA :
       (W_icode == I_RET) ? W_valM :
       F_predPC;
assign f_pred_PC = (f_icode == I_JXX | f_icode == I_CALL) ? f_valC : f_valP;


//part 2
always@(posedge t2)
  begin
    if (D_bubble | reset)
      begin
        D_stat <= STATE_BUB;
        D_icode <= I_NOP;
        D_ifun <= F_NONE;
        D_rA <= REG_NONE;
        D_rB <= REG_NONE;
        D_valP <= 0;
        D_valC <= 0;
      end
    else if (~ D_stall & ~ block & Stat == STATE_GOOD)
      begin
        D_stat <= f_stat;
        D_icode <= f_icode;
        D_ifun <= f_ifun;
        D_rA <= f_rA;
        D_rB <= f_rB;
        D_valP <= f_valP;
        D_valC <= f_valC;
      end
  end

assign d_srcA =
       (D_icode == I_RRMOVQ | D_icode == I_RMMOVQ | D_icode == I_OPQ | D_icode == I_PUSHQ | D_icode == I_OUT) ? D_rA :
       (D_icode == I_POPQ | D_icode == I_RET) ? REG_RSP : REG_NONE;
assign d_srcB =
       (D_icode == I_MRMOVQ | D_icode == I_RMMOVQ | D_icode == I_OPQ) ? D_rB :
       (D_icode == I_PUSHQ | D_icode == I_POPQ | D_icode == I_CALL | D_icode == I_RET) ? REG_RSP : REG_NONE;
assign d_dstE =
       (D_icode == I_RRMOVQ | D_icode == I_IRMOVQ | D_icode == I_OPQ) ? D_rB:
       (D_icode == I_PUSHQ | D_icode == I_POPQ | D_icode == I_CALL | D_icode == I_RET) ? REG_RSP : REG_NONE;
assign d_dstM = (D_icode == I_MRMOVQ | D_icode == I_POPQ) ? D_rA : REG_NONE;
assign d_valA =
       (D_icode == I_CALL | D_icode == I_JXX) ? D_valP :
       (d_srcA == 4'hF) ? d_rvalA :
       (d_srcA == e_dstE) ? e_valE :
       (d_srcA == M_dstM) ? m_valM :
       (d_srcA == M_dstE) ? M_valE :
       (d_srcA == W_dstM) ? W_valM :
       (d_srcA == W_dstE) ? W_valE : d_rvalA;

assign d_valB =
       (d_srcB == 4'hF) ? d_rvalB :
       (d_srcB == e_dstE) ? e_valE :
       (d_srcB == M_dstM) ? m_valM :
       (d_srcB == M_dstE) ? M_valE :
       (d_srcB == W_dstM) ? W_valM :
       (d_srcB == W_dstE) ? W_valE : d_rvalB;


//part 3
always@(posedge t2)
  begin
    if (E_bubble | reset)
      begin
        E_stat <= STATE_BUB;
        E_icode <= I_NOP;
        E_ifun <= F_NONE;
        E_srcA <= REG_NONE;
        E_srcB <= REG_NONE;
        E_dstE <= REG_NONE;
        E_dstM <= REG_NONE;
        E_valA <= 0;
        E_valB <= 0;
        E_valC <= 0;
      end
    else if (~ E_stall & ~ block & Stat == STATE_GOOD)
      begin
        E_stat <= D_stat;
        E_icode <= D_icode;
        E_ifun <= D_ifun;
        E_srcA <= d_srcA;
        E_srcB <= d_srcB;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
        E_valA <= d_valA;
        E_valB <= d_valB;
        E_valC <= D_valC;
      end
    if(set_cc)
      begin
        e_cf <= cf;
        e_zf <= zf;
        e_sf <= sf;
        e_of <= of;
      end
  end


assign aluA =
       (E_icode == I_RRMOVQ | E_icode == I_OPQ) ? E_valA :
       (E_icode == I_IRMOVQ | E_icode == I_RMMOVQ | E_icode == I_MRMOVQ) ? E_valC :
       (E_icode == I_CALL | E_icode == I_PUSHQ) ? -8 :
       (E_icode == I_RET | E_icode == I_POPQ) ? 8 : 0;

assign aluB =
       (E_icode == I_RMMOVQ | E_icode == I_MRMOVQ | E_icode == I_OPQ | E_icode == I_CALL | E_icode == I_PUSHQ | E_icode == I_RET | E_icode == I_POPQ) ? E_valB : 0;

assign alufun = (E_icode == I_OPQ) ? E_ifun : 1;
assign set_cc = E_icode == I_OPQ & (m_stat == STATE_GOOD | m_stat== STATE_BUB) &  (W_stat == STATE_GOOD | W_stat== STATE_BUB);

assign e_valA = E_valA;
assign e_dstE = (E_icode == I_RRMOVQ & !e_Cnd) ? REG_NONE : E_dstE;
assign e_Cnd =
       E_ifun == JMP |
       (E_ifun == JE & e_zf) |
       (E_ifun == JNE & ~e_zf) |
       (E_ifun == JS & e_sf) |
       (E_ifun == JNS & ~e_sf) |
       (E_ifun == JG & (~ (e_sf ^ e_of) & ~e_zf)) |
       (E_ifun == JGE & ~(e_sf ^ e_of)) |
       (E_ifun == JL & e_sf ^ e_of) |
       (E_ifun == JLE & (e_sf ^ e_of | e_zf)) |
       (E_ifun == JA & (~e_cf & ~e_zf)) |
       (E_ifun == JAE & ~e_cf) |
       (E_ifun == JB & e_cf) |
       (E_ifun == JBE & (e_cf | e_zf));


//part 4
always@(posedge t2)
  begin
    if (M_bubble | reset)
      begin
        M_stat <= STATE_BUB;
        M_icode <= I_NOP;
        M_ifun <= F_NONE;
        M_dstE <= REG_NONE;
        M_dstM <= REG_NONE;
        M_valA <= 0;
        M_valE <= 0;
        M_Cnd <= 0;
      end
    else if(~block & ~M_stall & Stat == STATE_GOOD)
      begin
        M_stat <= E_stat;
        M_icode <= E_icode;
        M_ifun <= E_ifun;
        M_dstE <= E_dstE;
        M_dstM <= E_dstM;
        M_valA <= E_valA;
        M_valE <= e_valE;
        M_Cnd <= e_Cnd;
      end
  end


assign dmem_error = 0;
assign mem_addr =
       (M_icode == I_RMMOVQ | M_icode == I_PUSHQ | M_icode == I_CALL | M_icode == I_MRMOVQ) ? M_valE :
       (M_icode == I_POPQ | M_icode == I_RET) ? M_valA : 0;
assign mem_write = M_icode == I_RMMOVQ | M_icode == I_PUSHQ | M_icode == I_CALL;
assign m_stat = (dmem_error) ? STATE_ADR : M_stat;


//part 5
always@(posedge t2)
  begin
    if (reset | W_bubble)
      W_stat <= STATE_GOOD;
    W_icode <= I_NOP;
    W_dstE <= REG_NONE;
    W_dstM <= REG_NONE;
    W_valE <= 0;
    W_valM <= 0;
    if (~W_stall & ~block & Stat == STATE_GOOD)
      begin
        W_stat <= m_stat;
        W_icode <= M_icode;
        W_dstE <= M_dstE;
        W_dstM <= M_dstM;
        W_valE <= M_valE;
        W_valM <= m_valM;
      end
  end

//stat
assign Stat = (W_stat == STATE_BUB | W_stat == STATE_INT) ? STATE_GOOD : W_stat;
endmodule
