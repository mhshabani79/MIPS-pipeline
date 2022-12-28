
module ID_Stage_Reg(WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S, PC,
	Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, EXE_SR, src1, src2,
	clk, rst, flush, WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, EXE_CMD_IN, B_IN, S_IN, PC_IN,
	Val_Rn_IN, Val_Rm_IN, imm_IN, Shift_operand_IN, Signed_imm_24_IN, Dest_IN, SR, src1_IN, src2_IN, freeze);
	
	output  WB_EN, MEM_R_EN, MEM_W_EN, B, S, imm;
	output [3:0] EXE_CMD, Dest, EXE_SR;
	output [31:0] PC, Val_Rn, Val_Rm;
	output [11:0] Shift_operand;
	output [23:0] Signed_imm_24;
	output [3:0] src1, src2;
	input clk, rst, flush, WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, B_IN, S_IN, imm_IN;
	input [3:0] EXE_CMD_IN, Dest_IN, SR;
	input [31:0] PC_IN, Val_Rn_IN, Val_Rm_IN;
	input [11:0] Shift_operand_IN;
	input [23:0] Signed_imm_24_IN;
	input [3:0] src1_IN, src2_IN;
	input freeze;

	wire [157:0]parin;
	reg [157:0]parout;
	assign	parin = {WB_EN_IN, MEM_R_EN_IN, MEM_W_EN_IN, EXE_CMD_IN, B_IN, S_IN, PC_IN,
		Val_Rn_IN, Val_Rm_IN, imm_IN, Shift_operand_IN, Signed_imm_24_IN, Dest_IN, SR, src1_IN, src2_IN};

	assign {WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S, PC,
		Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24, Dest, EXE_SR, src1, src2} = parout;

	always @(posedge clk,posedge rst) begin
		if(rst) parout <= 158'b0;
		else if(flush)
			parout <= 158'b0;
		else if(~freeze)
			parout <= parin;
	end
endmodule
//////////////////
//////////////////