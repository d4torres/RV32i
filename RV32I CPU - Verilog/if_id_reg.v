module if_id_reg(
	input  		      clk,rst,
	//control signals from hazard unit
	input  		      StallD,//low enable
	input  		      FlushD,//clear
	//data inputs from fetch stage
	input   [31:0]    InstrF, PCF, PCPlus4F,
	
	//output data signals
	output reg [31:0] InstrD,PCD, PCPlus4D
	
	
);
	always@(posedge clk) begin
		if (FlushD)   {InstrD, PCD, PCPlus4D} <= 0; 
		else if (rst) {InstrD, PCD, PCPlus4D} <= 0; 
		else if (!StallD) {InstrD, PCD, PCPlus4D} <= {InstrF, PCF, PCPlus4F};
	end 
endmodule