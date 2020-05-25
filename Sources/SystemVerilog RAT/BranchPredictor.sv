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
    input BP_CLK,
    input [4:0] BP_OPCODE_HI_5,
    input [1:0] BP_OPCODE_LO_2,
    input [9:0] BP_CURR_ADDR,
    input BP_NOP_CLR,
    input BP_EX_NOP,
    input BP_TAKE_COND_BRN,
    input BP_DECODE_COND_BRN,
    input [9:0] BP_EVAL_BRN_ADDR,
    output BP_PC_LD,
    output BP_PC_CNT_MUX_SEL,
    output BP_COND_BRN_TAKEN 
    );
    
    logic uncond_pc_cnt_mux_sel;
    logic uncond_pc_ld;
    logic cond_pc_cnt_mux_sel;
    logic cond_pc_ld;
    logic cond_brn_taken;
    logic [6:0] s_opcode;
    assign s_opcode = {BP_OPCODE_HI_5,BP_OPCODE_LO_2};
    
    //history table signals
    logic [9:0] brn_addresses [3:0];//a 10-bit vector net with a depth of 4, stores the branch addresses
    logic [3:0] brn_addresses_we;
    logic [1:0] sat_cnts [3:0]; //saturating counters
    logic [3:0] cnt_inc;
    logic [3:0] cnt_dec;
    logic [3:0] cnt_rst;
    logic [1:0] overwrite_target = 2'b00;
    logic overwrite_target_inc;
    
    
    
    always_comb
    begin : UNCOND_BRN_PREDICTOR
        uncond_pc_cnt_mux_sel <= 1'b0;
        uncond_pc_ld          <= 1'b0;
        if (BP_NOP_CLR == 1'b0) 
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
    
    always_comb
    begin : COND_BRN_PREDICTOR
        cond_pc_cnt_mux_sel <= 1'b0;
        cond_pc_ld          <= 1'b0;
        cond_brn_taken      <= 1'b0;
        if (BP_NOP_CLR == 1'b0) 
            begin
            if( (s_opcode == 7'b0010101) | (s_opcode == 7'b0010100) | (s_opcode == 7'b0010010) | (s_opcode == 7'b0010011) )
                begin
                if(BP_CURR_ADDR == brn_addresses[0])
                    begin
                        if(sat_cnts[0] > 1) //take branch
                            begin
                            cond_pc_cnt_mux_sel <= 1'b1;
                            cond_pc_ld          <= 1'b1;
                            cond_brn_taken      <= 1'b1;
                            end
                    end
                else if(BP_CURR_ADDR == brn_addresses[1])
                    begin
                        if(sat_cnts[1] > 1) //take branch
                            begin
                            cond_pc_cnt_mux_sel <= 1'b1;
                            cond_pc_ld          <= 1'b1;
                            cond_brn_taken      <= 1'b1;
                            end
                    end
                else if(BP_CURR_ADDR == brn_addresses[2])
                    begin
                        if(sat_cnts[2] > 1) //take branch
                            begin
                            cond_pc_cnt_mux_sel <= 1'b1;
                            cond_pc_ld          <= 1'b1;
                            cond_brn_taken      <= 1'b1;
                            end
                    end
                else if(BP_CURR_ADDR == brn_addresses[3])
                    begin
                        if(sat_cnts[3] > 1) //take branch
                            begin
                            cond_pc_cnt_mux_sel <= 1'b1;
                            cond_pc_ld          <= 1'b1;
                            cond_brn_taken      <= 1'b1;
                            end
                    end
                else //take branch, if not in table
                    begin
                    cond_pc_cnt_mux_sel <= 1'b1;
                    cond_pc_ld          <= 1'b1;
                    cond_brn_taken      <= 1'b1;
                    end
                end
            end
    end
    
    always_comb
    begin : Write_addr_cnt_control
        cnt_inc              <= 4'b0000;
        cnt_dec              <= 4'b0000;
        cnt_rst              <= 4'b0000;
        brn_addresses_we     <= 4'b0000;
        overwrite_target_inc <= 1'b0;
        if (BP_EX_NOP == 1'b0)
            begin
            if (BP_DECODE_COND_BRN == 1'b1)
                begin
                if(BP_EVAL_BRN_ADDR == brn_addresses[0])
                    begin
                    if (BP_TAKE_COND_BRN == 1'b1)
                        begin
                        cnt_inc[0] <= 1'b1;
                        end
                    else
                        begin
                        cnt_dec[0] <= 1'b1;
                        end
                    end
                else if(BP_EVAL_BRN_ADDR == brn_addresses[1])
                    begin
                    if (BP_TAKE_COND_BRN == 1'b1)
                        begin
                        cnt_inc[1] <= 1'b1;
                        end
                    else
                        begin
                        cnt_dec[1] <= 1'b1;
                        end 
                    end
                else if(BP_EVAL_BRN_ADDR == brn_addresses[2])
                    begin
                    if (BP_TAKE_COND_BRN == 1'b1)
                        begin
                        cnt_inc[2] <= 1'b1;
                        end
                    else
                        begin
                        cnt_dec[2] <= 1'b1;
                        end 
                    end
                else if(BP_EVAL_BRN_ADDR == brn_addresses[3])
                    begin
                    if (BP_TAKE_COND_BRN == 1'b1)
                        begin
                        cnt_inc[3] <= 1'b1;
                        end
                    else
                        begin
                        cnt_dec[3] <= 1'b1;
                        end 
                    end
                else
                    begin
                    overwrite_target_inc <= 1'b1;
                    if(overwrite_target == 2'b00)
                        begin
                        cnt_rst[0]          <= 1'b1;
                        brn_addresses_we[0] <= 1'b1;
                        end
                    else if(overwrite_target == 2'b01)
                        begin
                        cnt_rst[1]          <= 1'b1;
                        brn_addresses_we[1] <= 1'b1;
                        end
                    else if(overwrite_target == 2'b10)
                        begin
                        cnt_rst[2]          <= 1'b1;
                        brn_addresses_we[2] <= 1'b1;
                        end
                    else
                        begin
                        cnt_rst[3]          <= 1'b1;
                        brn_addresses_we[3] <= 1'b1;
                        end
                    end
                end
            end
    end : Write_addr_cnt_control
    
    always @(posedge BP_CLK) 
    begin : overwrite_target_cnt
        if (overwrite_target_inc == 1'b1)
            begin
            if (overwrite_target > 2)
                begin
                overwrite_target <= 2'b00;
                end
            else
                begin
                overwrite_target <= overwrite_target + 1;
                end
            end
    end : overwrite_target_cnt
    
    genvar i;
    // Generate for loop to instantiate N times
    generate 
        for (i = 0; i < 4; i = i + 1) begin
            BRN_ENTRY be (.BE_CLK(BP_CLK), .BE_BRN_ADDR_IN(BP_EVAL_BRN_ADDR),
                .BE_BRN_ADDR_WE(brn_addresses_we[i]), .BE_BRN_ADDR_OUT(brn_addresses[i]) );
            SATURATING_CNT sc ( .SC_CLK(BP_CLK), .SC_CNT_RST(cnt_rst[i]), .SC_CNT_INC(cnt_inc[i]), 
                .SC_CNT_DEC(cnt_dec[i]), .SC_CNT_OUT(sat_cnts[i]));
    end
    endgenerate
    
    assign BP_PC_LD = uncond_pc_ld | cond_pc_ld;
    assign BP_PC_CNT_MUX_SEL = uncond_pc_cnt_mux_sel | cond_pc_cnt_mux_sel;  
    assign BP_COND_BRN_TAKEN = cond_brn_taken;  
    
endmodule
