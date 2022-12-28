
module REG_FILE(val_rn,val_rm,clk,rst,src1,src2,wb_dest,wb_value,wb_wb_en);
	output [31:0]val_rn,val_rm;
	input [31:0]wb_value;
	input [3:0]src1,src2,wb_dest;
	input clk,rst,wb_wb_en;

	reg [31:0]register[0:14];
	integer i;
	initial begin
		for (i = 0; i < 15; i=i+1)
			register[i] = i;
	end
		
	assign val_rn = register[src1];
	assign val_rm = register[src2];

	always @(negedge clk or posedge rst) begin
		if (rst) begin
			for (i = 0; i < 15; i=i+1)
				register[i] <= i;
		end
		else if(wb_wb_en)
			register[wb_dest] <= wb_value;
	end
endmodule


module CONTROL(exe_cmd,mem_read,mem_write,wb_en,b,s,opcode,s_in,mode,or_out);
	output reg[3:0]exe_cmd;
	output mem_read,mem_write,wb_en,b,s;
	input [3:0]opcode;
	input [1:0]mode;
	input s_in,or_out;
	
	reg [4:0]signal;
	assign {mem_read,mem_write,wb_en,b,s}=signal;

	always @(*) begin
		if(or_out) begin signal=5'b0; exe_cmd=4'b0; end 
			else if(mode==2'b10) begin signal={5'b00010}; exe_cmd=4'bxxxx; end	//b
				else case({mode,opcode})
					6'b00_1101: begin signal={4'b0010,s_in}; exe_cmd=4'b0001; end	//mov
					6'b00_1111: begin signal={4'b0010,s_in}; exe_cmd=4'b1001; end	//mvn
					6'b00_0100: begin signal={4'b0010,s_in}; exe_cmd=4'b0010; end	//add
					6'b00_0101: begin signal={4'b0010,s_in}; exe_cmd=4'b0011; end	//adc
					6'b00_0010: begin signal={4'b0010,s_in}; exe_cmd=4'b0100; end	//sub
					6'b00_0110: begin signal={4'b0010,s_in}; exe_cmd=4'b0101; end	//sbc
					6'b00_0000: begin signal={4'b0010,s_in}; exe_cmd=4'b0110; end	//and
					6'b00_1100: begin signal={4'b0010,s_in}; exe_cmd=4'b0111; end	//orr
					6'b00_0001: begin signal={4'b0010,s_in}; exe_cmd=4'b1000; end	//eor
					6'b00_1010: begin signal={5'b00001}; exe_cmd=4'b0100; end	//cmp
					6'b00_1000: begin signal={5'b00001}; exe_cmd=4'b0110; end	//tst
					6'b01_0100: begin signal={s_in,~s_in,s_in,2'b00}; exe_cmd=4'b0010; end     //ldr,str
					default: begin signal=5'b0; exe_cmd=4'b0; end
				endcase
	end
endmodule


module CONDITION_CHECK(cond_out,cond,status);
	output reg cond_out;
	input [3:0]status;
	input [3:0]cond;

	wire n,z,c,v;
	assign {n,z,c,v}=status;

	always @(*) begin
		case(cond)
			4'b0000: if(z) cond_out=1'b1; else cond_out=1'b0;
			4'b0001: if(~z) cond_out=1'b1; else cond_out=1'b0;
			4'b0010: if(c) cond_out=1'b1; else cond_out=1'b0;
			4'b0011: if(~c) cond_out=1'b1; else cond_out=1'b0;
			4'b0100: if(n) cond_out=1'b1; else cond_out=1'b0;
			4'b0101: if(~n) cond_out=1'b1; else cond_out=1'b0;
			4'b0110: if(v) cond_out=1'b1; else cond_out=1'b0;
			4'b0111: if(~v) cond_out=1'b1; else cond_out=1'b0;
			4'b1000: if(c & ~z) cond_out=1'b1; else cond_out=1'b0;
			4'b1001: if(~c & z) cond_out=1'b1; else cond_out=1'b0;
			4'b1010: if(n==v) cond_out=1'b1; else cond_out=1'b0;
			4'b1011: if(n!=v) cond_out=1'b1; else cond_out=1'b0;
			4'b1100: if(~z & (n==v)) cond_out=1'b1; else cond_out=1'b0;
			4'b1101: if(z | (n!=v)) cond_out=1'b1; else cond_out=1'b0;
			4'b1110: cond_out=1'b1;
			default: cond_out=1'b1;
		endcase
	end
endmodule


module MUX_SRC2(src2,rm,rd,mem_write);
	output [3:0]src2;
	input [3:0]rm,rd;
	input mem_write;

	assign src2=(mem_write)? rd : rm;
endmodule
