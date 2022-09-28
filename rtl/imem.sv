module imem(
	input logic [31:0] a,
	output logic [31:0] rd
);
	logic [0:3][7:0]RAM [63:0];//data is being read byte by byte from least significant byte to most significant
	//initial $readmemh("C:/Users/david/Desktop/riscv-test-str-ld/strld.txt",RAM);
	initial $readmemh("C:/Users/david/Desktop/riscv-test-str-ld/rv32i-lui-auipc-jalr.txt",RAM);
	assign rd = {RAM[a[31:2]][3],RAM[a[31:2]][2],RAM[a[31:2]][1],RAM[a[31:2]][0]};
endmodule 
