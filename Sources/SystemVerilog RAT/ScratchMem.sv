`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 06:00:59 PM
// Design Name: 
// Module Name: ScratchMem
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


module ScratchMem(
    input SCR_CLK,
    input [7:0] SCR_ADDR,
    input [9:0] SCR_DIN,
    input SCR_WE,
    output [9:0] SCR_DOUT
    );
    
    logic [9:0] r_memory [255:0];
    
    initial begin
        int i;
        for (i=0; i<256; i++) begin
            r_memory[i] = 10'h000;
        end
    end
    
    always_ff @(posedge SCR_CLK) begin
        if (SCR_WE == 1'b1)
            r_memory[SCR_ADDR] = SCR_DIN;
    end
    
    assign SCR_DOUT = r_memory[SCR_ADDR];   
    
endmodule
