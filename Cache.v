
module Cache(ready, rdata, clk, clk2, rst, mem_r_en, mem_w_en, addr, wdata);
	input [31:0]addr, wdata;
	input mem_r_en, mem_w_en;
	input clk,clk2,rst;
	output ready;
	output [31:0]rdata;

	reg valid_left[0:63];
	reg valid_right[0:63];

	reg [9:0]tag_left[0:63];
	reg [9:0]tag_right[0:63];

	reg[31:0]word_high_right[0:63];
	reg[31:0]word_low_right[0:63];
	reg[31:0]word_high_left[0:63];
	reg[31:0]word_low_left[0:63];

	reg lru[0:63];

	reg[63:0]data_out;
	reg[31:0]word_out;
	reg hit, miss, s_left, s_right;
//////////////////////////////////////	
	wire SRAM_WE_N;
	wire [31:0]SRAM_DQ0, SRAM_DQ1;
	wire [16:0]SRAM_ADDR;
	wire [63:0]readData;
	wire ready_sram;
	reg [31:0]sram_addr, sram_wdata;
	SRAM_Controller sram_cr(clk, rst, mem_w_en, mem_r_en, sram_addr, sram_wdata, readData, ready_sram, SRAM_DQ0,SRAM_DQ1, SRAM_ADDR, SRAM_WE_N, hit);
	SRAM sram(clk2, rst, SRAM_WE_N, SRAM_ADDR, SRAM_DQ0, SRAM_DQ1);
////////////////////////////////////	
	always @(*) begin
		if(  ( tag_left[addr[8:3]]==addr[18:9] ) & valid_left[addr[8:3]] & mem_r_en  ) s_left=1'b1;
			else s_left=1'b0;
	
		if(  ( tag_right[addr[8:3]]==addr[18:9] ) & valid_right[addr[8:3]] & mem_r_en  ) s_right=1'b1;
			else s_right=1'b0;
		
		if( {s_left,s_right}==2'b10 ) data_out={ word_high_left[addr[8:3]], word_low_left[addr[8:3]] };
			else if( {s_left,s_right}==2'b01 ) data_out={ word_high_right[addr[8:3]], word_low_right[addr[8:3]] };
				else data_out=64'bz;

		if(addr[2]) word_out=data_out[63:32];
			else word_out=data_out[31:0];

		
		hit=s_left | s_right;
		miss=~hit;
	end
/////////////////////////////////
	integer i;
	initial begin
		for( i=0; i<64; i=i+1 ) begin 
			valid_left[i]=1'b0;
			valid_right[i]=1'b0;
			lru[i]=1'b1;	 end
	end
/////////////////////////////////
	always @(posedge clk) begin
		if( ~hit & mem_r_en & ready_sram ) begin
			if( ~lru[addr[8:3]] ) begin
 				{ word_high_left[addr[8:3]], word_low_left[addr[8:3]] }=readData;
				tag_left[addr[8:3]]=addr[18:9];
				valid_left[addr[8:3]]=1'b1;
				lru[addr[8:3]]=1'b1;
				end
			else if	( lru[addr[8:3]] ) begin
 				{ word_high_right[addr[8:3]], word_low_right[addr[8:3]] }=readData;
				tag_right[addr[8:3]]=addr[18:9];
				valid_right[addr[8:3]]=1'b1;
				lru[addr[8:3]]=1'b0;
				end
		end
		else if(mem_w_en) begin
					if(tag_right[addr[8:3]]==addr[18:9]) begin valid_right[addr[8:3]]=1'b0; tag_right[addr[8:3]]=10'bz; end
					else if(tag_left[addr[8:3]]==addr[18:9]) begin valid_left[addr[8:3]]=1'b0; tag_left[addr[8:3]]=10'bz; end
		end
	end
/////////////////////////////////
	always@(posedge clk) begin
		sram_addr <= addr;
		sram_wdata <= wdata;
	end


	assign ready= (hit | ready_sram) | ~(mem_r_en | mem_w_en) ;
	assign rdata=hit ? word_out : addr[2]? readData[63:32] : readData[31:0];
endmodule
