`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2020 05:39:58 PM
// Design Name: 
// Module Name: BRN_ENTRY
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


module BRN_ENTRY(
    input BE_CLK,
    input [9:0] BE_BRN_ADDR_IN,
    input BE_BRN_ADDR_WE,
    output [9:0] BE_BRN_ADDR_OUT
    );
    
    logic [9:0] brn_addr;
    
    always @(posedge BE_CLK) 
    begin : write_addr
        if(BE_BRN_ADDR_WE == 1'b1)
            begin
            brn_addr <= BE_BRN_ADDR_IN;
            end
    end :write_addr
    
    assign BE_BRN_ADDR_OUT = brn_addr;
    
endmodule
