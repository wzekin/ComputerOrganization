module main;

integer i = 1;
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
//机器状态指令
parameter GOOD=2'b00;
parameter SHALT=2'b01;
parameter ERROR=2'b10;

reg [63:0] pc;
reg [1:0] state;

wire cf,zf,sf,of;
wire [63:0] A,B;
wire [63:0] alu_out;

wire [63:0] mem_out;
wire [79:0] icode;
wire mem_loc_valA,mem_loc_valE;
wire [63:0] mem_loc;
wire [3:0] size;

wire abus,mbus,rbus,pbus,cbus;
wire mem_R_W,reg_R_W;
wire pc_update,icode_update;
wire need_valC,need_add_eight,need_sub_eight;
wire [3:0] ALU_Sel,regA,regB;
wire [63:0] valP,valC;

wire [63:0] valA,valB;

wire [63:0] dbus;

wire [3:0] code,ifun,rA,rB;

assign dbus = abus ? alu_out :
       mbus ? mem_out :
       rbus ? valA :
       pbus ? valP :
       cbus ? valC : 63'h00000000;

assign A = need_sub_eight ? -8 :
       need_add_eight ? 8 :
       need_valC ? valC : valA;
assign B = valB;

assign mem_loc = mem_loc_valA ? valA : alu_out;

assign code = icode[7:4];
assign ifun = icode[3:0];
assign rA = icode[15:12];
assign rB = icode[11:8];
assign valC = (code == CALL | code == JXX) ? icode[71:8] : icode[79:16];
assign valP = (code == JXX | code == CALL) ? pc + 9 :
       (code == RET | code == NOP) ? pc + 1 :
       (code == OPQ | code == RRMOVQ) ? pc + 2 :
       (code == MRMOVQ | code == RMMOVQ | code == IRMOVQ) ? pc + 10 : pc;

assign size = (code == RMMOVQ | code == RMMOVQ) ? ifun : 8;


controller controller_unit(
             pc,w1,w2,w3,w4,w5,w6,cf,zf,sf,of,
             code,ifun,rA,rB,
             abus,mbus,rbus,pbus,cbus,
             mem_R_W,reg_R_W,
             pc_update,icode_update,
             mem_loc_valA,mem_loc_valE,
             need_valC,need_add_eight,need_sub_eight,
             ALU_Sel,regA,regB
           );

alu alu_unit(
      A,B,ALU_Sel,t3,
      alu_out,cf,zf,sf,of
    );

memory memory_unit(
         mem_loc,pc,dbus,size,mem_R_W,t2,
         mem_out,icode
       );

register reg_unit(
           dbus,regA,regB,t3,reg_R_W,w6,
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
//更新数据
always@(posedge t3)
  begin
    if (icode_update == 1)
      begin
        if (code == HALT)
          begin
            state <= SHALT;
          end
      end
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
      state <= ERROR;

    if (pc_update == 1)
      begin
        pc <= dbus;
      end
    if (state != GOOD)
      $finish;
  end

always@(posedge w1)
  begin
    $stop;
    $display("第%3d个周期",i);
    i = i + 1;
  end

initial
  begin
    pc = 0;
    state = 0;
    clk = 0;
    $dumpfile("fpga.vcd");
    //$dumpvars(0,main);
    $dumpall;
    $display("第  0个周期");
    #1000;
    $finish;
  end
endmodule
