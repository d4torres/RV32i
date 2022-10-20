module rv32i_writeback(
	input  [1:0]  ResultSrcW,
	input  [31:0] ALUResultW, ReadDataW, PCPlus4W,
	//connects to execute and decode stage
	output [31:0] ResultW
);
	mux3 #(.WIDTH(32)) mux3w(// selects data to write to regfile and to forward to execute stage
		.d0(ALUResultW),
		.d1(ReadDataW),
		.d2(PCPlus4W),
		.s(ResultSrcW),// control
		.y(ResultW)
	);
endmodule