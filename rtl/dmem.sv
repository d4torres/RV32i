module dmem(
	input logic clk,
	input logic [1:0] we, //we is 00 when not writing 
	input logic [31:0] a, wd,
	output logic[31:0] rd
);
	logic [31:0] RAM[63:0];
	assign rd = RAM[a[31:2]];			//read
	always_ff@(posedge clk) begin//write
		case(we)
			//no write
			2'b00: begin end
			//sw
			2'b01: RAM[a[31:2]]<= wd[31:0];
			//sh
			2'b10: case(a[1])
						1'b0:RAM[a[31:2]][15:0]<= wd[15:0];
						1'b1:RAM[a[31:2]][31:16]<= wd[15:0];
						default: RAM[a[31:2]]<= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
				   endcase
			//sb
			2'b11: case(a[1:0])
						2'b00:RAM[a[31:2]][7:0] <= wd[7:0];
						2'b01:RAM[a[31:2]][15:8] <= wd[7:0];
						2'b10:RAM[a[31:2]][23:16] <= wd[7:0];
						2'b11:RAM[a[31:2]][31:24] <= wd[7:0];
						default: RAM[a[31:2]]<= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
				   endcase 
				   
			default: RAM[a[31:2]]    <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		endcase
	 end
endmodule