`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Paul Hummel
//
// Create Date: 06/28/2018 05:21:01 AM
// Module Name: RAT_WRAPPER
// Target Devices: RAT MCU on Basys3
// Description: RAT_WRAPPER with VGA connections
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////

module RAT_WRAPPER(
    input CLK,
    input BTNL,
    input BTNC,
    input [7:0] SWITCHES,
    output [7:0] LEDS,
    output [7:0] CATHODES,
    output [3:0] ANODES
//    output [7:0] VGA_RGB,
//    output VGA_HS,
//    output VGA_VS
    );
    
    // INPUT PORT IDS ////////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more port IDs, and you'll have
    // to add constants here for the mux below
    localparam SWITCHES_ID = 8'h20;
//    localparam VGA_READ_ID = 8'h93;
       
    // OUTPUT PORT IDS ///////////////////////////////////////////////////////
    // In future labs you can add more port IDs
    localparam LEDS_ID      = 8'h40;
    localparam SSEG0_ID     = 8'h81;
    localparam SSEG1_ID     = 8'h82;
//    localparam VGA_HADDR_ID = 8'h90;
//    localparam VGA_LADDR_ID = 8'h91;
//    localparam VGA_COLOR_ID = 8'h92;
       
    // Signals for connecting RAT_MCU to RAT_wrapper /////////////////////////
    logic [7:0] s_output_port;
    logic [7:0] s_port_id;
    logic s_load;
    logic s_interrupt;
    logic s_reset;
    logic s_clk_50 = 1'b0;     // 50 MHz clock
    
    // Signals for connecting VGA Framebuffer Driver
//    logic r_vga_we;             // write enable
//    logic [10:0] r_vga_wa;      // address of framebuffer to read and write
//    logic [7:0] r_vga_wd;       // pixel color data to write to framebuffer
//    logic [7:0] r_vga_rd;       // pixel color data read from framebuffer
     
    // Register definitions for output devices ///////////////////////////////
    logic [7:0]   s_input_port;
    logic [7:0]   r_LEDS = 8'h00;
    logic [15:0]  r_SSEG = 16'h0000;
         
    // Declare RAT_CPU ///////////////////////////////////////////////////////
    RATMCU MCU (.IN_PORT(s_input_port), .OUT_PORT(s_output_port),
                .PORT_ID(s_port_id), .IO_STRB(s_load), .RESET(s_reset),
                .INTR(s_interrupt), .CLK(s_clk_50));
    
    // Declare Seven Segment Display /////////////////////////////////////////
    SevSegDisp SSG_DISP (.DATA_IN(r_SSEG), .CLK(CLK), .MODE(1'b0),
                        .CATHODES(CATHODES), .ANODES(ANODES));
    
    // Declare Debouncer One Shot  ///////////////////////////////////////////
//    debounce_one_shot DB(.CLK(s_clk_50), .BTN(BTNL), .DB_BTN(s_interrupt));
    
    
    // Declare VGA Frame Buffer //////////////////////////////////////////////
//    vga_fb_driver VGA(.CLK(s_clk_50), .WA(r_vga_wa), .WD(r_vga_wd),
//                        .WE(r_vga_we), .RD(r_vga_rd), .ROUT(VGA_RGB[7:5]),
//                        .GOUT(VGA_RGB[4:2]), .BOUT(VGA_RGB[1:0]),
//                        .HS(VGA_HS), .VS(VGA_VS));
    
    // Clock Divider to create 50 MHz Clock /////////////////////////////////
    always_ff @(posedge CLK) begin
        s_clk_50 <= ~s_clk_50;
    end
    
     
    // MUX for selecting what input to read //////////////////////////////////
    always_comb begin
        if (s_port_id == SWITCHES_ID)
            s_input_port = SWITCHES;
//        else if (s_port_id == VGA_READ_ID)
//            s_input_port = r_vga_rd;
        else
            s_input_port = 8'h00;
    end
   
    // MUX for updating output registers //////////////////////////////////////////
    // Register updates depend on rising clock edge and asserted load signal
    always_ff @ (posedge CLK) begin
//        r_vga_we <= 1'b0;           // reset VGA framebuffer write enable to 0
        if (s_load == 1'b1) begin
             
            if (s_port_id == LEDS_ID)
                r_LEDS <= s_output_port;
            else if (s_port_id == SSEG0_ID)
                r_SSEG[7:0] <= s_output_port;
            else if (s_port_id == SSEG1_ID)
                r_SSEG[15:8] <= s_output_port;
//            else if (s_port_id == VGA_HADDR_ID)   // top 3 bits of high addr
//                r_vga_wa[10:8] <= s_output_port[2:0];
//            else if (s_port_id == VGA_LADDR_ID)   // lower 8 bits for low addr
//                r_vga_wa[7:0] <= s_output_port;
//            else if (s_port_id == VGA_COLOR_ID) begin
//                r_vga_wd <= s_output_port;
//                r_vga_we <= 1'b1; // write enable to save data to framebuffer
//            end
        end
    end
     
    // Connect Signals ////////////////////////////////////////////////////////////
    assign s_reset = BTNC;
    assign s_interrupt = BTNL;
     
    // Register Interface Assignments /////////////////////////////////////////////
    assign LEDS = r_LEDS;
   
    endmodule
