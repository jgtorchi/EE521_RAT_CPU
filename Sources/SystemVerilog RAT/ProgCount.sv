`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 04:21:54 PM
// Design Name: 
// Module Name: ProgCount
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


module ProgCount(
    input PC_CLK,
    input PC_RST,
    input PC_LD,
    input [9:0] PC_DIN,
    output [9:0] PC_COUNT
    );
    
    logic [9:0] r_count = 0;
    
    always_ff @(posedge PC_CLK)
    begin
        if (PC_RST == 1'b1)
            r_count <= '0;
        else if (PC_LD == 1'b1)
            r_count <= PC_DIN;
        else
            r_count <= r_count + 1;
    end
    
    assign PC_COUNT = r_count;
    
endmodule
