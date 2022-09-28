module controller(
	input  logic [6:0]  op,
	input  logic [2:0]  funct3,
	input  logic        funct7b5,
	output logic [1:0]  ResultSrcD,ALUASrcD,MemWriteD,
	output logic [3:0]  ALUControlD,
	output logic [2:0]  ImmSrcD,LoadSizeD,
	output logic        ALUBSrcD,  RegWriteD, JumpD, BranchD,PCTargetALUSrcD 
	);									//port declarations	
	logic [1:0] ALUOp;	
	maindec md(
				//inputs
				.op(op), 
				//outputs
				.Branch(BranchD), 
				.Jump(JumpD),
				.ResultSrc(ResultSrcD), 
				.MemWrite(MemWriteD), 
				.ALUBSrc(ALUBSrcD), 
				.ALUASrc(ALUASrcD),
				.ImmSrc(ImmSrcD),   
				.RegWrite(RegWriteD),
				.ALUOp(ALUOp),
				//
				.LoadSizeD(LoadSizeD),
				.funct3(funct3),
				.PCTargetALUSrc(PCTargetALUSrcD)
				);
	aludec ad(
			   .opb5(op[5]),
			   .funct3(funct3),
			   .funct7b5(funct7b5),
			   .ALUControl(ALUControlD),
			   .ALUOp(ALUOp)
			   );
endmodule
		


