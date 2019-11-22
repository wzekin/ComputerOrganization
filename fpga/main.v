module main;

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

// 取址阶段
reg [63:0] F_predPC = 0;
always@(posedge t2)
  begin
    if (~F_stall)
      F_predPC = f_pred_PC;
  end

wire [63:0] f_pc,f_pred_PC,f_valC,f_valP;
wire [3:0] f_icode,f_ifun,f_rA,f_rB;
wire imem_error,instr_valid,need_regids,need_valC;
wire [2:0] f_stat;

wire [79:0] mem_out;
//
assign imem_error = 0;
assign f_stat =
       imem_error ? STATE_ADR :
       (~instr_valid) ? STATE_INS :
       f_icode == I_HALT ? STATE_HALT :
       STATE_GOOD;

assign need_regids = f_icode == I_RRMOVQ
       | f_icode == I_OPQ
       | f_icode == I_PUSHQ
       | f_icode == I_POPQ
       | f_icode == I_IRMOVQ
       | f_icode == I_RMMOVQ
       | f_icode == I_MRMOVQ;


assign need_valC = f_icode == I_IRMOVQ
       | f_icode == I_RMMOVQ
       | f_icode == I_MRMOVQ
       | f_icode == I_JXX
       | f_icode == I_CALL;

assign f_icode = mem_out[7:4];
assign f_ifun = mem_out[3:0];
assign f_valC = need_valC & need_regids ? mem_out[79:16] :
       need_valC ? mem_out[71:8] : 0;
assign f_valP = (f_icode == I_JXX | f_icode == I_CALL) ? f_pc + 9 :
       (f_icode == I_RET | f_icode == I_NOP) ? f_pc + 1 :
       (f_icode == I_OPQ | f_icode == I_RRMOVQ) ? f_pc + 2 :
       (f_icode == I_MRMOVQ | f_icode == I_RMMOVQ | f_icode == I_IRMOVQ) ? f_pc + 10 : f_pc;
assign f_rA = need_regids ? mem_out[15:12] : 4'hF;
assign f_rB = need_regids ? mem_out[11:8] : 4'hF;

assign instr_valid = f_icode != 4'h8 & f_icode != 4'h9 & f_icode != 4'hE & f_icode != 4'hF;
assign f_pc = (M_icode == I_JXX & !M_Cnd) ? M_valA :
       (W_icode == I_RET) ? W_valM :
       F_predPC;
assign f_pred_PC = (f_icode == I_JXX | f_icode == I_CALL) ? f_valC : f_valP;

// 译码
reg [2:0] D_stat;
reg [3:0] D_icode,D_ifun,D_rA,D_rB;
reg [63:0] D_valP,D_valC;
always@(posedge t2)
  begin
    if (D_bubble)
      begin
        D_stat <= STATE_BUB;
        D_icode <= I_NOP;
        D_ifun <= F_NONE;
        D_rA <= REG_NONE;
        D_rB <= REG_NONE;
        D_valP <= 0;
        D_valC <= 0;
      end
    else if (D_stall)
      begin
      end
    else
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

wire [3:0] d_srcA,d_srcB,d_dstE,d_dstM;
wire [63:0] d_rvalA,d_rvalB;
wire [63:0] d_valA,d_valB;

assign d_srcA =
       (D_icode == I_RRMOVQ | D_icode == I_RMMOVQ | D_icode == I_OPQ | D_icode == I_PUSHQ) ? D_rA :
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

//执行
reg cc;
reg [2:0] E_stat;
reg [3:0] E_icode,E_ifun,E_srcA,E_srcB,E_dstE,E_dstM;
reg [63:0] E_valC,E_valA,E_valB;
always@(posedge t2)
  begin
    if (E_bubble)
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
    else if (E_stall)
      begin

      end
    else
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

wire [63:0] aluA,aluB,e_valA,e_valE;
wire [3:0] alufun,e_dstE;
wire set_cc,e_Cnd;
wire cf,zf,sf,of;
reg e_cf,e_zf,e_sf,e_of;

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

// 访存
reg [2:0] M_stat;
reg [3:0] M_icode,M_ifun,M_dstE,M_dstM;
reg [63:0] M_valA,M_valE;
reg M_Cnd;
always@(posedge t2)
  begin
    if (M_bubble)
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
    else
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

wire [63:0] m_valM,mem_addr;
wire [2:0] m_stat;
wire dmem_error;

assign dmem_error = 0;
assign mem_addr =
       (M_icode == I_RMMOVQ | M_icode == I_PUSHQ | M_icode == I_CALL | M_icode == I_MRMOVQ) ? M_valE :
       (M_icode == I_POPQ | M_icode == I_RET) ? M_valA : 0;
assign mem_write = M_icode == I_RMMOVQ | M_icode == I_PUSHQ | M_icode == I_CALL;
assign m_stat = (dmem_error) ? STATE_ADR : M_stat;


//写回
reg [2:0] W_stat;
reg [3:0] W_icode,W_dstE,W_dstM;
reg [63:0] W_valE,W_valM;

always@(posedge t2)
  begin
    if (!W_bubble)
      begin
        W_stat <= m_stat;
        W_icode <= M_icode;
        W_dstE <= M_dstE;
        W_dstM <= M_dstM;
        W_valE <= M_valE;
        W_valM <= m_valM;
      end
  end


