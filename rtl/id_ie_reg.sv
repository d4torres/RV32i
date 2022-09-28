module id_ie_reg(
	input logic 		clk,rst,
	//Control Signals
	input logic [1:0]   ALUASrcD,
	input logic 		RegWriteD,  JumpD, BranchD, ALUBSrcD,
	input logic  [1:0] 	ResultSrcD,MemWriteD,
	input logic  [3:0] 	ALUControlD,
	input  logic [31:0] RD1D, RD2D, PCD, ImmExtD,PCPlus4D,
	input  logic [11:7] RdD,
	//Fowarding 
	input logic [4:0]   Rs1D, Rs2D,		//Rs1D = InstrD[19:15] ,Rs2D = InstrD[24:20] This is for checking if the registers match causing a data hazard
	output logic [4:0]  Rs1E, Rs2E,
	//Stalling
	input logic 		FlushE,
	
	output logic [1:0]  ALUASrcE,
	output logic 		RegWriteE, JumpE,BranchE, ALUBSrcE,
	output logic [1:0] 	ResultSrcE,MemWriteE,
	output logic [3:0] 	ALUControlE,
    output logic [31:0] RD1E, RD2E, PCE, ImmExtE,PCPlus4E,
	output logic [11:7] RdE,
	
	input logic [2:0] LoadSizeD,
	output logic [2:0] LoadSizeE,
	input logic  PCTargetALUSrcD,
	output logic PCTargetALUSrcE
	
);
	always_ff @(posedge clk) begin
		if (FlushE | rst) {RegWriteE, MemWriteE, JumpE, BranchE, ALUASrcE, ALUBSrcE,
							 ResultSrcE,  ALUControlE, RD1E, RD2E,PCE, ImmExtE, PCPlus4E, RdE, Rs1E, 
							 Rs2E,LoadSizeE,PCTargetALUSrcE} <= 0;
		else {RegWriteE, MemWriteE, JumpE, BranchE, ALUASrcE,
				ALUBSrcE, ResultSrcE, ALUControlE, 
				RD1E, RD2E,PCE, ImmExtE, PCPlus4E, RdE, Rs1E, Rs2E,LoadSizeE,PCTargetALUSrcE} <= {RegWriteD, MemWriteD, JumpD, BranchD, ALUASrcD, ALUBSrcD, 
																						  ResultSrcD, ALUControlD, RD1D, RD2D, 
																						  PCD, ImmExtD, PCPlus4D, RdD, Rs1D, Rs2D,LoadSizeD,PCTargetALUSrcD};
		
	end
endmodule