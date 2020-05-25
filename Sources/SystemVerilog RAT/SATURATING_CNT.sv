`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2020 05:39:58 PM
// Design Name: 
// Module Name: SATURATING_CNT
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


module SATURATING_CNT(
    input SC_CLK,
    input SC_CNT_RST,
    input SC_CNT_INC,
    input SC_CNT_DEC,
    output [1:0] SC_CNT_OUT
    );
    
    logic [1:0] sat_cnt;
    
    always @(posedge SC_CLK) 
    begin : manage_cnt
        if (SC_CNT_RST == 1'b1)
            begin
            sat_cnt <= 2'b10;
            end
        else if (SC_CNT_INC == 1'b1)
            begin
            if (sat_cnt < 3)
                begin
                sat_cnt <= sat_cnt + 1;
                end
            end
        else if (SC_CNT_DEC == 1'b1)
            begin
            if (sat_cnt > 0)
                begin
                sat_cnt <= sat_cnt - 1; 
                end
            end
    end : manage_cnt
    
    assign SC_CNT_OUT = sat_cnt;
endmodule
