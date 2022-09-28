module aludec(
	input logic  	   funct7b5,opb5,
	input logic  [2:0] funct3,
	input logic  [1:0] ALUOp,
	output logic [3:0] ALUControl	//port declarations
);
logic RtypeSub,ItypeSub;
assign RtypeSub = opb5 & funct7b5;		
assign ItypeSub = ~opb5 & funct7b5;
always_comb begin
	case (ALUOp)
		//I-type Load, S-type, U-type
		2'b00: 		ALUControl = 4'b0000; //add- lw,sw,lb,lh,lbu,lhu,sb,sh,auipc,lui
		//B-type
		2'b01: case (funct3)														
					3'b000:     						ALUControl = 4'b0001; //sub - beq
					3'b001:  			     			ALUControl = 4'b1100; //sub - bne
					3'b100: 			    			ALUControl = 4'b0101; //blt
					3'b101:				     			ALUControl = 4'b1010; //bge
					3'b110: 		         			ALUControl = 4'b0110; //bltu
					3'b111:								ALUControl = 4'b1011; //bgeu
					default: 			     			ALUControl = 4'bxxxx; //unknown
				endcase		
		//R-type, I-type ALU,I-type logical shift
		2'b10: case (funct3)													
					3'b000:if (RtypeSub)     			ALUControl = 4'b0001; //sub
						   else 		     			ALUControl = 4'b0000; //add  
			
					3'b001:  			     			ALUControl = 4'b0100; //sll
					3'b010: 			    			ALUControl = 4'b0101; //slt
					3'b011:				     			ALUControl = 4'b0110; //sltu
					3'b100: 		         			ALUControl = 4'b0111; //xor
					3'b101:	if (RtypeSub | ItypeSub)    ALUControl = 4'b1000; //sra
							else		     			ALUControl = 4'b1001; //srl
					3'b110: 			     			ALUControl = 4'b0011; //or
					3'b111: 			     			ALUControl = 4'b0010; //and
					default: 			     			ALUControl = 4'bxxxx; //unknown
				endcase
		default:  case (funct3)
					3'b000:if (RtypeSub)     			ALUControl = 4'b0001; //sub
						   else 		     			ALUControl = 4'b0000; //add  
					3'b001:  			     			ALUControl = 4'b0100; //sll
					3'b010: 			    			ALUControl = 4'b0101; //slt
					3'b011:				     			ALUControl = 4'b0110; //sltu
					3'b100: 		         			ALUControl = 4'b0111; //xor
					3'b101:	if (RtypeSub | ItypeSub)    ALUControl = 4'b1000; //sra
							else		     			ALUControl = 4'b1001; //srl
					3'b110: 			     			ALUControl = 4'b0011; //or
					3'b111: 			     			ALUControl = 4'b0010; //and
					default: 			     			ALUControl = 4'bxxxx; //unknown
				endcase
	endcase
end
endmodule