module rv32i_execute(
	input logic 			clk,rst,
	//input from ID/IE register output
	
		//data signals
	input logic [31:0]	RD1E,RD2E,PCE,ImmExtE,PCPlus4E,
	input logic [4:0] 	RdE,
		//control signals
	input logic	   		RegWriteE,JumpE,BranchE,ALUBSrcE,PCTargetALUSrcE,
	input logic [1:0] 	ResultSrcE,MemWriteE,ALUASrcE,
	input logic [2:0] 	LoadSizeE,
	input logic [3:0] 	ALUControlE,
	//input from hazard unit
	input logic [1:0] 	ForwardAE,ForwardBE,
	//forwarded inputs
	input logic [31:0] 	ResultW, 
	
	//connects to fetch stage
	output logic [31:0] PCTargetE,
	//connects to fetch stage and hazard unit
	output logic 		PCSrcE,
	//connects to Data Memory stage
	output logic	   	RegWriteM,
	output logic [1:0] 	ResultSrcM,
	output logic [2:0] 	LoadSizeM,
	output logic [31:0] PCPlus4M,
		
	//connects to data memory 
	output logic [1:0] 	MemWriteM,
	output logic [31:0]	WriteDataM,
	//connects to data memory,data memory stage, and execute stage
	output logic [31:0] ALUResultM,
	//connects to data memory and hazard unit
	output logic [4:0]  RdM
);
	logic [31:0] SrcAETick,SrcAE,WriteDataE,SrcBE,PCTargetSrcAE, ALUResultE;
	logic 		 BranchCondE;
	assign PCSrcE = (BranchE & BranchCondE) | (JumpE);
	
	mux2 #(.WIDTH(32)) mux2e(//chooses between sign extended immediate or data from rs2		 	
		.d0(WriteDataE),
		.d1(ImmExtE),
		.s(ALUBSrcE), 
		.y(SrcBE)
	);
	alu #(.WIDTH(32)) alu1(//performs arithmetic calculations of instruction
		.a(SrcAE),
		.b(SrcBE), 
		.control(ALUControlE), 
		.y(ALUResultE),
		.BranchCond(BranchCondE) 
		
	);
	adder #(.WIDTH(32)) adderwe(//adds branch offset to PC for B-type instructions
		.a(PCTargetSrcAE),
		.b(ImmExtE),
		.y(PCTargetE)
	);
	mux3 #(.WIDTH(32)) mux3eforward1(//forwards data from wrtieback or Memory stage if there is a hazard
		.d0(RD1E),
		.d1(ResultW),
		.d2(ALUResultM),
		.s(ForwardAE),
		.y(SrcAETick)
	);
	mux3 #(.WIDTH(32)) mux3eforward2(  //forwards data from wrtieback or Memory stage if there is a hazard
		.d0(RD2E),
		.d1(ResultW),
		.d2(ALUResultM),
		.s(ForwardBE),
		.y(WriteDataE)
	);
	mux3 #(.WIDTH(32)) mux3e2(//choose source A for Result ALU
		.d0(SrcAETick),
		.d1(32'd0),
		.d2(PCE),
		.s(ALUASrcE),
		.y(SrcAE)
	);
	mux2 #(.WIDTH(32)) mux2e3(//Choose source A for PCTarget ALU
		.d0(PCE),
		.d1(SrcAETick),
		.s(PCTargetALUSrcE), 
		.y(PCTargetSrcAE)
	);
	ie_dm_reg iedmreg(
		//inputs
		.clk(clk),
		.rst(rst),
		.RegWriteE(RegWriteE),
		.MemWriteE(MemWriteE),
		.ResultSrcE(ResultSrcE),
		.ALUResultE(ALUResultE),
		.WriteDataE(WriteDataE),
		.PCPlus4E(PCPlus4E),
		.RdE(RdE),
		.LoadSizeE(LoadSizeE),
		//outputs
		.RegWriteM(RegWriteM),
		.MemWriteM(MemWriteM),
		.ResultSrcM(ResultSrcM),
		.ALUResultM(ALUResultM),
		.WriteDataM(WriteDataM),
		.PCPlus4M(PCPlus4M),
		.RdM(RdM),
		.LoadSizeM(LoadSizeM)
	);
endmodule
