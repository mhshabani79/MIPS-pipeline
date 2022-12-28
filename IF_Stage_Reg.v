
module IF_Stage_Reg(PC, Instruction, clk, rst, PC_in, Instruction_in, freeze, flush);
	output reg[31:0] PC, Instruction;
	input [31:0] PC_in,Instruction_in;
	input clk, rst, freeze, flush;

	always @(posedge clk,posedge rst) begin
		if(rst) {PC, Instruction} <= 64'b0;
		else if(flush)
			{PC, Instruction} <= 64'b0;
		else if(~freeze)
			{PC, Instruction} <= {PC_in,Instruction_in};
	end
endmodule
