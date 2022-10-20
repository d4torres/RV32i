module rv32i_fetch(
	input  		clk,rst,
	//control signals from execute 
	input   		PCSrcE,//set PC = PC + 4 or PcC Target
	//control signals fom hazard unit
	input  		StallF,//stall instruction fetch
	input  		StallD, FlushD,//stall and flush decode input
	//data signal from Writeback 
	input   [31:0] PCTargetE,//next PC if branch or jump taken
	//instruction memory input
	input   [31:0] InstrF,//Instruction received from Instruction Memory
	//output to instruction memory
	output  [31:0] PCF,//PC to receive instruction from Instruction Memory
	//IF/ID Register outputs
	output  [31:0] InstrD,PCD,PCPlus4D//signals required for decode stage
);
	wire [31:0] PCFTick, PCPlus4F;
	mux2 #(.WIDTH(32)) mux2f(
		.d0(PCPlus4F),
		.d1(PCTargetE),
		.s(PCSrcE),
		.y(PCFTick)
	);
	floprnen #(.WIDTH(32)) floprnenf(
		.clk(clk),
		.rst(rst),
		.nen(StallF),
		.d(PCFTick),
		.q(PCF)
	);
	adder #(.WIDTH(32)) adderf(
		.a(PCF),
		.b(32'd4),
		.y(PCPlus4F)
	);
	if_id_reg freg(
		.clk(clk),
		.rst(rst),
		.StallD(StallD),
		.FlushD(FlushD),
		.InstrF(InstrF),
		.PCF(PCF),
		.PCPlus4F(PCPlus4F),
		.InstrD(InstrD),
		.PCD(PCD),
		.PCPlus4D(PCPlus4D)
	);
endmodule