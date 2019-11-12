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
         output [63:0] valA,
         output [63:0] valB
       );

reg [63:0] r[14:0];

assign valA = r[rA];
assign valB = r[rB];

always@(posedge clock)
  begin
    if (R_W == 1)
      begin
        r[rB] = dbus_in;
      end
  end
endmodule
