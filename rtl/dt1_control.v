module dt1_control(
	input  [6:0]  op,
	input   [2:0]  funct3,
	input          funct7b5,
	`ifdef RISCV-FORMAL
		output  			rvfi_valid,
		output [63 : 0] 	rvfi_order,
		output [4095 : 0] 	rvfi_insn,
		output  			rvfi_trap,
		output  			rvfi_halt,
		output  			rvfi_intr,
		output [1:0] 		rvfi_mode,
		output [1:0] 		rvfi_ixl,
	`endif
	output  [1:0]  ResultSrcD,ALUASrcD,MemWriteD,
	output  [3:0]  ALUControlD,
	output  [2:0]  ImmSrcD,LoadSizeD,
	output         ALUBSrcD,  RegWriteD, JumpD, BranchD,PCTargetALUSrcD 
	
	);									//port declarations	
	wire [1:0] ALUOp;	
	dt1_maindec md(
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
				.rvfi_valid
				.rvfi_order
				.rvfi_insn
				.rvfi_trap
				.rvfi_halt
				.rvfi_intr
				.rvfi_mode
				.rvfi_ixl
				);
	dt1_aludec ad(
			   .opb5(op[5]),
			   .funct3(funct3),
			   .funct7b5(funct7b5),
			   .ALUControl(ALUControlD),
			   .ALUOp(ALUOp)
			   );
endmodule
		


