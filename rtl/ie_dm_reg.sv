module ie_dm_reg(
	input logic clk,rst,
	//Control signals
	input logic RegWriteE, 
	input logic [1:0] ResultSrcE,MemWriteE,
	output logic RegWriteM, 
	output logic [1:0] ResultSrcM,MemWriteM,
	//
	input logic [31:0] ALUResultE, WriteDataE,PCPlus4E,
	input logic [11:7] RdE,
	output logic [31:0] ALUResultM, WriteDataM ,PCPlus4M,
	output logic [11:7] RdM,
	input logic [2:0] LoadSizeE,
	output logic [2:0] LoadSizeM
	
);
	always_ff @(posedge clk) begin
		if(rst) 
			{RegWriteM, MemWriteM, ResultSrcM, ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= 0;
		
		else 
			{RegWriteM, MemWriteM, ResultSrcM, 
			 ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= {RegWriteE, MemWriteE, ResultSrcE, 
													    ALUResultE, WriteDataE, PCPlus4E, RdE, LoadSizeE};
		
	end
endmodule