`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 05:03:50 PM
// Design Name: 
// Module Name: ArithLogicUnit
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


module ArithLogicUnit(
    input [7:0] ALU_A,
    input [7:0] ALU_B,
    input [3:0] ALU_SEL,
    input ALU_CIN,
    output logic [7:0] ALU_RESULT,
    output logic ALU_C,
    output logic ALU_Z
    );
    
    logic [8:0] r_result;
    
    always_comb
    begin
        r_result = '0;
        case (ALU_SEL)
            4'b0000: r_result = ALU_A + ALU_B;                  // ADD
            4'b0001: r_result = ALU_A + ALU_B + ALU_CIN;        // ADDC
            4'b0010: r_result = ALU_A - ALU_B;                  // SUB
            4'b0011: r_result = ALU_A - ALU_B - ALU_CIN;        // SUBC
            4'b0100: r_result = ALU_A - ALU_B;                  // CMP
            4'b0101: r_result = ALU_A & ALU_B;                  // AND
            4'b0110: r_result = ALU_A | ALU_B;                  // OR
            4'b0111: r_result = ALU_A ^ ALU_B;                  // EXOR
            4'b1000: r_result = ALU_A & ALU_B;                  // TEST
            4'b1001: r_result = {ALU_A,ALU_CIN};                // LSL 
            4'b1010: r_result = {ALU_A[0],ALU_CIN,ALU_A[7:1]};  // LSR
            4'b1011: r_result = {ALU_A,ALU_A[7]};               // ROL
            4'b1100: r_result = {ALU_A[0],ALU_A[0],ALU_A[7:1]}; // ROR
            4'b1101: r_result = {ALU_A[0],ALU_A[7],ALU_A[7:1]}; // ASR
            4'b1110: r_result = {ALU_CIN,ALU_B};                // MOV
            default: r_result = '0;                             // unused
        endcase
        
        ALU_C = r_result[8];
        ALU_RESULT = r_result[7:0];
        
        if (r_result[7:0] == 8'h00)
            ALU_Z = 1'b1;
        else
            ALU_Z = 1'b0;
        
    end
    
endmodule
