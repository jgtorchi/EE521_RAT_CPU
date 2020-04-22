`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2020 02:05:45 AM
// Design Name: 
// Module Name: NopGenerator
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


module NopGenerator(
    input CLK,
    input RESET,
    input UNCON_BRN,
    input TAKE_COND_BRN,
    output EX_NOP, 
    output WB_NOP  
    );
    
    logic [2:0] NOP_COUNT = 0;
    logic PRE_EX_NOP;
    logic PRE_WB_NOP;
    
    always_ff @(posedge CLK)
    begin : NOP_CNT
        if (RESET == 1'b1)
            NOP_COUNT <= 0;
        else
            if (NOP_COUNT > 0)  
                NOP_COUNT <= NOP_COUNT - 1;
            if (((TAKE_COND_BRN == 1'b1) | (UNCON_BRN == 1'b1)) & (NOP_COUNT <= 1))
                NOP_COUNT <= 4;
    end : NOP_CNT
    
    always_comb
    begin : GENERATE_EX_NOP
        if (NOP_COUNT>1) begin
            PRE_EX_NOP <= 1'b1; end
        else begin
            PRE_EX_NOP <= 1'b0; end
    end : GENERATE_EX_NOP
    
    assign EX_NOP = PRE_EX_NOP | TAKE_COND_BRN | UNCON_BRN;
    
    always_comb
    begin : GENERATE_WB_NOP
        if (NOP_COUNT>0) begin
            PRE_WB_NOP <= 1'b1; end
        else begin
            PRE_WB_NOP <= 1'b0; end
    end : GENERATE_WB_NOP
    
    assign WB_NOP = PRE_WB_NOP;
    
endmodule
