// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on


module memory(
         input [63:0] valE,pc, dbus_in,
         input [3:0] size,
         input R_W,
         input clock,
         output [63:0] dbus_out,
         output [79:0] pc_out
       );

parameter MEM_INIT_FILE = "program.mem";
reg [7:0] ram[65535:0];
reg [63:0] data;
reg [79:0] data_;

integer i;
initial
  begin
    data = 64'h00000000;
    for (i=0; i<65536; i=i+1)
      ram[i] = 0;
    if (MEM_INIT_FILE != "")
      begin
        $readmemb(MEM_INIT_FILE, ram);
      end
  end

always@(posedge clock)
  begin
    if (R_W == 1)
      begin
        $display("0x%h to %3d",valE,dbus_in);
        ram[valE] = dbus_in[0+:8];
        if (size >=2)
          ram[valE + 1] = dbus_in[8+:8];
        if (size >=4)
          begin
            ram[valE + 2] = dbus_in[16+:8];
            ram[valE + 3] = dbus_in[24+:8];
          end
        if (size >= 8)
          begin
            ram[valE + 4] = dbus_in[32+:8];
            ram[valE + 5] = dbus_in[40+:8];
            ram[valE + 6] = dbus_in[48+:8];
            ram[valE + 7] = dbus_in[56+:8];
          end
      end
    else
      begin
        data = 0;
        data[0+:8] = ram[valE];
        if (size >= 2)
          data[8+:8] = ram[valE + 1];
        if (size >=4)
          begin
            data[16+:8] = ram[valE + 2];
            data[24+:8] = ram[valE + 3];
          end
        if (size >=8)
          begin
            data[32+:8] = ram[valE + 4];
            data[40+:8] = ram[valE + 5];
            data[48+:8] = ram[valE + 6];
            data[56+:8] = ram[valE + 7];
          end
      end
    data_[0+:8] = ram[pc];
    data_[8+:8] = ram[pc + 1];
    data_[16+:8] = ram[pc + 2];
    data_[24+:8] = ram[pc + 3];
    data_[32+:8] = ram[pc + 4];
    data_[40+:8] = ram[pc + 5];
    data_[48+:8] = ram[pc + 6];
    data_[56+:8] = ram[pc + 7];
    data_[64+:8] = ram[pc + 8];
    data_[72+:8] = ram[pc + 9];
  end

assign pc_out = data_;
assign dbus_out = data;
endmodule
