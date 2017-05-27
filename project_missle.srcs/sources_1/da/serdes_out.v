
`timescale 1ps/1ps

module serdes_out (

  // reset and clocks

  rst,
  clk,
  div_clk,

  // data interface

  data_s0,
  data_s1,
  data_s2,
  data_s3,
  Frame,
		   sync,
//  Frame_n,
//  data_out_p,
  data_out
  );

  // parameters

  parameter   DEVICE_TYPE = 0;
  parameter   SERDES = 1;
  parameter   DATA_WIDTH = 16;


  localparam  DEVICE_6SERIES = 1;
  localparam  DEVICE_7SERIES = 0;
  localparam  DW = DATA_WIDTH - 1;

  // reset and clocks

  input           rst;
  input           clk;
  input           div_clk;

  // data interface

  input   [DW:0]  data_s0;
  input   [DW:0]  data_s1;
  input   [DW:0]  data_s2;
  input   [DW:0]  data_s3;
   output 	  sync;
   
  output          Frame;
  output  [DW:0]  data_out;
//  output  [DW:0]  data_out_p;
//  output  [DW:0]  data_out_n;

  // internal signals

  wire    [DW:0]  data_out_s;
  wire    [DW:0]  serdes_shift1_s;
  wire    [DW:0]  serdes_shift2_s;

  // instantiations

  genvar l_inst;
  generate
  for (l_inst = 0; l_inst <= DW; l_inst = l_inst + 1) begin: g_data

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
    .D1 (1),//data_s0[l_inst]),
    .D2 (1),//data_s1[l_inst]),
    .D3 (0),//data_s2[l_inst]),
    .D4 (0),//data_s3[l_inst]),
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
  assign data_out = data_out_s;
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

