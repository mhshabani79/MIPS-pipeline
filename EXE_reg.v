module EXE_reg (clk, rst, WB_en_in, MEM_R_EN_in, MEM_W_EN_in, ALU_result_in, ST_val_in, Dest_in,
		WB_en, MEM_R_EN, MEM_W_EN, ALU_result, ST_val, Dest, freeze);
	input clk,rst, WB_en_in, MEM_R_EN_in, MEM_W_EN_in;
	input [31:0] ALU_result_in,ST_val_in;
	input [3:0] Dest_in; 
	input freeze;
	output WB_en, MEM_R_EN, MEM_W_EN;
	output [31:0] ALU_result, ST_val;
	output [3:0] Dest;
	
	wire [70:0]parin;
	reg [70:0]parout;
	assign	parin = {WB_en_in, MEM_R_EN_in, MEM_W_EN_in, ALU_result_in, ST_val_in, Dest_in};
	assign {WB_en, MEM_R_EN, MEM_W_EN, ALU_result, ST_val, Dest} = parout;

	always @(posedge clk, posedge rst) begin
		if(rst)
			parout <= 70'b0;
		else if(~freeze)
			parout <= parin;
	end

endmodule
