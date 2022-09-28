module extend (
	input  logic [2:0]   ImmSrc,
	input  logic [31:7]  Instr,
	output logic [31:0]  ImmExt
);
	always_comb begin
		case (ImmSrc)
			3'b000: ImmExt = { {20{Instr[31]}}, Instr[31:20] }; 				    		     //I-type ALU
			3'b001: ImmExt = { {20{Instr[31]}}, Instr[31:25], Instr[11:7] }; 		     	 //S-type
			3'b010: ImmExt = { {20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};   //B-type
			3'b011: ImmExt = { {12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; //J-type
			3'b100: ImmExt = { {27{1'b0}}, Instr[24:20]};						                 //I-type Shift
			3'b101: ImmExt = { Instr[31:12] , {12{1'b0}} };//U-type lui
			default: ImmExt = 'x;
		endcase
	end
endmodule