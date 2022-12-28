module EXE_Stage(clk, EXE_CMD, MEM_R_EN, MEM_W_EN, imm, PC, Val_Rn, Val_Rm, Shift_operand, Signed_imm_24,
		SR, ALU_result, Br_addr, status, sel_src1, sel_src2, alu_res, wb_value, val2_src);
	input clk; //not needed
	input [3:0] EXE_CMD;
	input MEM_R_EN;
	input MEM_W_EN;
	input [31:0] PC;
	input [31:0] Val_Rn, Val_Rm;
	input imm; 
	input [11:0] Shift_operand;
	input [23:0] Signed_imm_24;
	input [3:0] SR;
	output [31:0] ALU_result, Br_addr;
	output [3:0] status;
	input [1:0] sel_src1, sel_src2;
	input [31:0] alu_res, wb_value;
	output [31:0] val2_src;

	wire mem_flag;
	wire [31:0]val2;
	assign mem_flag = MEM_R_EN | MEM_W_EN;

	MUX_ALU2 ma2(val2_src, Val_Rm, alu_res, wb_value, sel_src2);
	VAL2_GENERATE Val2_Generate(val2_src, Shift_operand, imm, mem_flag, val2);

	wire c_in;
	assign c_in = SR[1];
	
	wire [31:0] alu_src1;
	MUX_ALU1  ma1(alu_src1, Val_Rn, alu_res, wb_value, sel_src1);

	ALU ALU(alu_src1, val2, EXE_CMD, c_in, ALU_result, status);

	wire [31:0]Signed_imm_24_extended;
	assign Signed_imm_24_extended = {{8{Signed_imm_24[23]}},Signed_imm_24} << 2;

	ADDER32 Br_Addr_Adder(PC, Signed_imm_24_extended, Br_addr);

endmodule
