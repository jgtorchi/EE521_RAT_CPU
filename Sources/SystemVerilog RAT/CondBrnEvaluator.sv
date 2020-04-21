`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2020 02:12:00 AM
// Design Name: 
// Module Name: CondBrnEvaluator
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


module CondBrnEvaluator(
    input COND_BRN,
    input [1:0] COND_BRN_TYPE,
    input C_FLAG,
    input Z_FLAG,
    output TAKE_COND_BRN
    );
    
    logic PRE_TAKE_COND_BRN;
    always_comb
    begin
    PRE_TAKE_COND_BRN <= 1'b0;
        case (COND_BRN_TYPE)
        
            2'b00: begin            // BRCC
                if (C_FLAG == 1'b0) begin
                    PRE_TAKE_COND_BRN <= 1'b1;
                end
            end
            
            2'b01: begin            // BRCS
                if (C_FLAG == 1'b1) begin
                    PRE_TAKE_COND_BRN <= 1'b1;
                end
            end
            
            2'b10: begin            // BREQ
                if (Z_FLAG == 1'b1) begin
                    PRE_TAKE_COND_BRN <= 1'b1;
                end
            end
            
            2'b11: begin            // BRNE
                if (Z_FLAG == 1'b0) begin
                    PRE_TAKE_COND_BRN <= 1'b1;
                end
            end
            
            default:          // failsafe
              PRE_TAKE_COND_BRN <= 1'b0;
              
        endcase
    end
    
    assign TAKE_COND_BRN = PRE_TAKE_COND_BRN & COND_BRN;
endmodule
