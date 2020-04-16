`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2018 01:00:34 AM
// Design Name: 
// Module Name: ProgRom
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


module ProgRom(
    input PROG_CLK,
    input [9:0] PROG_ADDR,
    output logic [17:0] PROG_IR
    );
     
    (* rom_style="{distributed | block}" *)
    logic [17:0] rom[0:1023];
    
    initial begin
        $readmemh("TestAll.mem", rom, 0, 1023);
    end 
    
    always_ff @(posedge PROG_CLK) begin
        PROG_IR <= rom[PROG_ADDR];
    end
              
endmodule
