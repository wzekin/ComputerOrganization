module memory(
         input [63:0] mem_addr,pc, val,
         input R_W,
         input clock,
         output [63:0] m_out,
         output [79:0] pc_out
       );

parameter MEM_INIT_FILE = "program.mem";
reg [7:0] ram[65535:0];
reg [63:0] data;

integer i;
initial
  begin
    for (i=0; i<65536; i=i+1)
      ram[i] = 0;
    if (MEM_INIT_FILE != "")
      begin
        $readmemb(MEM_INIT_FILE, ram);
      end
    data = 64'h00000000;
  end

always@(posedge clock)
  begin
    if (R_W == 1)
      begin
        $display("0x%h to %3d",mem_addr,val);
        ram[mem_addr] = val[0+:8];
        //if (size >=2)
        ram[mem_addr + 1] = val[8+:8];
        //if (size >=4)
        //begin
        ram[mem_addr + 2] = val[16+:8];
        ram[mem_addr + 3] = val[24+:8];
        //end
        //if (size >= 8)
        //begin
        ram[mem_addr + 4] = val[32+:8];
        ram[mem_addr + 5] = val[40+:8];
        ram[mem_addr + 6] = val[48+:8];
        ram[mem_addr + 7] = val[56+:8];
        //end
      end
    else
      begin
        //data = 0;
        data[0+:8] = ram[mem_addr];
        //if (size >= 2)
        data[8+:8] = ram[mem_addr + 1];
        //if (size >=4)
        //begin
        data[16+:8] = ram[mem_addr + 2];
        data[24+:8] = ram[mem_addr + 3];
        //end
        //if (size >=8)
        //begin
        data[32+:8] = ram[mem_addr + 4];
        data[40+:8] = ram[mem_addr + 5];
        data[48+:8] = ram[mem_addr + 6];
        data[56+:8] = ram[mem_addr + 7];
        //end
      end
  end

assign pc_out[7:0] = ram[pc];
assign pc_out[8+:8] = ram[pc + 1];
assign pc_out[16+:8] = ram[pc + 2];
assign pc_out[24+:8] = ram[pc + 3];
assign pc_out[32+:8] = ram[pc + 4];
assign pc_out[40+:8] = ram[pc + 5];
assign pc_out[48+:8] = ram[pc + 6];
assign pc_out[56+:8] = ram[pc + 7];
assign pc_out[64+:8] = ram[pc + 8];
assign pc_out[72+:8] = ram[pc + 9];
assign m_out = data;
endmodule
