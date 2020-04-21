`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2020 03:55:01 PM
// Design Name: 
// Module Name: DataForwardEnabler
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


module DataForwardEnabler(
    input  [4:0] ReadAddress,
    input  [4:0] WriteAddress,
    input  Forwarding,
    output ForwardEn
    );
    
logic  AddressEq;
logic  preForwardEn;

always_comb
 begin
    if(ReadAddress == WriteAddress) begin
        preForwardEn = 1; end 
    else    begin 
        preForwardEn = 0; end
end    

assign ForwardEn = preForwardEn & Forwarding;
    
endmodule


