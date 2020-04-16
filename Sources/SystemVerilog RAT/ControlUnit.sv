`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/07/2018 06:38:55 PM
// Design Name:
// Module Name: ControlUnit
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

module ControlUnit(
  input CU_CLK,
  input CU_C,
  input CU_Z,
  input CU_INT,
  input CU_RESET,
  input [4:0] CU_OPCODE_HI_5,
  input [1:0] CU_OPCODE_LO_2,
  output logic CU_PC_LD,
  output logic CU_PC_INC,
  output logic [1:0] CU_PC_MUX_SEL,
  output logic CU_SP_LD,
  output logic CU_SP_INCR,
  output logic CU_SP_DECR,
  output logic CU_RF_WR,
  output logic [1:0] CU_RF_WR_SEL,
  output logic CU_ALU_OPY_SEL,
  output logic [3:0] CU_ALU_SEL,
  output logic CU_SCR_WE,
  output logic CU_SCR_DATA_SEL,
  output logic [1:0] CU_SCR_ADDR_SEL,
  output logic CU_FLG_C_SET,
  output logic CU_FLG_C_CLR,
  output logic CU_FLG_C_LD,
  output logic CU_FLG_Z_LD,
  output logic CU_FLG_LD_SEL,
  output logic CU_FLG_SHAD_LD,
  output logic CU_I_SET,
  output logic CU_I_CLR,
  output logic CU_IO_STRB,
  output logic CU_RST);

  // Define State Labels
  typedef enum {ST_FETCH, ST_EXEC, ST_INIT, ST_INTER} STATES; 
  STATES NS, PS = ST_INIT;

  logic [6:0] s_opcode;

  assign s_opcode = {CU_OPCODE_HI_5,CU_OPCODE_LO_2};

  // Synchronous State Changes
  always_ff @ (posedge CU_CLK)
    begin
      if (CU_RESET == 1'b1)
        PS <= ST_INIT;
      else
        PS <= NS;
    end

  always_comb
    begin

      // Initialize all signals to avoid latches
      CU_PC_INC   <= 1'b0;  CU_PC_MUX_SEL   <= 2'b00;  CU_PC_LD        <= 1'b0;
      CU_SP_LD    <= 1'b0;  CU_SP_INCR      <= 1'b0;   CU_SP_DECR      <= 1'b0;
      CU_RF_WR    <= 1'b0;  CU_RF_WR_SEL    <= 2'b00;
      CU_ALU_SEL  <= 4'h0;  CU_ALU_OPY_SEL  <= 1'b0;
      CU_SCR_WE   <= 1'b0; 	CU_SCR_DATA_SEL <= 1'b0;   CU_SCR_ADDR_SEL <= 2'b00;
      CU_FLG_C_LD <= 1'b0;  CU_FLG_C_CLR    <= 1'b0;   CU_FLG_C_SET    <= 1'b0;
      CU_FLG_Z_LD <= 1'b0;  CU_FLG_LD_SEL   <= 1'b0;   CU_FLG_SHAD_LD  <= 1'b0;
      CU_I_SET    <= 1'b0;	CU_I_CLR        <= 1'b0;   CU_IO_STRB      <= 1'b0;
      CU_RST      <= 1'b0;

      case (PS)
        ST_INIT: begin      // Initialize
          NS     <= ST_FETCH;
          CU_RST <= 1'b1;
        end

        ST_INTER: begin    // Interrupt
          NS              <= ST_FETCH;
          CU_FLG_SHAD_LD  <= 1'b1;
          CU_PC_LD        <= 1'b1;
          CU_PC_MUX_SEL   <= 2'b10;
          CU_SP_DECR      <= 1'b1;
          CU_SCR_WE       <= 1'b1;
          CU_SCR_DATA_SEL <= 1'b1;
          CU_SCR_ADDR_SEL <= 2'b11;
          CU_I_CLR        <= 1'b1;
        end

        ST_FETCH: begin    // Fetch
          NS <= ST_EXEC;
          CU_PC_INC <= 1'b1;
        end

        ST_EXEC: begin      // Execute

          // Check for Interrupt
          if (CU_INT == 1'b1)
            NS <= ST_INTER;
          else
            NS <= ST_FETCH;

          // Op Code Decoder
          case (s_opcode)

            7'b0000100:  begin              // ADD RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0000;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1010000 , 7'b1010001 , 7'b1010010 , 7'b1010011: begin // ADD RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0000;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0000101: begin               // ADDC RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0001;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1010100 , 7'b1010101 , 7'b1010110 , 7'b1010111: begin // ADDC RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0001;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0000000: begin                   // AND RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0101;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1000000 , 7'b1000001 , 7'b1000010 , 7'b1000011: begin// AND RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0101;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0100100: begin              // ASR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b1101;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0010101: begin               // BRCC
              if (CU_C == 1'b0) begin
                CU_PC_LD      <= 1'b1;
                CU_PC_MUX_SEL <= 2'b00;
              end
            end

            7'b0010100: begin              // BRCS
              if (CU_C == 1'b1) begin
                CU_PC_LD      <= 1'b1;
                CU_PC_MUX_SEL <= 2'b00;
              end
            end

            7'b0010010: begin              // BREQ
              if (CU_Z == 1'b1) begin
                CU_PC_LD      <= 1'b1;
                CU_PC_MUX_SEL <= 2'b00;
              end
            end

            7'b0010000: begin              // BRN
              CU_PC_LD      <= 1'b1;
              CU_PC_MUX_SEL <= 2'b00;
            end

            7'b0010011: begin              // BRNE
              if (CU_Z == 1'b0) begin
                CU_PC_LD      <= 1'b1;
                CU_PC_MUX_SEL <= 2'b00;
              end
            end

            7'b0010001: begin              // CALL
              CU_PC_LD        <= 1'b1;
              CU_PC_MUX_SEL   <= 2'b00;
              CU_SP_LD        <= 1'b0;
              CU_SP_INCR      <= 1'b0;
              CU_SP_DECR      <= 1'b1;
              CU_SCR_WE       <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b11;
              CU_SCR_DATA_SEL <= 1'b1;
            end

            7'b0110000:               // CLC
              CU_FLG_C_CLR <= 1'b1;

            7'b0110101:               // CLI
              CU_I_CLR <= 1'b1;

            7'b0001000: begin              // CMP RR
              CU_RF_WR       <= 1'b0;
              CU_ALU_SEL     <= 4'b0100;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1100000 , 7'b1100001 , 7'b1100010 , 7'b1100011: begin // CMP RI
              CU_RF_WR       <= 1'b0;
              CU_ALU_SEL     <= 4'b0100;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0000010: begin              // EXOR RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0111;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1001000 , 7'b1001001 , 7'b1001010 , 7'b1001011: begin // EXOR RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0111;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1100100 , 7'b1100101 , 7'b1100110 , 7'b1100111: begin // IN
              CU_RF_WR     <= 1'b1;
              CU_RF_WR_SEL <= 2'b11;
            end

            7'b0001010: begin              // LD RR
              CU_SCR_WE       <= 1'b0;
              CU_SCR_ADDR_SEL <= 2'b00;
              CU_RF_WR        <= 1'b1;
              CU_RF_WR_SEL    <= 2'b01;
            end

            7'b1110000 , 7'b1110001 , 7'b1110010 , 7'b1110011: begin // LD RI
              CU_SCR_WE       <= 1'b0;
              CU_SCR_ADDR_SEL <= 2'b01;
              CU_RF_WR        <= 1'b1;
              CU_RF_WR_SEL    <= 2'b01;
            end

            7'b0100000: begin              // LSL
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b1001;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0100001: begin              // LSR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b1010;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0001001: begin              // MOV RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_ALU_SEL     <= 4'b1110;
            end

            7'b1101100 , 7'b1101101 , 7'b1101110 , 7'b1101111: begin // MOV RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_ALU_SEL     <= 4'b1110;
            end

            7'b0000001: begin              // OR RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0110;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1000100 , 7'b1000101 , 7'b1000110 , 7'b1000111: begin // OR RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0110;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1101000 , 7'b1101001 , 7'b1101010 , 7'b1101011: begin // OUT
              CU_RF_WR   <= 1'b0;
              CU_IO_STRB <= 1'b1;
            end

            7'b0100110: begin              // POP
              CU_SP_LD        <= 1'b0;
              CU_SP_INCR      <= 1'b1;
              CU_SP_DECR      <= 1'b0;
              CU_SCR_WE       <= 1'b0;
              CU_SCR_ADDR_SEL <= 2'b10;
              CU_RF_WR        <= 1'b1;
              CU_RF_WR_SEL    <= 2'b01;
            end

            7'b0100101: begin              // PUSH
              CU_SP_LD        <= 1'b0;
              CU_SP_INCR      <= 1'b0;
              CU_SP_DECR      <= 1'b1;
              CU_SCR_WE       <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b11;
              CU_SCR_DATA_SEL <= 1'b0;
            end

            7'b0110010: begin              // RET
              CU_PC_LD        <= 1'b1;
              CU_PC_MUX_SEL   <= 2'b01;
              CU_SP_LD        <= 1'b0;
              CU_SP_INCR      <= 1'b1;
              CU_SP_DECR      <= 1'b0;
              CU_SCR_WE       <= 1'b0;
              CU_SCR_ADDR_SEL <= 2'b10;
            end

            7'b0110110: begin              // RETID
              CU_PC_LD        <= 1'b1;
              CU_PC_MUX_SEL   <= 2'b01;
              CU_SP_INCR      <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b10;
              CU_FLG_LD_SEL   <= 1'b1;
              CU_FLG_C_LD     <= 1'b1;
              CU_FLG_Z_LD     <= 1'b1;
              CU_I_CLR        <= 1'b1;
            end

            7'b0110111: begin              // RETIE
              CU_PC_LD        <= 1'b1;
              CU_PC_MUX_SEL   <= 2'b01;
              CU_SP_INCR      <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b10;
              CU_FLG_LD_SEL   <= 1'b1;
              CU_FLG_C_LD     <= 1'b1;
              CU_FLG_Z_LD     <= 1'b1;
              CU_I_SET        <= 1'b1;
            end

            7'b0100010: begin              // ROL
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b1011;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0100011: begin              // ROR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b1100;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0110001:               // SEC
              CU_FLG_C_SET   <= 1'b1;

            7'b0110100:               // SEI
              CU_I_SET <= 1'b1;

            7'b0001011: begin              // ST RR
              CU_SCR_DATA_SEL <= 1'b0;
              CU_SCR_WE       <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b00;
            end

            7'b1110100 , 7'b1110101 , 7'b1110110 , 7'b1110111: begin // ST RI
              CU_SCR_DATA_SEL <= 1'b0;
              CU_SCR_WE       <= 1'b1;
              CU_SCR_ADDR_SEL <= 2'b01;
            end

            7'b0000110: begin              // SUB RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0010;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1011000 , 7'b1011001 , 7'b1011010 , 7'b1011011: begin // SUB RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0010;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0000111: begin              // SUBC RR
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0011;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1011100 , 7'b1011101 , 7'b1011110 , 7'b1011111: begin // SUBC RI
              CU_RF_WR       <= 1'b1;
              CU_RF_WR_SEL   <= 2'b00;
              CU_ALU_SEL     <= 4'b0011;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_LD    <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0000011: begin              // TEST RR
              CU_RF_WR       <= 1'b0;
              CU_ALU_SEL     <= 4'b1000;
              CU_ALU_OPY_SEL <= 1'b0;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b1001100 , 7'b1001101 , 7'b1001110 , 7'b1001111: begin // TEST RI
              CU_RF_WR       <= 1'b0;
              CU_ALU_SEL     <= 4'b1000;
              CU_ALU_OPY_SEL <= 1'b1;
              CU_FLG_LD_SEL  <= 1'b0;
              CU_FLG_C_CLR   <= 1'b1;
              CU_FLG_Z_LD    <= 1'b1;
            end

            7'b0101000:       // WSP
              CU_SP_LD <= 1'b1;

            default:          // failsafe
              CU_RST <= 1'b0;

          endcase
        end

        default:          // Failsafe
          NS <= ST_INIT;

      endcase
    end

endmodule
