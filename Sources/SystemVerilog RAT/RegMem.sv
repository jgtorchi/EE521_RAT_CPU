`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/07/2018 04:44:31 PM
// Design Name: 
// Module Name: RegMem
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


module RegMem(
    input [4:0] RF_ADDRX,
    input [4:0] RF_ADDRY,
    input [4:0] RF_ADDR_WR,
    input RF_WR,
    input RF_CLK,
    input [7:0] RF_DIN,
    output [7:0] RF_DX_OUT,
    output [7:0] RF_DY_OUT
    );
    
    logic [7:0] r_memory [31:0];
    
    initial begin
        int i;
        for (i=0; i<32; i++) begin
            r_memory[i] = 0;
        end
    end
    
    assign RF_DX_OUT = r_memory[RF_ADDRX];
    assign RF_DY_OUT = r_memory[RF_ADDRY]; 
    
    always_ff @(posedge RF_CLK)
    begin
        if (RF_WR == 1)
            r_memory[RF_ADDR_WR] <= RF_DIN;
    end
    
endmodule