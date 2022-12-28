
module ID_Stage(WB_EN, MEM_R_EN, MEM_W_EN, EXE_CMD, B, S, Val_Rn, Val_Rm, imm, Shift_operand, Signed_imm_24,
	Dest, src1, src2, clk, rst, Instruction, hazard, Dest_wb, Result_WB, writeBackEn, SR);
	
	output WB_EN, MEM_R_EN, MEM_W_EN, B, S, imm; 
	output [3:0] EXE_CMD, Dest, src1, src2;
	output [31:0] Val_Rn, Val_Rm;
	output [11:0] Shift_operand;
	output [23:0] Signed_imm_24;
	input  clk, rst, hazard, writeBackEn;
	input [31:0] Instruction, Result_WB;
	input [3:0] Dest_wb, SR;

	wire cond_out;
	assign src1 = Instruction[19:16];
	assign or_out = hazard | ~cond_out;
	assign Dest = Instruction[15:12];
	assign Shift_operand = Instruction[11:0];
	assign Signed_imm_24 = Instruction[23:0];
	assign imm = Instruction[25];

	REG_FILE  Register_File(.val_rn(Val_Rn), .val_rm(Val_Rm), .clk(clk), .rst(rst), .src1(src1), .src2(src2), .wb_dest(Dest_wb), .wb_value(Result_WB), .wb_wb_en(writeBackEn));
	CONTROL  Control_Unit(.exe_cmd(EXE_CMD), .mem_read(MEM_R_EN), .mem_write(MEM_W_EN), .wb_en(WB_EN), .b(B), .s(S), .opcode(Instruction[24:21]), .s_in(Instruction[20]), .mode(Instruction[27:26]), .or_out(or_out));
	CONDITION_CHECK  Cond_Check(.cond_out(cond_out), .cond(Instruction[31:28]), .status(SR));
	MUX_SRC2  Src2_Mux(.src2(src2), .rm(Instruction[3:0]), .rd(Instruction[15:12]), .mem_write(MEM_W_EN));
endmodule
//////////////////
//////////////////

