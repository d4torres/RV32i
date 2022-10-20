module id_ie_reg(
	input  		clk,rst,
	//Control Signals
	input  [1:0]      ALUASrcD,
	input  		      RegWriteD,  JumpD, BranchD, ALUBSrcD,
	input   [1:0] 	  ResultSrcD,MemWriteD,
	input   [3:0]  	  ALUControlD,
	input   [31:0]    RD1D, RD2D, PCD, ImmExtD,PCPlus4D,
	input   [11:7]    RdD,
	//Fowarding 
	input  [4:0]      Rs1D, Rs2D,		//Rs1D = InstrD[19:15] ,Rs2D = InstrD[24:20] This is for checking if the registers match causing a data hazard
	
	input  [2:0]      LoadSizeD,
	input  		      FlushE,
	input             PCTargetALUSrcD,
	
	output  reg [4:0] Rs1E, Rs2E,
	output  reg [1:0] ALUASrcE,
	output  reg		  RegWriteE, JumpE,BranchE, ALUBSrcE,
	output  reg [1:0] ResultSrcE,MemWriteE,
	output  reg [3:0] ALUControlE,
    output  reg [31:0]RD1E, RD2E, PCE, ImmExtE,PCPlus4E,
	output  reg [11:7]RdE,
	output  reg [2:0] LoadSizeE,
	output  reg       PCTargetALUSrcE
	
);
	always@(posedge clk) begin
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