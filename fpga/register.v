// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on

//module alu(X,Y,S,Out,CF,ZF,SF,OF);
module register(
         input [63:0] dbus_in,
         input [3:0] rA,
         input [3:0] rB,
         input clock,
         input R_W,
         input w6, //打印信息用
         output [63:0] valA,
         output [63:0] valB
       );

reg [63:0] r[14:0];
reg [63:0] v_A,v_B;

assign valA = v_A;
assign valB = v_B;

integer i;
initial
  begin
    for (i=0; i<15; i=i+1)
      r[i] = 0;
    v_A = 64'h00000000;
    v_B = 64'h00000000;
  end

always@(posedge clock)
  begin
    if (R_W == 1)
      begin
        $display("%%r%0d from %3d to %3d",rB + 1,r[rB],dbus_in);
        r[rB] = dbus_in;
      end
    else
      begin
        if (rA != 8'hF)
          v_A = r[rA];
        if (rB != 8'hF)
          v_B = r[rB];
      end
  end

always@(posedge w6)
  begin
    $display("%%r1: %d",r[0]);
    $display("%%r2: %d",r[1]);
    $display("%%r3: %d",r[2]);
    $display("%%r4: %d",r[3]);
    $display("%%r5: %d",r[4]);
    $display("%%r6: %d",r[5]);
    $display("%%r7: %d",r[6]);
    $display("%%r8: %d",r[7]);
    $display("%%r9: %d",r[8]);
    $display("%%r10:%d",r[9]);
    $display("%%r11:%d",r[10]);
    $display("%%r12:%d",r[11]);
    $display("%%r13:%d",r[12]);
    $display("%%r14:%d",r[13]);
    $display("%%rsp:%d",r[14]);
  end
endmodule
