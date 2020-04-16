`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 05:45:44 PM
// Design Name: 
// Module Name: StackPtr
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


module StackPtr(
    input SP_CLK,
    input SP_INC,
    input SP_DEC,
    input SP_LD,
    input SP_RST,
    input [7:0] SP_DIN,
    output [7:0] SP_DOUT
    );
    
    logic [7:0] r_stack_ptr = 8'h00;
    
    always_ff @(posedge SP_CLK)
    begin
        if (SP_RST == 1'b1)
            r_stack_ptr = 8'h0;
        else if (SP_LD == 1'b1)
            r_stack_ptr = SP_DIN;
        else if (SP_INC == 1'b1)
            r_stack_ptr = r_stack_ptr + 1;
        else if (SP_DEC == 1'b1)
            r_stack_ptr = r_stack_ptr - 1;
    end
    
    assign SP_DOUT = r_stack_ptr;
    
endmodule
