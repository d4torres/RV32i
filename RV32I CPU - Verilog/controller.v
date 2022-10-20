module controller(
	input  [6:0]  op,
	input   [2:0]  funct3,
	input          funct7b5,
	output  [1:0]  ResultSrcD,ALUASrcD,MemWriteD,
	output  [3:0]  ALUControlD,
	output  [2:0]  ImmSrcD,LoadSizeD,
	output         ALUBSrcD,  RegWriteD, JumpD, BranchD,PCTargetALUSrcD 
	);									//port declarations	
	wire [1:0] ALUOp;	
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
		


