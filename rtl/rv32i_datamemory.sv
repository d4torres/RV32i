module rv32i_datamemory(
	input logic clk,rst,
	//inputs from IE/DM register
		//control
	input logic	   	    RegWriteM,
	input logic [1:0] 	ResultSrcM,
	input logic [2:0] 	LoadSizeM,
		//data
	input logic [31:0] 	ALUResultM, PCPlus4M,
	input logic [4:0]  	RdM,
	//input from data memory
	input logic [31:0] 	ReadDataMTick,
	//outputs from DM/WB register
	
	//connects to decode stage
	output logic 		RegWriteW,
	//connects to hazard unit and decode stage
	output logic [4:0] 	RdW,
	//connects to writeback stage
	output logic [1:0] 	ResultSrcW,
	output logic [31:0] ALUResultW, ReadDataW, PCPlus4W
);
	logic [31:0] ReadDataM;
	sizeconvld ldsz1(
		//inputs
		.ReadDataMTick(ReadDataMTick),
		.LoadSize(LoadSizeM),
		.ByteNum(ALUResultM[1:0]),
		//outputs
		.ReadDataM(ReadDataM)
	);
	dm_wb_reg dmwbreg(
		//inputs
		.clk(clk),
		.rst(rst),
		.RegWriteM(RegWriteM),
		.ResultSrcM(ResultSrcM),
		.ALUResultM(ALUResultM),
		.ReadDataM(ReadDataM),
		.PCPlus4M(PCPlus4M),
		.RdM(RdM),
		//outputs
		.RegWriteW(RegWriteW),
		.ResultSrcW(ResultSrcW),
		.ALUResultW(ALUResultW),
		.ReadDataW(ReadDataW),
		.PCPlus4W(PCPlus4W),
		.RdW(RdW)
	);
endmodule
