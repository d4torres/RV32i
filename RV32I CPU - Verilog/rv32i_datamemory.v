module rv32i_datamemory(
	input  clk,rst,
	//inputs from IE/DM register
		//control
	input 	   	    RegWriteM,
	input  [1:0] 	ResultSrcM,
	input  [2:0] 	LoadSizeM,
		//data
	input  [31:0] 	ALUResultM, PCPlus4M,
	input  [4:0]  	RdM,
	//input from data memory
	input  [31:0] 	ReadDataMTick,
	//outputs from DM/WB register
	
	//connects to decode stage
	output  		RegWriteW,
	//connects to hazard unit and decode stage
	output  [4:0] 	RdW,
	//connects to writeback stage
	output  [1:0] 	ResultSrcW,
	output  [31:0] ALUResultW, ReadDataW, PCPlus4W
);
	wire [31:0] ReadDataM;
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