`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/11/30 14:40:25
// Design Name:
// Module Name: alu
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


module alu(
         input [15:0] aluA,aluB,
         input [3:0] ifun,
         input clock,
         output cf,zf,sf,of,
         output [15:0] valE
       );

reg [15:0] alu_result;

assign cf = (alu_result < aluA & ifun == 4'b0001) | (alu_result > aluA & ifun == 4'b0010);
assign zf = alu_result == 0;
assign sf = alu_result[15];
assign of = ~(aluA[15] ^ aluB[15]) & (alu_result[15] ^ aluA[15]);

always@(posedge clock)
  begin
    case (ifun)
      4'b0001:
        alu_result <= aluB + aluA;
      4'b0010:
        alu_result <= aluB - aluA;
      4'b0011:
        alu_result <= aluB * aluA;
      4'b0100:
        alu_result <= aluB / aluA;
      4'b0101:
        alu_result <= aluB & aluA;
      4'b0110:
        alu_result <= aluB | aluA;
      4'b0111:
        alu_result <= aluB ^ aluA;
      default:
        alu_result <= aluA;
    endcase
  end
assign valE = alu_result;
endmodule
