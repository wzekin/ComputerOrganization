module alu(
         input [63:0] aluA,aluB,
         input [3:0] ifun,
         input clock,
         output cf,zf,sf,of,
         output [63:0] valE
       );

assign cf = (alu_result < aluA & ifun == 4'b0001) | (alu_result > aluA & ifun == 4'b0010);
assign zf = alu_result == 0;
assign sf = alu_result[63];
assign of = (aluA > 0 == aluB > 0) && (alu_result < 0 != aluA < 0);

reg [63:0] alu_result;

initial
  begin
    alu_result = 64'h00000000;
  end

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
