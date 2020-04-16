`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 06:28:43 PM
// Design Name: 
// Module Name: InterReg
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


module InterReg(
    input I_SET,
    input I_CLR,
    input I_CLK,
    output I_OUT
    );
    
    logic r_intr = 1'b0;
    
    always_ff @(posedge I_CLK)
    begin
        if (I_CLR == 1'b1)
            r_intr = 1'b0;
        else if (I_SET == 1'b1)
            r_intr = 1'b1;
    end
    
    assign I_OUT = r_intr;
    
endmodule
