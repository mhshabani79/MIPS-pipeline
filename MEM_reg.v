module MEM_reg(clk, rst, WB_en_in, MEM_R_en_in, ALU_result_in, Mem_read_value_in, Dest_in,
		WB_en, MEM_R_en, ALU_result, Mem_read_value, Dest, freeze);
	input clk;
	input rst;
	input WB_en_in;
	input MEM_R_en_in;
	input [31:0] ALU_result_in;
	input [31:0] Mem_read_value_in;
	input [3:0] Dest_in;
	input freeze;
	output WB_en;
	output MEM_R_en;
	output [31:0] ALU_result;
	output [31:0] Mem_read_value;
	output [3:0] Dest;

	wire [69:0]parin;
	reg [69:0]parout;
	assign	parin = {WB_en_in, MEM_R_en_in, ALU_result_in, Mem_read_value_in, Dest_in};
	assign {WB_en, MEM_R_en, ALU_result, Mem_read_value, Dest} = parout;

	always @(posedge clk, posedge rst) begin
		if(rst)
			parout <= 70'b0;
		else if(~freeze)
			parout <= parin;
	end

endmodule
