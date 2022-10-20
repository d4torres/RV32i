module ie_dm_reg(
	input            clk,rst,
	//Control signals
	input            RegWriteE, 
	input  [1:0]     ResultSrcE,MemWriteE,
	input  [31:0]    ALUResultE, WriteDataE,PCPlus4E,
	input  [11:7] 	 RdE,
	input  [2:0] 	 LoadSizeE,
	output reg		 RegWriteM, 
	output reg[1:0]  ResultSrcM,MemWriteM,
	output reg [31:0]ALUResultM, WriteDataM ,PCPlus4M,
	output reg [11:7]RdM,
	output reg [2:0] LoadSizeM
	
);
	always@(posedge clk) begin
		if(rst) 
			{RegWriteM, MemWriteM, ResultSrcM, ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= 0;
		
		else 
			{RegWriteM, MemWriteM, ResultSrcM, 
			 ALUResultM, WriteDataM, PCPlus4M, RdM, LoadSizeM} <= {RegWriteE, MemWriteE, ResultSrcE, 
													    ALUResultE, WriteDataE, PCPlus4E, RdE, LoadSizeE};
		
	end
endmodule