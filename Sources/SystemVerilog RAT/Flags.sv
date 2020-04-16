`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 06:05:27 PM
// Design Name: 
// Module Name: Flags
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Flags(
		input FLG_CLK,
		input FLG_C_SET,
		input FLG_C_CLR,
		input FLG_C_LD,
		input FLG_Z_LD,
		input FLG_LD_SEL,
		input FLG_SHAD_LD,
		input FLG_CIN,
		input FLG_ZIN,
		output FLG_COUT,
		output FLG_ZOUT);

	logic s_cin, s_zin, r_cout, r_zout, r_c_shad, r_z_shad = 1'b0;
	
	//Z Flag MUX
	always_comb
	begin
		if (FLG_LD_SEL == 1'b0) 
			s_zin = FLG_ZIN;
		else
			s_zin = r_z_shad;
	end
	
	//C Flag MUX
	always_comb
	begin
		if (FLG_LD_SEL == 1'b0) 
			s_cin = FLG_CIN;
		else
			s_cin = r_c_shad;
	end
	
	// Z Flag
	always_ff @ (posedge FLG_CLK)
	begin
		if (FLG_Z_LD == 1'b1)
			r_zout = s_zin;
	end
	
	// C Flag
	always_ff @ (posedge FLG_CLK)
	begin
		if (FLG_C_CLR == 1'b1)
			r_cout = 1'b0;
		else if (FLG_C_SET == 1'b1)
			r_cout = 1'b1;
		else if (FLG_C_LD == 1'b1)
			r_cout = s_cin;
	end

	// Z Shadow Flag
	always_ff @ (posedge FLG_CLK)
	begin
		if (FLG_SHAD_LD == 1'b1)
			r_z_shad = r_zout;
	end

	// C Shadow Flag
	always_ff @ (posedge FLG_CLK)
	begin
		if (FLG_SHAD_LD == 1'b1)
			r_c_shad = r_cout;
	end
	
	// Assign Flag Outputs
	assign FLG_COUT = r_cout;
	assign FLG_ZOUT = r_zout;
		
endmodule


