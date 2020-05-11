`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2020 03:55:11 AM
// Design Name: 
// Module Name: BranchPredictor
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


module BranchPredictor(
    input [4:0] BP_OPCODE_HI_5,
    input [1:0] BP_OPCODE_LO_2,
    input [9:0] BP_CURR_ADDR,
    input [9:0] BP_BRN_ADDR,
    input BP_NOP_CLR,
    output BP_PC_LD,
    output BP_PC_CNT_MUX_SEL,
    output BP_COND_BRN_TAKEN 
    );
    
    logic uncond_pc_cnt_mux_sel;
    logic uncond_pc_ld;
    logic [6:0] s_opcode;
    assign s_opcode = {BP_OPCODE_HI_5,BP_OPCODE_LO_2};
    
    always_comb
    begin : UNCOND_BRN_PREDICTOR
        uncond_pc_cnt_mux_sel <= 1'b0;
        uncond_pc_ld          <= 1'b0;
        if (BP_NOP_CLR == 1'b1) 
            begin
            uncond_pc_cnt_mux_sel <= 1'b0;
            uncond_pc_ld          <= 1'b0;
            end
        else
            begin
            //if brn or call
            if( (s_opcode == 7'b0010000) | (s_opcode == 7'b0010001) )
                begin
                //then branch
                uncond_pc_cnt_mux_sel <= 1'b1;
                uncond_pc_ld          <= 1'b1;
                end
            end
    end
    
    assign BP_PC_LD = uncond_pc_ld;
    assign BP_PC_CNT_MUX_SEL = uncond_pc_cnt_mux_sel;    
    
endmodule
