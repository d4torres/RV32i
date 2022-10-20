module rv32i_decode(
	input  		clk,rst,
	//control signals from hazard unit output
	input  		FlushE,
	//control signals from Writeback output
	input  		RegWriteW,
	//data signals from ifid register output
	input  [31:0] 	InstrD,PCD,PCPlus4D,
	//data signals from Writeback output
	input  [31:0]	ResultW,
	input  [4:0]   RdW,
	//ID/IE register outputs
	
	//to Execute stage
	output  [31:0]	RD1E,RD2E,PCE,ImmExtE,PCPlus4E,
	//to hazard unit
	output  [4:0] 	Rs1E,Rs2E,RdE,
	//to execute stage control
	output 	     	RegWriteE,JumpE,BranchE,ALUBSrcE,PCTargetALUSrcE,
	output  [1:0] 	ResultSrcE,MemWriteE,ALUASrcE,
	output  [2:0] 	LoadSizeE,
	output  [3:0] 	ALUControlE
);
	//datapath outputs to ID/IE register input
	wire [31:0]	RD1D,RD2D,ImmExtD;

	//control unit outputs to ID/IE register input
	wire	   	RegWriteD,JumpD,BranchD,ALUBSrcD,PCTargetALUSrcD;
	wire [1:0] ResultSrcD,MemWriteD,ALUASrcD;
	wire [2:0] LoadSizeD;
	wire [3:0] ALUControlD;
	//control unit to extend unit
	wire [2:0] ImmSrcD;
	controller control(
		 //inputs
		.op(InstrD[6:0]),
		.funct3(InstrD[14:12]),
		.funct7b5(InstrD[30]),
		//outputs
		.ResultSrcD(ResultSrcD),
		.ALUControlD(ALUControlD),
		.ImmSrcD(ImmSrcD),
		.ALUASrcD(ALUASrcD),
		.ALUBSrcD(ALUBSrcD),
		.MemWriteD(MemWriteD),
		.RegWriteD(RegWriteD),
		.JumpD(JumpD),
		.BranchD(BranchD),
		.LoadSizeD(LoadSizeD),
		.PCTargetALUSrcD(PCTargetALUSrcD)
	);
	regfile regfile1(
		.clk(clk),
		.we3(RegWriteW),	
		.rst(rst),
		.a1(InstrD[19:15]),
		.a2(InstrD[24:20]),
		.a3(RdW),
		.wd3(ResultW),
		.rd1(RD1D),
		.rd2(RD2D)
	);
	extend extend1(
		.ImmSrc(ImmSrcD),	
		.Instr(InstrD[31:7]),
		.ImmExt(ImmExtD)
	);
	id_ie_reg idiereg(
		.clk(clk),
		.rst(rst),
		.RegWriteD(RegWriteD),
		.MemWriteD(MemWriteD),
		.JumpD(JumpD),
		.BranchD(BranchD),
		.ALUASrcD(ALUASrcD),
		.ALUBSrcD(ALUBSrcD),
		.ResultSrcD(ResultSrcD),
		.ALUControlD(ALUControlD),
		.RD1D(RD1D),
		.RD2D(RD2D),
		.PCD(PCD),
		.ImmExtD(ImmExtD),
		.PCPlus4D(PCPlus4D),
		.RdD(InstrD[11:7]),
		.Rs1D(InstrD[19:15]),
		.Rs2D(InstrD[24:20]),
		.FlushE(FlushE),
		.LoadSizeD(LoadSizeD),
		.PCTargetALUSrcD(PCTargetALUSrcD),
		//outputs
		.RegWriteE(RegWriteE),
		.MemWriteE(MemWriteE),
		.JumpE(JumpE),
		.BranchE(BranchE),
		.ALUASrcE(ALUASrcE),
		.ALUBSrcE(ALUBSrcE),
		.ResultSrcE(ResultSrcE),
		.ALUControlE(ALUControlE),
		.RD1E(RD1E),
		.RD2E(RD2E),
		.PCE(PCE),
		.ImmExtE(ImmExtE),
		.PCPlus4E(PCPlus4E),
		.RdE(RdE),
		.Rs1E(Rs1E),
		.Rs2E(Rs2E),
		.LoadSizeE(LoadSizeE),
		.PCTargetALUSrcE(PCTargetALUSrcE)
	);
endmodule