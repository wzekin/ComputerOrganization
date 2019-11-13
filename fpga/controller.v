// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

//module alu(X,Y,S,Out,CF,ZF,SF,OF);
module controller;

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
parameter JLE=8'h1;
//parameter JLE=8'h2;
parameter JL=8'h3;
parameter JE=8'h4;
parameter JNE=8'h5;
parameter JGE=8'h6;
parameter JG=8'h7;

//机器状态指令
parameter GOOD=2'b00;
parameter SHALT=2'b01;
parameter ERROR=2'b10;

parameter RSP=4'hE;

//机器状态
reg [1:0] State;

//总线
wire [63:0] dbus;

//时钟
wire t1,t2,t3;
wire w1,w2,w3,w4,w5,w6;

//寄存器
reg [63:0] PC;
wire [63:0] valC,valP;

//alu
wire [3:0] ALU_sel;
wire [63:0]A,B;
wire [63:0] valE;
wire CF,ZF;

//memory
wire MEM_R_W;
wire [63:0] mem_loc;
wire [63:0] mbus_out;
wire [79:0] icode;

//reg
wire [3:0]regA,regB;
wire REG_R_W;
wire [63:0] valA,valB;

//控制器硬连线

//信号
wire [3:0] code,ifun;
wire [3:0]rA,rB;

wire code_update, pc_update;


assign regB = ((w2 & (code == OPQ | code == RMMOVQ))
               | (w5 & ( code == OPQ | code == MRMOVQ | code == IRMOVQ | code == RRMOVQ))) ? rB :
       ((w2 | w5)& (code == CALL | code == RET)) ? RSP :
       (w5 & code == MRMOVQ) ? rA : 8'hF;
assign regA = (w2 & (code == OPQ | code == MRMOVQ | code == RRMOVQ | code == RMMOVQ )) ? rA :
       (w2 & code == RET) ? RSP : 8'hF;
assign REG_R_W = (w5 & (code == OPQ | code == MRMOVQ | code == IRMOVQ | code == RRMOVQ | code == CALL | code == RET));
assign MEM_R_W = (w4 & (code == CALL | code == RMMOVQ));
assign code_update = w2 | w1;
assign pc_update = w6;
assign ALU_sel = (code == OPQ) ? ifun :
       (code == CALL | code == RET| code == MRMOVQ | code == RMMOVQ) ? 4'h1 : 4'h0;
assign A = (code == CALL) ? -8 :
       (code == RET) ? 8 :
       (code == OPQ | code == RRMOVQ) ? valA :
       (code == IRMOVQ | code == RMMOVQ) ? valC : 0;
assign B = (code == CALL | code == RET |
            code == OPQ | code == MRMOVQ |
            code == RMMOVQ
           )?valB:0;
assign mem_loc = (code == MRMOVQ | code == RMMOVQ | code == CALL) ? valE :
       (code == RET) ? valA : 0;

assign dbus = (w4 & code == CALL) ? valP :
       (w4 & code == RMMOVQ) ? valA :
       (w5 & (code == CALL | code == RET | code == OPQ | code == IRMOVQ | code == RRMOVQ)) ? valE :
       ((w5 & code == MRMOVQ) | (w6 & code == RET)) ? mbus_out :
       (w6 & code == CALL) ? valC :
       (w6 & (code == NOP | code == OPQ | code == MRMOVQ | code == RRMOVQ | code == IRMOVQ | code == RMMOVQ)) ? valP : 0;

assign code = icode[7:4];
assign ifun = icode[3:0];
assign rA = icode[15:12];
assign rB = icode[11:8];
assign valC = (code == CALL | code == JXX) ? icode[71:8] : icode[79:16];
assign valP = (code == JXX | code == CALL) ? PC + 9 :
       (code == RET | code == NOP) ? PC + 1 :
       (code == OPQ | code == RRMOVQ) ? PC + 2 :
       (code == MRMOVQ | code == RMMOVQ | code == IRMOVQ) ? PC + 10 : PC;

//更新数据
always@(posedge t3)
  begin
    if (code_update == 1)
      if (code == HALT)
        State <= SHALT;
      else if (code != CALL
               & code != JXX
               & code != RET
               & code != NOP
               & code != OPQ
               & code != RRMOVQ
               & code != MRMOVQ
               & code != RMMOVQ
               & code != IRMOVQ
              )
        State <= ERROR;

    if (pc_update == 1)
      begin
        PC <= dbus;
      end

  end

alu alu_unit(
      A,B,ALU_sel,t3,
      valE,CF,ZF
    );

memory memory_unit(
         mem_loc,PC,dbus,MEM_R_W,t2,
         mbus_out,icode
       );

register reg_unit(
           dbus,regA,regB,t3,REG_R_W,
           valA,valB
         );

reg clk;
//固有时钟震荡
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

counter c_w1(
          t1,3'b000,3'b101,w1
        );
counter c_w2(
          t1,3'b001,3'b101,w2
        );
counter c_w3(
          t1,3'b010,3'b101,w3
        );

counter c_w4(
          t1,3'b011,3'b101,w4
        );
counter c_w5(
          t1,3'b100,3'b101,w5
        );
counter c_w6(
          t1,3'b101,3'b101,w6
        );

initial
  begin
    PC = 0;
    State = 0;
    clk = 0;
    $dumpfile("fpga.vcd");
    $dumpvars(0,controller);
    $display("hello world!");
    #1000;
    $finish;
  end
endmodule
