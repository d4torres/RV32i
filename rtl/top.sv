module top(
	input logic clk,rst,
	output logic [31:0] WriteData, DataAdr,
	output logic [1:0] MemWrite
);
	logic[31:0] PCF,InstrF,ReadDataMTick;
rv32ipipelined riscv(
	//inputs
	.clk(clk),
	.rst(rst),
	.InstrF(InstrF),
	.ReadDataMTick(ReadDataMTick),
	//outputs
	.PCF(PCF),
	.ALUResultM(DataAdr),
	.WriteDataM(WriteData),
	.MemWrite(MemWrite)
);
imem imem1(
	.a(PCF),
	.rd(InstrF)
);
dmem dmem1(
	.clk(clk),
	.we(MemWrite),
	.a(DataAdr),
	.wd(WriteData),
	.rd(ReadDataMTick)
);

endmodule