`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2020 12:18:14 PM
// Design Name: 
// Module Name: RAT_WRAPPER_TB
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


module RAT_WRAPPER_TB;
    logic CLK;
    logic BTNL;
    logic BTNC;
    logic [7:0] SWITCHES;
    logic [7:0] LEDS;
    logic [7:0] CATHODES;
    logic [3:0] ANODES;
    
    RAT_WRAPPER uut (
        .CLK(CLK),
        .BTNL(BTNL),
        .BTNC(BTNC),
        .SWITCHES(SWITCHES),
        .LEDS(LEDS),
        .CATHODES(CATHODES),
        .ANODES(ANODES)
    );
    
    initial
    begin
        BTNC <= 1;
        BTNL <= 0;
        SWITCHES <= 7'b00;
        #20;
        
        BTNC <= 0;
    end
    
    always
    begin
        CLK <= 1; #5;
        CLK <= 0; #5;
    end
endmodule
