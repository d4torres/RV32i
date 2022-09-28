module if_id_reg(
	input logic 		  clk,rst,
	//control signals from hazard unit
	input logic 		  StallD,//low enable
	input logic 		  FlushD,//clear
	//data inputs from fetch stage
	input logic  [31:0]   InstrF, PCF, PCPlus4F,
	
	//output data signals
	output logic [31:0]   InstrD,PCD, PCPlus4D
	
	
);
	always_ff @(posedge clk) begin
		if (FlushD | rst) {InstrD, PCD, PCPlus4D} <= 0; 
		else if (!StallD) {InstrD, PCD, PCPlus4D} <= {InstrF, PCF, PCPlus4F};
	end 
endmodule