wire [2:0] Stat;
assign Stat = (W_stat == STATE_BUB) ? STATE_GOOD : W_stat;

reg clk;
wire t1,t2,t3;
//各器件
register reg_unit(
           W_valM,W_valE,d_srcA,d_srcB,W_dstM,W_dstE,t3,d_rvalA,d_rvalB
         );
alu alu_unit(
      aluA,aluB,alufun,t3,cf,zf,sf,of,e_valE
    );
memory mem_unit(
         mem_addr,f_pc,M_valA,mem_write,t3,m_valM,mem_out
       );


always #1 clk = ~clk;
counter c_t1(
          clk,3'b000,3'b010,t1
        );
counter c_t2(
          clk,3'b001,3'b010,t2
        );
counter c_t3(
          clk,3'b010,3'b010,t3
        );

//流水线控制
wire F_bubble,F_stall,D_bubble,D_stall,E_bubble,E_stall,M_stall,M_bubble,W_stall,W_bubble;
assign F_bubble = 0;
assign F_stall =
       ((E_icode == I_MRMOVQ | E_icode == I_POPQ) & (E_dstM == d_srcA | E_dstM == d_srcB))
       | D_icode == I_RET
       | E_icode == I_RET
       | M_icode == I_RET;
assign D_stall =
       (E_icode == I_MRMOVQ | E_icode == I_POPQ)
       & (E_dstM == d_srcA | E_dstM == d_srcB);
assign D_bubble = (E_icode == I_JXX & !e_Cnd)
       | (~ D_stall & (
            | D_icode == I_RET
            | E_icode == I_RET
            | M_icode == I_RET));
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

initial
  begin
    F_predPC = 0;
    D_stat = STATE_GOOD;
    D_icode = I_NOP;
    D_ifun = F_NONE;
    D_rA = REG_NONE;
    D_rB = REG_NONE;
    D_valP = 0;
    D_valC = 0;
    E_stat = STATE_GOOD;
    E_icode = I_NOP;
    E_ifun = F_NONE;
    E_srcA = REG_NONE;
    E_srcB = REG_NONE;
    E_dstE = REG_NONE;
    E_dstM = REG_NONE;
    E_valC = 0;
    E_valA = 0;
    E_valB = 0;
    M_stat = STATE_GOOD;
    M_icode = I_NOP;
    M_ifun = F_NONE;
    M_dstE = REG_NONE;
    M_dstM = REG_NONE;
    M_valA = 0;
    M_valE = 0;
    M_Cnd = 0;
    W_stat = STATE_GOOD;
    W_icode = I_NOP;
    W_dstE = REG_NONE;
    W_dstM = REG_NONE;
    W_valE = 0;
    W_valM = 0;
    clk = 0;
    $dumpfile("fpga.vcd");
    $dumpvars(0,main);
  end

//打印信息
integer i = 0;
always@(posedge t3)
  begin
    $display("---------------------------------------------------");
    $display("第%3d个周期",i);
    $display("");
    $display("取指阶段状态:");
    $display("分支预测pc：0x%d",F_predPC);
    $display("是否暂停: %d",F_stall);
    $display("是否冒泡: %d",F_bubble);
    $display("");
    $display("译码阶段状态: %d", D_stat);
    $display("指令：%d",D_icode);
    $display("ifun：%d",D_ifun);
    $display("rA: %d",D_rA);
    $display("rB: %d",D_rB);
    $display("valP: %d",D_valP);
    $display("valC: %d",D_valC);
    $display("是否暂停: %d",D_stall);
    $display("是否冒泡: %d",D_bubble);
    $display("");
    $display("执行阶段状态: %d",E_stat);
    $display("指令：%d",E_icode);
    $display("ifun：%d",E_ifun);
    //$display("srcA: %d",E_srcA);
    //$display("srcB: %d",E_srcB);
    $display("dstE: %d",E_dstE);
    $display("dstM: %d",E_dstM);
    $display("valA: %d",E_valA);
    $display("valB: %d",E_valB);
    $display("valC: %d",E_valC);
    $display("cf: %d",e_cf);
    $display("zf: %d",e_zf);
    $display("sf: %d",e_sf);
    $display("of: %d",e_of);
    $display("是否暂停: %d",E_stall);
    $display("是否冒泡: %d",E_bubble);
    $display("");
    $display("访存阶段状态: %d",M_stat);
    $display("指令：%d",M_icode);
    $display("ifun：%d",M_ifun);
    $display("dstE: %d",M_dstE);
    $display("dstM: %d",M_dstM);
    $display("valA: %d",M_valA);
    $display("valE: %d",M_valE);
    $display("Cnd: %d",M_Cnd);
    $display("是否暂停: %d",M_stall);
    $display("是否冒泡: %d",M_bubble);
    $display("");
    $display("写回阶段状态: %d",W_stat);
    $display("指令：%d",W_icode);
    $display("dstE: %d",W_dstE);
    $display("dstM: %d",W_dstM);
    $display("valE: %d",W_valE);
    $display("valM: %d",W_valM);
    $display("是否暂停: %d",W_stall);
    $display("是否冒泡: %d",W_bubble);
    $display("");
    if (Stat == STATE_HALT)
      begin
        $display("服务器停机");
        $finish;
      end
    $stop;
    i = i+1;
  end
endmodule
