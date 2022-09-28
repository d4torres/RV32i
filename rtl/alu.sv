module alu #(parameter WIDTH)(
	input  logic [3:0]       control,
	input  logic [WIDTH-1:0] a,b,
	output logic [WIDTH-1:0] y,
	output logic 		     BranchCond
);

	always_comb begin
		case (control)
			//add,addi,lw,sw
			4'b0000: begin
						y = a + b;
						BranchCond = 1'b0;
					end
			//sub,beq
			4'b0001: begin
						y = a - b;
						if (y) BranchCond = 1'b0;
						else   BranchCond = 1'b1;
					end
			//and,andi
			4'b0010: begin
						y = a & b;
						BranchCond = 1'b0;
					end
			//or,ori
			4'b0011: begin
						y = a | b;
						BranchCond = 1'b0;
					end
			//sll,slli
			4'b0100:begin 
						y = a << b;
						BranchCond = 1'b0;
					end
			//slt,slti
			4'b0101: begin
						y = signed'(a) < signed'(b);				
						if (y) BranchCond = 1'b1;
						else   BranchCond = 1'b0;
					end
			//sltu,bltu
			4'b0110:begin 
						y = unsigned'(a) <  unsigned'(b);				
						if (y) BranchCond = 1'b1;
						else   BranchCond = 1'b0;
					end
			//xor,xori
			4'b0111:  begin
						y = a ^ b; 
						BranchCond = 1'b0;
					 end
			//sra,srai
			4'b1000: begin
						y = a >>> b;
						BranchCond = 1'b0;
					end
			//srl,srli
			4'b1001: begin
						y = a >> b;
						BranchCond = 1'b0;
					 end
			//bge
			4'b1010: begin
						y = signed'(a) >= signed'(b);				
						if (y) BranchCond = 1'b1;
						else   BranchCond = 1'b0;
					end
			//bgeu
			4'b1011:begin 
						y = unsigned'(a) >= unsigned'(b);				
						if (y) BranchCond = 1'b1;
						else   BranchCond = 1'b0;
					end
			//bne
			4'b1100:begin 									
						y = a - b;			
						if (y) BranchCond = 1'b1;
						else   BranchCond = 1'b0;
					end
			default:begin 
						y = 'x; //??
						BranchCond = 'x;
					end
		endcase
	end
endmodule