`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/27/2018 11:37:00 PM
// Design Name: 
// Module Name: RATMCU
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


module RATMCU(
    input CLK,
    input [7:0] IN_PORT,
    input INTR,
    input RESET,
    output IO_STRB,
    output [7:0] OUT_PORT,
    output [7:0] PORT_ID
    );
    
    // Define internal signals /////////////////////////////////////////////////
    
    // ProgCount
    logic s_pc_ld, s_pc_inc;
    logic [1:0] s_pc_mux_sel;
    logic [9:0] s_pc_din, s_pc_count;
    
    // ProgRom
    logic [17:0] s_prog_instr;
    
    // RegFile
    logic s_rf_wr;
    logic [1:0] s_rf_wr_sel;
    logic [7:0] s_rf_din, s_rf_dx_out, s_rf_dy_out;
    
    // ALU
    logic [3:0] s_alu_sel;
    logic s_alu_opy_sel, s_alu_c, s_alu_z;
    logic [7:0] s_alu_b, s_alu_result;
    
    // FlagFile
    logic s_flg_c_set, s_flg_c_clr, s_flg_c_ld, s_flg_z_ld;
    logic s_flg_c, s_flg_z, s_flg_ld_sel, s_flg_shad_ld;
    
    // Intr
    logic s_i_set, s_i_clr, s_i_out, s_cu_intr;
    
    // StackPointer
    logic s_sp_ld, s_sp_inc, s_sp_dec;
    logic [7:0] s_sp_data_out;
    
    // ScratchRam
    logic s_scr_we, s_scr_data_sel;
    logic [1:0] s_scr_addr_sel;
    logic [7:0] s_scr_addr;
    logic [9:0] s_scr_data_in, s_scr_data_out;
    
    // CU
    logic s_io_strb, s_cond_brn;
    logic [1:0] s_cond_brn_type;
    
    //define signals used for each pipeline stage
    
    //prefetch pc address to allign with instruction
    logic [9:0] s_prefetch_pc_count;
    
    //fetch stage signals
    logic [17:0] s_fetch_instr;
    logic [9:0] s_fetch_pc_count;
    
    //decode stage signals
    logic [12:0] s_decode_instr; //don't need upper 5 bits of instr
    logic [7:0] s_decode_dx_out, s_decode_dy_out;
    logic [1:0] s_decode_pc_mux_sel;
    logic s_decode_sp_inc, s_decode_sp_dec;
    logic s_decode_rf_wr;
    logic [1:0] s_decode_rf_wr_sel;
    logic s_decode_alu_opy_sel;
    logic [3:0] s_decode_alu_sel;
    logic s_decode_scr_we, s_decode_scr_data_sel;
    logic [1:0] s_decode_scr_addr_sel;
    logic s_decode_flg_c_set, s_decode_flg_c_clr, s_decode_flg_c_ld; 
    logic s_dexode_flg_z_ld, s_decode_flg_ld_sel, s_decode_flg_shad_ld;
    logic s_decode_i_set, s_decode_i_clr, s_decode_io_strb, s_decode_cond_brn;
    logic [1:0] s_decode_cond_brn_type;
    
    //decode mux signals
    logic s_execute_dx_sel;
    logic s_forward_execute_dx_out;
    logic s_forward_execute_mux_dx_out; //forwarded data result
    logic s_execute_dy_sel;
    logic s_forward_execute_dy_out;
    logic s_forward_execute_mux_dy_out; //forwarded data results
    
    //execute stage signals 
    logic [12:0] s_execute_instr; //needed for conditional branches and scr address
    logic [7:0] s_execute_alu_result;
    logic [1:0] s_execute_pc_mux_sel;
    logic s_execute_sp_inc, s_execute_sp_dec;
    logic s_execute_rf_wr;
    logic [1:0] s_execute_rf_wr_sel;
    logic s_execute_scr_we, s_execute_scr_data_sel;
    logic [1:0] s_execute_scr_addr_sel;
    logic s_execute_cond_brn;
    logic [1:0] s_execute_cond_brn_type;
    
    //execute stage mux signals
    
    // Define Muxes ////////////////////////////////////////////////////////////
    
    always_comb begin: PC_MUX
        case (s_pc_mux_sel)
            2'b00: s_pc_din = s_prog_instr[12:3];
            2'b01: s_pc_din = s_scr_data_out;
            2'b10: s_pc_din = 10'h3FF;
            default: s_pc_din = 10'h000; // failsafe
        endcase
    end: PC_MUX
    
    always_comb begin: REG_MUX
        case (s_rf_wr_sel)
            2'b00: s_rf_din = s_alu_result;
            2'b01: s_rf_din = s_scr_data_out[7:0];
            2'b10: s_rf_din = s_sp_data_out;
            2'b11: s_rf_din = IN_PORT;
            default: s_rf_din = 8'h00;  // failsafe
        endcase
    end: REG_MUX

    always_comb begin: ALU_MUX
        case (s_alu_opy_sel)
            1'b0: s_alu_b = s_forward_execute_mux_dy_out;
            1'b1: s_alu_b = s_decode_instr[7:0];
            default: s_alu_b = 8'h00;   // failsafe
        endcase
    end: ALU_MUX
    
    always_comb begin: SCR_DATA_MUX
        case (s_scr_data_sel)
            1'b0: s_scr_data_in = s_rf_dx_out;
            1'b1: s_scr_data_in = s_pc_count;
            default: s_scr_data_in = 10'h000; // failsafe
        endcase
    end: SCR_DATA_MUX
    
    always_comb begin: SCR_ADDR_MUX
        case (s_scr_addr_sel)
            2'b00: s_scr_addr = s_rf_dy_out;
            2'b01: s_scr_addr = s_prog_instr[7:0];
            2'b10: s_scr_addr = s_sp_data_out;
            2'b11: s_scr_addr = s_sp_data_out - 1;
            default: s_scr_addr = 8'h00; //failsafe
        endcase
    end: SCR_ADDR_MUX
    
    // Define Pipeline Stages //////////////////////////////////////
    
    //need to prefetch instruction count since it is always one cycle behind instruction    
    always @(posedge CLK) // store instruction that is sent to decode
    begin : PreFetch
        s_prefetch_pc_count <= s_pc_count + 1; //preincrement PC count for return address 
    end : PreFetch 
    
    always @(posedge CLK) // store instruction that is sent to decode
    begin : Fetch
        s_fetch_instr <= s_prog_instr; 
        s_fetch_pc_count <= s_prefetch_pc_count;
    end : Fetch 
    
    //Decode data forwarding muxs
    logic s_decode_dx_sel;
    logic s_forward_deocde_dx_out;
    logic s_forward_decode_mux_dx_out; //forwarded data result
    always_comb begin: DECODE_FORWARDING_DX_MUX
        case (s_decode_dx_sel)
            1'b0: s_forward_decode_mux_dx_out = s_rf_dx_out;
            1'b1: s_forward_decode_mux_dx_out = s_forward_deocde_dx_out;
            default: s_forward_decode_mux_dx_out = 8'h00; // failsafe
        endcase
    end: DECODE_FORWARDING_DX_MUX
    
    logic s_decode_dy_sel;
    logic s_forward_decode_dy_out;
    logic s_forward_decode_mux_dy_out; //forwarded data results
    always_comb begin: DECODE_FORWARDING_DY_MUX
        case (s_decode_dy_sel)
            1'b0: s_forward_decode_mux_dy_out = s_rf_dy_out;
            1'b1: s_forward_decode_mux_dy_out = s_forward_decode_dy_out;
            default: s_forward_decode_mux_dy_out = 8'h00; // failsafe
        endcase
    end: DECODE_FORWARDING_DY_MUX
    
    
    
    
    always @(posedge CLK) // Store control signals and data from decode
    begin : Decode
        s_decode_instr         <= s_fetch_instr;
        s_decode_dx_out        <= s_forward_decode_mux_dx_out; //get the forwarding result
        s_decode_dy_out        <= s_forward_decode_mux_dy_out; //get the forwarding result
        s_decode_pc_mux_sel    <= s_pc_mux_sel;
        s_decode_sp_inc        <= s_sp_inc;
        s_decode_sp_dec        <= s_sp_dec;
        s_decode_rf_wr_sel     <= s_rf_wr_sel;
        s_decode_alu_opy_sel   <= s_alu_opy_sel;
        s_decode_alu_sel       <= s_alu_sel;
        s_decode_scr_we        <= s_scr_we;
        s_decode_scr_data_sel  <= s_scr_data_sel;
        s_decode_scr_addr_sel  <= s_scr_addr_sel;  
        s_decode_flg_c_set     <= s_flg_c_set;
        s_decode_flg_c_clr     <= s_flg_c_clr;
        s_decode_flg_c_ld      <= s_flg_c_ld;
        s_dexode_flg_z_ld      <= s_flg_z_ld;
        s_decode_flg_ld_sel    <= s_flg_ld_sel;
        s_decode_flg_shad_ld   <= s_flg_shad_ld;
        s_decode_i_set         <= s_i_set;
        s_decode_i_clr         <= s_i_clr;
        s_decode_io_strb       <= s_io_strb;
        s_decode_cond_brn      <= s_cond_brn;
        s_decode_cond_brn_type <= s_cond_brn_type;
    end : Decode 
    
    
    //Execute data forwarding muxs
    always_comb begin: EXECUTE_FORWARDING_DX_MUX
        case (s_execute_dx_sel)
            1'b0: s_forward_execute_mux_dx_out = s_decode_dx_out;
            1'b1: s_forward_execute_mux_dx_out = s_forward_execute_dx_out;
            default: s_forward_execute_mux_dx_out = 8'h00; // failsafe
        endcase
    end: EXECUTE_FORWARDING_DX_MUX
    
    always_comb begin: EXECUTE_FORWARDING_DY_MUX
        case (s_decode_dy_sel)
            1'b0: s_forward_execute_mux_dy_out = s_decode_dy_out;
            1'b1: s_forward_execute_mux_dy_out = s_forward_execute_dy_out;
            default: s_forward_execute_mux_dy_out = 8'h00; // failsafe
        endcase
    end: EXECUTE_FORWARDING_DY_MUX
    
    // Store result from execution and control signals for write back 
    always @(posedge CLK) 
    begin : Execute
        s_execute_instr         <= s_decode_instr;
        s_execute_alu_result    <= s_alu_result;
        s_execute_pc_mux_sel    <= s_decode_pc_mux_sel;
        s_execute_sp_inc        <= s_decode_sp_inc;
        s_execute_sp_dec        <= s_decode_sp_dec;
        s_execute_rf_wr         <= s_decode_rf_wr;
        s_execute_rf_wr_sel     <= s_decode_rf_wr_sel;
        s_execute_scr_we        <= s_decode_scr_we;
        s_execute_scr_data_sel  <= s_decode_scr_data_sel;
        s_execute_scr_addr_sel  <= s_decode_scr_addr_sel;
        s_execute_cond_brn      <= s_decode_cond_brn;
        s_execute_cond_brn_type <= s_decode_cond_brn_type;
    end : Execute 
    
    
    // Define hardware connections /////////////////////////////////////////////
    assign s_cu_intr = s_i_out & INTR;
    assign OUT_PORT = s_rf_dx_out;
    assign PORT_ID = s_prog_instr[7:0];
    
    // Define submodule components /////////////////////////////////////////////
    InterReg I_REG (.I_SET(s_i_set), .I_CLR(s_i_clr), .I_CLK(CLK), .I_OUT(s_i_out));
    
    ProgCount PC (.PC_CLK(CLK), .PC_RST(RESET), .PC_LD(s_pc_ld),
        .PC_DIN(s_pc_din), .PC_COUNT(s_pc_count));
    
    ProgRom PROG (.PROG_CLK(CLK), .PROG_ADDR(s_pc_count), .PROG_IR(s_prog_instr));
    
    RegMem RF (.RF_ADDRX(s_fetch_instr[12:8]), .RF_ADDRY(s_fetch_instr[7:3]), 
        .RF_WR(s_rf_wr), .RF_CLK(CLK), .RF_DIN(s_rf_din), .RF_DX_OUT(s_rf_dx_out),
        .RF_DY_OUT(s_rf_dy_out));
    
    ArithLogicUnit ALU (.ALU_A(s_forward_execute_mux_dx_out), .ALU_B(s_alu_b), .ALU_SEL(s_alu_sel),
        .ALU_CIN(s_flg_c), .ALU_RESULT(s_alu_result), .ALU_C(s_alu_c), .ALU_Z(s_alu_z));
    
    Flags FLG (.FLG_CLK(CLK), .FLG_C_SET(s_flg_c_set), .FLG_C_CLR(s_flg_c_clr),
        .FLG_C_LD(s_flg_c_ld), .FLG_Z_LD(s_flg_z_ld), .FLG_LD_SEL(s_flg_ld_sel), 
        .FLG_SHAD_LD(s_flg_shad_ld), .FLG_CIN(s_alu_c), .FLG_ZIN(s_alu_z), 
        .FLG_COUT(s_flg_c), .FLG_ZOUT(s_flg_z));
   
    ScratchMem SCR (.SCR_CLK(CLK), .SCR_ADDR(s_scr_addr), .SCR_DIN(s_scr_data_in), 
        .SCR_WE(s_scr_we), .SCR_DOUT(s_scr_data_out));
    
    StackPtr SP (.SP_CLK(CLK), .SP_INC(s_sp_inc), .SP_DEC(s_sp_dec), .SP_LD(s_sp_ld),
        .SP_RST(RESET), .SP_DIN(s_rf_dx_out), .SP_DOUT(s_sp_data_out));
    
    ControlUnit CU (.CU_INT(s_cu_intr),
        .CU_OPCODE_HI_5(s_prog_instr[17:13]), .CU_OPCODE_LO_2(s_prog_instr[1:0]),
        .CU_PC_LD(s_pc_ld), .CU_PC_MUX_SEL(s_pc_mux_sel),
        .CU_SP_LD(s_sp_ld), .CU_SP_INCR(s_sp_inc), .CU_SP_DECR(s_sp_dec), .CU_RF_WR(s_rf_wr),
        .CU_RF_WR_SEL(s_rf_wr_sel), .CU_ALU_OPY_SEL(s_alu_opy_sel), .CU_ALU_SEL(s_alu_sel),
        .CU_SCR_WE(s_scr_we), .CU_SCR_DATA_SEL(s_scr_data_sel), .CU_SCR_ADDR_SEL(s_scr_addr_sel),
        .CU_FLG_C_SET(s_flg_c_set), .CU_FLG_C_CLR(s_flg_c_clr), .CU_FLG_C_LD(s_flg_c_ld),
        .CU_FLG_Z_LD(s_flg_z_ld), .CU_FLG_LD_SEL(s_flg_ld_sel), .CU_FLG_SHAD_LD(s_flg_shad_ld),
        .CU_I_SET(s_i_set), .CU_I_CLR(s_i_clr), .CU_IO_STRB(s_io_strb), 
        .CU_COND_BRN(s_cond_brn), .CU_COND_BRN_TYPE(s_cond_brn_type));
    
endmodule
