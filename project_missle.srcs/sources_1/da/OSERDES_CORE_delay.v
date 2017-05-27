`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/07 09:48:19
// Design Name: 
// Module Name: OSERDES_CORE
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


module OSERDES_CORE(
    input       [7:0] parallel_data,
    input             rst,
    input              parallel_clk,
    input              serial_clk,
    output             serial_data
    );
 
    
//    OSERDESE3 #(
//       .DATA_WIDTH(8),            // Parallel Data Width (4-8)
//       .INIT(1'b0),               // Initialization value of the OSERDES flip-flops
//       .IS_CLKDIV_INVERTED(1'b0), // Optional inversion for CLKDIV
//       .IS_CLK_INVERTED(1'b0),    // Optional inversion for CLK
//       .IS_RST_INVERTED(1'b0)     // Optional inversion for RST
//    )
//    OSERDESE3_inst1 (
//       .OQ(serial_data),         // 1-bit output: Serial Output Data
//       .T_OUT(),   // 1-bit output: 3-state control output to IOB
//       .CLK(serial_clk),       // 1-bit input: High-speed clock
//       .CLKDIV(parallel_clk), // 1-bit input: Divided Clock
//       .D(parallel_data),           // 8-bit input: Parallel Data Input
//       .RST(0),       // 1-bit input: Asynchronous Reset
//       .T(1)            // 1-bit input: Tristate input from fabric
//    );
   OSERDESE2 #(
   .DATA_RATE_OQ("DDR"),   // DDR, SDR
   .DATA_RATE_TQ("DDR"),   // DDR, BUF, SDR
   .DATA_WIDTH(8),         // Parallel data width (2-8,10,14)
   .INIT_OQ(1'b0),         // Initial value of OQ output (1'b0,1'b1)
   .INIT_TQ(1'b0),         // Initial value of TQ output (1'b0,1'b1)
   .SERDES_MODE("MASTER"), // MASTER, SLAVE
   .SRVAL_OQ(1'b0),        // OQ output value when SR is used (1'b0,1'b1)
   .SRVAL_TQ(1'b0),        // TQ output value when SR is used (1'b0,1'b1)
   .TBYTE_CTL("FALSE"),    // Enable tristate byte operation (FALSE, TRUE)
   .TBYTE_SRC("FALSE"),    // Tristate byte source (FALSE, TRUE)
   .TRISTATE_WIDTH(4)      // 3-state converter width (1,4)
)
OSERDESE2_inst (
   .OFB(),             // 1-bit output: Feedback path for data
   .OQ(serial_data),               // 1-bit output: Data path output
   // SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
   .SHIFTOUT1(),
   .SHIFTOUT2(),
   .TBYTEOUT(),   // 1-bit output: Byte group tristate
   .TFB(),             // 1-bit output: 3-state control
   .TQ(),               // 1-bit output: 3-state control
   .CLK(serial_clk),             // 1-bit input: High speed clock
   .CLKDIV(parallel_clk),       // 1-bit input: Divided clock
   // D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
   .D1(parallel_data[0]),
   .D2(parallel_data[1]),
   .D3(parallel_data[2]),
   .D4(parallel_data[3]),
   .D5(parallel_data[4]),
   .D6(parallel_data[5]),
   .D7(parallel_data[6]),
   .D8(parallel_data[7]),
   .OCE(1),             // 1-bit input: Output data clock enable
   .RST(rst),             // 1-bit input: Reset
   // SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
   .SHIFTIN1(0),
   .SHIFTIN2(0),
   // T1 - T4: 1-bit (each) input: Parallel 3-state inputs
   .T1(0),
   .T2(0),
   .T3(0),
   .T4(0),
   .TBYTEIN(0),     // 1-bit input: Byte group tristate
   .TCE(0)              // 1-bit input: 3-state clock enable
);
endmodule
