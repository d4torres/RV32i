module dt1_WB_stage(
	input  [1:0]  ResultSrcW,
	input  [31:0] ALUResultW, ReadDataW, PCPlus4W,
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
	//connects to execute and decode stage
	output [31:0] ResultW
	
);
	//selects data to write to regfile and to forward to execute stage
	assign ResultW[1] = ResultSrcW ? PCPlus4W : (ResultW[0] ? ReadDataW : ALUResultW);
endmodule