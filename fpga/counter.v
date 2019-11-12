module counter(
         input clk,
         input [2:0] W,
         input [2:0] max,
         output clk_out
       );
parameter MAX=3'b101;

reg [2:0] cnt;

initial
  begin
    cnt = 0;
  end

always @(posedge clk)
  begin
    if(cnt == max)
      begin
        cnt <=3'b000;
      end
    else
      begin
        cnt <=cnt+3'b001;
      end
  end
assign clk_out = cnt == W;
endmodule
