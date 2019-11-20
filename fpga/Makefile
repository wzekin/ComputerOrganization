build: *.v
	iverilog *.v -o build -g2012

run: build program.mem
	./build

show: fpga.vcd
	gtkwave ./fpga.vcd
	
clean:
	rm -f build  *.vcd 

fpga.vcd: run
