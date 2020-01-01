`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/12/01 09:58:14
// Design Name:
// Module Name: counter
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


module counter(
         input clk,
         input reset,
         input block,
         output t1,t2,t3
       );

reg [2:0] cnt;

always @(posedge clk or posedge reset)
  begin
    if(reset)
      begin
        cnt <= 3'b001;
      end
    else if(clk)
      begin
        if(~block)
          begin
            case(cnt)
              3'b001:
                cnt <= 3'b010;
              3'b010:
                cnt <= 3'b100;
              3'b100:
                cnt <= 3'b001;
            endcase
          end
      end
  end
assign t1 = cnt == 3'b001;
assign t2 = cnt == 3'b010;
assign t3 = cnt == 3'b100;
endmodule
