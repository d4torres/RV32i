module dt1_DM_stage(
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
	
	// get correct load data size
	always@(*) begin
		case (LoadSizeM)
			//lw
			3'b000:	ReadDataM = ReadDataMTick;
			//lb
			3'b001:	case(ALUResultM[1:0])
					2'b00: ReadDataM = { {24{ReadDataMTick[7]}}, ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{ReadDataMTick[15]}}, ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{ReadDataMTick[23]}}, ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{ReadDataMTick[31]}}, ReadDataMTick[31:24] };
				endcase
			//lbu
			3'b010:	case(ALUResultM[1:0])
					2'b00: ReadDataM = { {24{1'b0}},ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{1'b0}},ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{1'b0}},ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{1'b0}},ReadDataMTick[31:24] };
				endcase
			
			//lh
			3'b011: case(ALUResultM[1])
					1'b0: ReadDataM = { {16{ReadDataMTick[15]}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{ReadDataMTick[31]}},ReadDataMTick[31:16] };
				endcase
			
			//lhu
			3'b100: case(ALUResultM[1])
					1'b0: ReadDataM = { {16{1'b0}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{1'b0}},ReadDataMTick[31:16] };
				endcase
				
			default:ReadDataM = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		endcase
	end
	//data memory to writeback register
	always@(posedge clk) begin
		if(rst){ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= 0;
		else {ALUResultW, ReadDataW, PCPlus4W, RdW,RegWriteW, ResultSrcW} <= {ALUResultM, ReadDataM, PCPlus4M, RdM,RegWriteM, ResultSrcM};
	end
endmodule