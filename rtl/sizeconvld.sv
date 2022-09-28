module sizeconvld(
	input logic  [31:0] ReadDataMTick,
	input logic  [2:0]  LoadSize, 
	input logic [1:0] ByteNum, //memory read is word aligned, so we use 2 lsb of data address to load the correct byte. ADD THIS TO DESIGN Connect to ALUResultM[1:0]
	output logic [31:0] ReadDataM
);
	always_comb begin
		case (LoadSize)
			//lw
			3'b000:	ReadDataM = ReadDataMTick;
			//lb
			3'b001:	case(ByteNum)
					2'b00: ReadDataM = { {24{ReadDataMTick[7]}}, ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{ReadDataMTick[15]}}, ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{ReadDataMTick[23]}}, ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{ReadDataMTick[31]}}, ReadDataMTick[31:24] };
				endcase
			//lbu
			3'b010:	case(ByteNum)
					2'b00: ReadDataM = { {24{1'b0}},ReadDataMTick[7:0] };
					2'b01: ReadDataM = { {24{1'b0}},ReadDataMTick[15:8] };
					2'b10: ReadDataM = { {24{1'b0}},ReadDataMTick[23:16] };
					2'b11: ReadDataM = { {24{1'b0}},ReadDataMTick[31:24] };
				endcase
			
			//lh
			3'b011: case(ByteNum[1])
					1'b0: ReadDataM = { {16{ReadDataMTick[15]}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{ReadDataMTick[31]}},ReadDataMTick[31:16] };
				endcase
			
			//lhu
			3'b100: case(ByteNum[1])
					1'b0: ReadDataM = { {16{1'b0}},ReadDataMTick[15:0] };
					1'b1: ReadDataM = { {16{1'b0}},ReadDataMTick[31:16] };
				endcase
				
			default:ReadDataM = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		endcase
	end
endmodule 
