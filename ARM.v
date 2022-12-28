module ARM (clk, clk2, rst, FW, IF_Inst);
	input clk, clk2, rst, FW;
//	inout [31:0]SRAM_DQ;
//	output [16:0]SRAM_ADDR;
//	output SRAM_WE_N;
output [31:0] IF_Inst;

	//IF
	wire [31:0] IF_PC;
	
	//IF_ID Registers
	wire [31:0] IF_ID_PC, IF_ID_Inst;

	//ID
	wire ID_WB_EN, ID_MEM_R_EN, ID_MEM_W_EN, ID_B, ID_S;
	wire [3:0] ID_EXE_CMD;
	wire [31:0] ID_Val_Rn, ID_Val_Rm; 
	wire ID_imm; 
	wire [11:0] ID_Shift_operand;
	wire [23:0] ID_Signed_imm_24;
	wire [3:0] ID_Dest, ID_src1, ID_src2;

	//ID_EX Registers
	wire ID_EX_WB_EN, ID_EX_MEM_R_EN, ID_EX_MEM_W_EN, ID_EX_B, ID_EX_S;
	wire [3:0] ID_EX_EXE_CMD;
	wire [31:0] ID_EX_PC, ID_EX_Val_Rn, ID_EX_Val_Rm;
	wire ID_EX_imm; 
	wire [11:0] ID_EX_Shift_operand;
	wire [23:0] ID_EX_Signed_imm_24;
	wire [3:0] ID_EX_Dest, ID_EX_src1, ID_EX_src2;
	wire [3:0] EXE_SR;

	//EX
	wire flush, Branch_taken;
	wire [31:0] EX_ALU_result, EX_Br_addr; 
	wire [3:0] EX_status_bits;
	wire [31:0]val2_src;

	assign Branch_taken = ID_EX_B;
	assign flush = ID_EX_B;

	//Status Register
	wire [3:0] SR;
	
	//EX_MEM Registers
	wire EX_MEM_WB_EN, EX_MEM_MEM_R_EN, EX_MEM_MEM_W_EN; 
	wire [31:0] EX_MEM_ALU_result, EX_MEM_ST_val; 
	wire [3:0] EX_MEM_Dest;

	//SRAM Controller
	wire [31:0] MEM_mem_result;
	wire ready;

	//MEM_WB Registers
	wire MEM_WB_WB_EN, MEM_WB_MEM_R_en;
	wire [31:0] MEM_WB_ALU_result, MEM_WB_Mem_read_value; 
	wire [3:0] MEM_WB_Dest;
	
	//WB
	wire WB_WriteBack_En;
	wire [3:0] WB_Dest;
	wire [31:0] WB_Value;

	assign WB_WriteBack_En = MEM_WB_WB_EN;
	assign WB_Dest = MEM_WB_Dest;

	//Hazard Detection Unit//
	wire hazard_Detected;



	/// forwarding_unit//
	wire[1:0]sel_src1,sel_src2;

	//IF
	IF_Stage if_stage(
		.clk(clk),
		.rst(rst),
		.freeze(hazard_Detected | ~ready), 
		.Branch_taken(Branch_taken), 
		.BranchAddr(EX_Br_addr), 
		.PC(IF_PC), 
		.Instruction(IF_Inst)
		);
	
	//IF_ID Registers
	IF_Stage_Reg if_stage_reg(
		.clk(clk), 
		.rst(rst), 
		.flush(flush), 
		.PC_in(IF_PC), 
		.Instruction_in(IF_Inst), 
		.PC(IF_ID_PC), 
		.Instruction(IF_ID_Inst),
		.freeze(hazard_Detected | ~ready)
		);

	//ID
	ID_Stage id_stage(
		.clk(clk), 
		.rst(rst), 
		.Instruction(IF_ID_Inst), 
		.Result_WB(WB_Value), 
		.writeBackEn(WB_WriteBack_En), 
		.Dest_wb(WB_Dest), 
		.SR(SR),
		.WB_EN(ID_WB_EN), 
		.MEM_R_EN(ID_MEM_R_EN), 
		.MEM_W_EN(ID_MEM_W_EN), 
		.B(ID_B), 
		.S(ID_S), 
		.EXE_CMD(ID_EXE_CMD), 
		.Val_Rn(ID_Val_Rn), 
		.Val_Rm(ID_Val_Rm), 
		.imm(ID_imm), 
		.Shift_operand(ID_Shift_operand), 
		.Signed_imm_24(ID_Signed_imm_24), 
		.Dest(ID_Dest),
		.src1(ID_src1), 
		.src2(ID_src2),
		.hazard(hazard_Detected)
		);

	//ID_EX Registers
	ID_Stage_Reg id_stage_reg(
		.clk(clk), 
		.rst(rst), 
		.flush(flush), 
		.WB_EN_IN(ID_WB_EN), 
		.MEM_R_EN_IN(ID_MEM_R_EN), 
		.MEM_W_EN_IN(ID_MEM_W_EN),
		.B_IN(ID_B), 
		.S_IN(ID_S), 
		.EXE_CMD_IN(ID_EXE_CMD), 
		.PC_IN(IF_ID_PC), 
		.Val_Rn_IN(ID_Val_Rn), 
		.Val_Rm_IN(ID_Val_Rm),
		.imm_IN(ID_imm), 
		.Shift_operand_IN(ID_Shift_operand), 
		.Signed_imm_24_IN(ID_Signed_imm_24), 
		.Dest_IN(ID_Dest),
		.src1_IN(ID_src1),
		.src2_IN(ID_src2),
		.WB_EN(ID_EX_WB_EN), 
		.MEM_R_EN(ID_EX_MEM_R_EN), 
		.MEM_W_EN(ID_EX_MEM_W_EN), 
		.B(ID_EX_B), 
		.S(ID_EX_S), 
		.EXE_CMD(ID_EX_EXE_CMD), 
		.PC(ID_EX_PC), 
		.Val_Rn(ID_EX_Val_Rn), 
		.Val_Rm(ID_EX_Val_Rm),
		.imm(ID_EX_imm), 
		.Shift_operand(ID_EX_Shift_operand), 
		.Signed_imm_24(ID_EX_Signed_imm_24), 
		.Dest(ID_EX_Dest),
		.SR(SR),
		.EXE_SR(EXE_SR),
		.src1(ID_EX_src1),
		.src2(ID_EX_src2),
		.freeze(~ready)
		);

	//EX
	EXE_Stage exe_stage(
		.clk(clk), 
		.EXE_CMD(ID_EX_EXE_CMD), 
		.MEM_R_EN(ID_EX_MEM_R_EN), 
		.MEM_W_EN(ID_EX_MEM_W_EN), 
		.PC(ID_EX_PC), 
		.Val_Rn(ID_EX_Val_Rn), 
		.Val_Rm(ID_EX_Val_Rm), 
		.imm(ID_EX_imm), 
		.Shift_operand(ID_EX_Shift_operand), 
		.Signed_imm_24(ID_EX_Signed_imm_24), 
		.SR(EXE_SR),
		.ALU_result(EX_ALU_result), 
		.Br_addr(EX_Br_addr),
		.status(EX_status_bits),     
		.sel_src1(sel_src1),
		.sel_src2(sel_src2),
		.alu_res(EX_MEM_ALU_result),
		.wb_value(WB_Value),
		.val2_src(val2_src)
		);

	//Status Register
	StatusRegister status_register(
		.clk(clk),
		.rst(rst),
		.d(EX_status_bits),
		.s(ID_EX_S),
		.q(SR),
		.freeze(~ready)
		);

	//EX_MEM Registers
	EXE_reg exe_reg(
		.clk(clk), 
		.rst(rst), 
		.WB_en_in(ID_EX_WB_EN), 
		.MEM_R_EN_in(ID_EX_MEM_R_EN), 
		.MEM_W_EN_in(ID_EX_MEM_W_EN), 
		.ALU_result_in(EX_ALU_result), 
		.ST_val_in(val2_src), 
		.Dest_in(ID_EX_Dest),
		.WB_en(EX_MEM_WB_EN), 
		.MEM_R_EN(EX_MEM_MEM_R_EN), 
		.MEM_W_EN(EX_MEM_MEM_W_EN), 
		.ALU_result(EX_MEM_ALU_result), 
		.ST_val(EX_MEM_ST_val), 
		.Dest(EX_MEM_Dest),
		.freeze(~ready)
		);

	//SRAM Controller
	//SRAM_Controller sram_controller(.clk(clk),
