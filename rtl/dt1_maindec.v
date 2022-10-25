module dt1_maindec(							//This will decode what type of instruction we are using
	input   [6:0] op,
	input  [2:0] funct3,
	output reg	       Branch,
					   Jump,
					   ALUBSrc,
					   RegWrite,
					   PCTargetALUSrc,
	`ifdef RISCV-FORMAL
		output reg 				rvfi_valid,
		output reg [63 : 0] 	rvfi_order,
		output reg [4095 : 0] 	rvfi_insn,
		output reg				rvfi_trap,
		output reg 				rvfi_halt,
		output reg				rvfi_intr,
		output reg [1:0] 		rvfi_mode,
		output reg [1:0] 		rvfi_ixl,
	`endif
	output reg [1:0]   ResultSrc,
					   ALUOp,
					   ALUASrc,
					   MemWrite,
	output reg   [2:0] LoadSizeD,ImmSrc
	
);				// Port Declarations

reg [18:0] controls;

always@(*) begin
	{RegWrite, ImmSrc, ALUASrc, ALUBSrc, 
	MemWrite, ResultSrc, Branch, ALUOp, 
	Jump, LoadSizeD,PCTargetALUSrc} = controls;
end
always@(*) begin
	case (op)
		7'b0000011: case(funct3)
						3'b000: controls = 19'b1_000_00_1_00_01_0_00_0_001_0;	//lb
						3'b001: controls = 19'b1_000_00_1_00_01_0_00_0_011_0;	//lh
						3'b010: controls = 19'b1_000_00_1_00_01_0_00_0_000_0;	//lw
						3'b100: controls = 19'b1_000_00_1_00_01_0_00_0_010_0;	//lbu
						3'b101: controls = 19'b1_000_00_1_00_01_0_00_0_100_0;	//lhu
						default:begin
								`ifdef RISCV-FORMAL
									rvfi_valid = 1'b0;
									rvfi_order = 64{{1'bx}};
									rvfi_insn = 4096{{1'bx}};
									rvfi_trap = 1'bx;
									rvfi_halt = 1'bx;
									rvfi_intr = 1'bx;
									rvfi_mode = 2'bxx;
									rvfi_ixl = 2'bxx;
								`endif
									controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
								
								end
					endcase
		7'b0100011: case(funct3)
						3'b000: controls = 19'b0_001_00_1_11_00_0_00_0_000_0;	//sb
						3'b001: controls = 19'b0_001_00_1_10_00_0_00_0_000_0;	//sh
						3'b010: controls = 19'b0_001_00_1_01_00_0_00_0_000_0;	//sw
					    default:begin
								`ifdef RISCV-FORMAL
									rvfi_valid = 1'b0;
									rvfi_order = 64{{1'bx}};
									rvfi_insn = 4096{{1'bx}};
									rvfi_trap = 1'bx;
									rvfi_halt = 1'bx;
									rvfi_intr = 1'bx;
									rvfi_mode = 2'bxx;
									rvfi_ixl = 2'bxx;
								`endif
									controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
								end
					endcase
		7'b0110011: 			controls = 19'b1_000_00_0_00_00_0_10_0_000_0;	//R-type
		7'b1100011: 			controls = 19'b0_010_00_0_00_00_1_01_0_000_0;	//beq
		//I-type ALU or shift
		7'b0010011: case (funct3)
						3'b000,3'b010,3'b011,3'b100,3'b110,3'b111: controls = 19'b1_000_00_1_00_00_0_10_0_000_0;	//I-type ALU
						3'b001,3'b101					         : controls = 19'b1_100_00_1_00_00_0_10_0_000_0;	//I-type Shift
						default									 :begin
																`ifdef RISCV-FORMAL
																   rvfi_valid = 1'b0;
																   rvfi_order = 64{{1'bx}};
															       rvfi_insn = 4096{{1'bx}};
																   rvfi_trap = 1'bx;
																   rvfi_halt = 1'bx;
																   rvfi_intr = 1'bx;
																   rvfi_mode = 2'bxx;
																   rvfi_ixl = 2'bxx;
																`endif
																   controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
																  end
					endcase											//I-type shift 
		7'b1101111: 			controls = 19'b1_011_00_0_00_10_0_00_1_000_0;  //jal
		7'b0110111: 			controls = 19'b1_101_01_1_00_00_0_00_0_000_0;  //U-type lui
		7'b0010111: 			controls = 19'b1_101_10_1_00_00_0_00_0_000_0; //U-type auipc
		7'b1100111: 			controls = 19'b1_000_00_1_00_10_0_00_1_000_1; //jalr
		7'b0000000: 			controls = 19'b0_000_00_0_00_00_0_00_0_000_0;	//reset
		default: 				begin
								`ifdef RISCV-FORMAL
									rvfi_valid = 1'b0;
									rvfi_order = 64{{1'bx}};
									rvfi_insn = 4096{{1'bx}};
									rvfi_trap = 1'bx;
									rvfi_halt = 1'bx;
									rvfi_intr = 1'bx;
									rvfi_mode = 2'bxx;
									rvfi_ixl = 2'bxx;
								`endif
									controls = 19'bx_xxx_xx_x_xx_xx_x_xx_x_xxx_x;   //?
								end
	endcase

end

endmodule
					   
					
					   
					 