
`timescale 1ps/1ps

module serdes_out (

  // reset and clocks

  rst,
  clk,
  div_clk,
clk_dly,		   
  // data interface

  data_s0,
  data_s1,
  data_s2,
  data_s3,
  Frame,
		   sync,
		   Q_delay_tap,
//  Frame_n,
//  data_out_p,
  data_out
  );

  // parameters

  parameter   DEVICE_TYPE = 0;
  parameter   SERDES = 1;
  parameter   DATA_WIDTH = 16;
  parameter   IODELAY_GROUP   = "DAC_ODELAY_GROUP";

  localparam  DEVICE_6SERIES = 1;
  localparam  DEVICE_7SERIES = 0;
  localparam  DW = DATA_WIDTH - 1;

  // reset and clocks

  input           rst;
  input           clk;
  input           div_clk;
  input           clk_dly;
  // data interface

  input   [DW:0]  data_s0;
  input   [DW:0]  data_s1;
  input   [DW:0]  data_s2;
  input   [DW:0]  data_s3;
   input [DW*5+4 :0] Q_delay_tap;
   output 	  sync;
   
  output          Frame;
  output  [DW:0]  data_out;
//  output  [DW:0]  data_out_p;
//  output  [DW:0]  data_out_n;

  // internal signals

  wire    [DW:0]  data_out_s;
     wire    [DW:0]  data_out_d;
  wire    [DW:0]  serdes_shift1_s;
  wire    [DW:0]  serdes_shift2_s;

  // instantiations

  genvar l_inst;
  generate
  for (l_inst = 0; l_inst <= DW; l_inst = l_inst + 1) begin: g_data

       (* IODELAY_GROUP = IODELAY_GROUP *)
  IDELAYCTRL i_delay_ctrl (
    .RST (rst),
    .REFCLK (clk_dly),
    .RDY ());
     
        (* IODELAY_GROUP = IODELAY_GROUP*) // Specifies group name for associated IDELAYs/ODELAYs and IDELAYCTRL

   ODELAYE2 #(
      .CINVCTRL_SEL("FALSE"),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC("ODATAIN"),           // Delay input (ODATAIN, CLKIN)
      .HIGH_PERFORMANCE_MODE("FALSE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .ODELAY_TYPE("VAR_LOAD"),           // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .ODELAY_VALUE(0),                // Output delay tap setting (0-31)
      .PIPE_SEL("FALSE"),              // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY(200.0),        // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN("DATA")          // DATA, CLOCK input signal
   )
   ODELAYE2_inst (
      .CNTVALUEOUT(), // 5-bit output: Counter value output
      .DATAOUT(data_out_d[l_inst]),         // 1-bit output: Delayed data/clock output
      .C(clk_dly),                     // 1-bit input: Clock input
      .CE(0),                   // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL(0),       // 1-bit input: Dynamic clock inversion input
      .CLKIN(0),             // 1-bit input: Clock delay input
      .CNTVALUEIN(Q_delay_tap[l_inst*5]),   // 5-bit input: Counter value input
      .INC(0),                 // 1-bit input: Increment / Decrement tap delay input
      .LD(1),                   // 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or
                                 // VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN

      .LDPIPEEN(0),       // 1-bit input: Enables the pipeline register to load data
      .ODATAIN(data_out_s[l_inst]),         // 1-bit input: Output delay data input
      .REGRST(rst)            // 1-bit input: Active-high reset tap-delay input
   );
     
  if (SERDES == 0) begin
  ODDR #(
    .DDR_CLK_EDGE ("SAME_EDGE"),
    .INIT (1'b0),
    .SRTYPE ("ASYNC"))
  i_oddr (
    .S (1'b0),
    .CE (1'b1),
    .R (rst),
    .C (clk),
    .D1 (data_s0[l_inst]),
    .D2 (data_s1[l_inst]),
    .Q (data_out_s[l_inst]));
  end

  if ((SERDES == 1) && (DEVICE_TYPE == DEVICE_7SERIES)) begin
  OSERDESE2 #(
    .DATA_RATE_OQ ("DDR"),
    .DATA_RATE_TQ ("SDR"),
    .DATA_WIDTH (4),
    .TRISTATE_WIDTH (1),
    .SERDES_MODE ("MASTER"))
  i_serdes (
    .D1 (data_s0[l_inst]),
    .D2 (data_s1[l_inst]),
    .D3 (data_s2[l_inst]),
    .D4 (data_s3[l_inst]),
    .D5 (1'b0),
    .D6 (1'b0),
    .D7 (1'b0),
    .D8 (1'b0),
    .T1 (1'b0),
    .T2 (1'b0),
    .T3 (1'b0),
    .T4 (1'b0),
    .SHIFTIN1 (1'b0),
    .SHIFTIN2 (1'b0),
    .SHIFTOUT1 (),
    .SHIFTOUT2 (),
    .OCE (1'b1),
    .CLK (clk),
    .CLKDIV (div_clk),
    .OQ (data_out_s[l_inst]),
    .TQ (),
    .OFB (),
    .TFB (),
    .TBYTEIN (1'b0),
    .TBYTEOUT (),
    .TCE (1'b0),
    .RST (rst));
  end

  if ((SERDES == 1) && (DEVICE_TYPE == DEVICE_6SERIES)) begin
  OSERDESE1 #(
    .DATA_RATE_OQ ("DDR"),
    .DATA_RATE_TQ ("SDR"),
    .DATA_WIDTH (8),
    .INTERFACE_TYPE ("DEFAULT"),
    .TRISTATE_WIDTH (1),
    .SERDES_MODE ("MASTER"))
  i_serdes_m (
    .D1 (data_s0[l_inst]),
    .D2 (data_s1[l_inst]),
    .D3 (data_s2[l_inst]),
    .D4 (data_s3[l_inst]),
    .D5 (1'b0),
    .D6 (1'b0),
    .T1 (1'b0),
    .T2 (1'b0),
    .T3 (1'b0),
    .T4 (1'b0),
    .SHIFTIN1 (serdes_shift1_s[l_inst]),
    .SHIFTIN2 (serdes_shift2_s[l_inst]),
    .SHIFTOUT1 (),
    .SHIFTOUT2 (),
    .OCE (1'b1),
    .CLK (clk),
    .CLKDIV (div_clk),
    .CLKPERF (1'b0),
    .CLKPERFDELAY (1'b0),
    .WC (1'b0),
    .ODV (1'b0),
    .OQ (data_out_s[l_inst]),
    .TQ (),
    .OCBEXTEND (),
    .OFB (),
    .TFB (),
    .TCE (1'b0),
    .RST (rst));

  OSERDESE1 #(
    .DATA_RATE_OQ ("DDR"),
    .DATA_RATE_TQ ("SDR"),
    .DATA_WIDTH (8),
    .INTERFACE_TYPE ("DEFAULT"),
    .TRISTATE_WIDTH (1),
    .SERDES_MODE ("SLAVE"))
  i_serdes_s (
    .D1 (1'b0), 
    .D2 (1'b0), 
    .D3 (0),
    .D4 (0),
    .D5 (1'b0),
    .D6 (1'b0),
    .T1 (1'b0),
    .T2 (1'b0),
    .T3 (1'b0),
    .T4 (1'b0),
    .SHIFTIN1 (1'b0),
    .SHIFTIN2 (1'b0),
    .SHIFTOUT1 (serdes_shift1_s[l_inst]),
    .SHIFTOUT2 (serdes_shift2_s[l_inst]),
    .OCE (1'b1),
    .CLK (clk),
    .CLKDIV (div_clk),
    .CLKPERF (1'b0),
    .CLKPERFDELAY (1'b0),
    .WC (1'b0),
    .ODV (1'b0),
    .OQ (),
    .TQ (),
    .OCBEXTEND (),
    .OFB (),
    .TFB (),
    .TCE (1'b0),
    .RST (rst));
  end
  
//  OBUFDS i_obuf (
//    .I (data_out_s[l_inst]),
//    .O (data_out_p[l_inst]),
//    .OB (data_out_n[l_inst]));
  end
  endgenerate
  assign data_out = data_out_d;
//frame
   
  if ((SERDES == 1) && (DEVICE_TYPE == DEVICE_7SERIES)) begin
  OSERDESE2 #(
    .DATA_RATE_OQ ("DDR"),
    .DATA_RATE_TQ ("SDR"),
    .DATA_WIDTH (4),
    .TRISTATE_WIDTH (1),
    .SERDES_MODE ("MASTER"))
  i_serdes_f (
    .D1 (1),
    .D2 (1),
    .D3 (0),
    .D4 (0),
    .D5 (0),
    .D6 (0),
    .D7 (0),
    .D8 (0),
    .T1 (1'b0),
    .T2 (1'b0),
    .T3 (1'b0),
    .T4 (1'b0),
    .SHIFTIN1 (1'b0),
    .SHIFTIN2 (1'b0),
    .SHIFTOUT1 (),
    .SHIFTOUT2 (),
    .OCE (1'b1),
    .CLK (clk), //500MHz
    .CLKDIV (div_clk), //250MHz
    .OQ (Frame),
    .TQ (),
    .OFB (),
    .TFB (),
    .TBYTEIN (1'b0),
    .TBYTEOUT (),
    .TCE (1'b0),
    .RST (rst));

     // sync
       OSERDESE2 #(
    .DATA_RATE_OQ ("DDR"),
    .DATA_RATE_TQ ("SDR"),
    .DATA_WIDTH (4),
    .TRISTATE_WIDTH (1),
    .SERDES_MODE ("MASTER"))
  i_serdes_s(
    .D1 (1),
    .D2 (1),
    .D3 (0),
    .D4 (0),
    .D5 (0),
    .D6 (0),
    .D7 (0),
    .D8 (0),
    .T1 (1'b0),
    .T2 (1'b0),
    .T3 (1'b0),
    .T4 (1'b0),
    .SHIFTIN1 (1'b0),
    .SHIFTIN2 (1'b0),
    .SHIFTOUT1 (),
    .SHIFTOUT2 (),
    .OCE (1'b1),
    .CLK (clk), //500MHz
    .CLKDIV (div_clk), //250MHz
    .OQ (sync),
    .TQ (),
    .OFB (),
    .TFB (),
    .TBYTEIN (1'b0),
    .TBYTEOUT (),
    .TCE (1'b0),
    .RST (rst));
    
  end
endmodule

// ***************************************************************************
// ***************************************************************************