//		.rst(rst),
//		.write_en(EX_MEM_MEM_W_EN),
//		.read_en(EX_MEM_MEM_R_EN),
//		.address(EX_MEM_ALU_result),
//		.writeData(EX_MEM_ST_val),
//		.readData(MEM_mem_result),
//		.ready(ready),
//		.SRAM_DQ(SRAM_DQ),
//		.SRAM_ADDR(SRAM_ADDR),
//		.SRAM_WE_N(SRAM_WE_N)
//	);
	 Cache cachem(.ready(ready), 
		.rdata(MEM_mem_result), 
		.clk(clk), .clk2(clk2), 
		.rst(rst), 
		.mem_r_en(EX_MEM_MEM_R_EN), 
		.mem_w_en(EX_MEM_MEM_W_EN), 
		.addr(EX_MEM_ALU_result), 
		.wdata(EX_MEM_ST_val)
	);	

	//MEM_WB Registers
	MEM_reg mem_reg(
		.clk(clk), 
		.rst(rst), 
		.WB_en_in(EX_MEM_WB_EN), 
		.MEM_R_en_in(EX_MEM_MEM_R_EN),
		.ALU_result_in(EX_MEM_ALU_result), 
		.Mem_read_value_in(MEM_mem_result), 
		.Dest_in(EX_MEM_Dest),
		.WB_en(MEM_WB_WB_EN), 
		.MEM_R_en(MEM_WB_MEM_R_en), 
		.ALU_result(MEM_WB_ALU_result), 
		.Mem_read_value(MEM_WB_Mem_read_value), 
		.Dest(MEM_WB_Dest),
		.freeze(~ready)
		);
	
	//WB
	WB_Stage wb_stage(
		.ALU_result(MEM_WB_ALU_result), 
		.MEM_result(MEM_WB_Mem_read_value), 
		.MEM_R_en(MEM_WB_MEM_R_en),
		.out(WB_Value)
		);

	//Hazard Detection Unit
	hazard_Detection_Unit hazard_detection_unit(
		.src1(ID_src1), 
		.src2(ID_src2),
		.Exe_Dest(ID_EX_Dest), 
		.Exe_WB_EN(ID_EX_WB_EN),
		.Mem_Dest(EX_MEM_Dest), 
		.Mem_WB_EN(EX_MEM_WB_EN),
		.hazard_Detected(hazard_Detected),
		.EXE_CMD(ID_EXE_CMD),
		.imm(ID_imm),    
		.MEM_W_EN(ID_MEM_W_EN),
		.ID_EX_MEM_R_EN(ID_EX_MEM_R_EN),
		.FW(FW)
		);

	//forwarding unit
	Forwarding_Unit fu(ID_EX_src1, ID_EX_src2, EX_MEM_Dest, EX_MEM_WB_EN, WB_Dest, WB_WriteBack_En, sel_src1, sel_src2);

endmodule
