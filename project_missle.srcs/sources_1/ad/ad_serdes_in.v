// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT,
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, INTELLECTUAL PROPERTY RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
// USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
`timescale 1ps/1ps

module ad_serdes_in (

  // reset and clocks

  rst,
  clk,
  div_clk,

  // data interface

  data_s0,
  data_s1,
  data_s2,
  data_s3,
  data_s4,
  data_s5,
  data_s6,
  data_s7,
  data_in_p,
  data_in_n,

  // delay-data interface
		     
  up_clk,
  up_dld,
  up_dwdata,
  up_drdata,

  // delay-control interface
bitslip,
  delay_clk,
  delay_rst,
  delay_locked);

  // parameters

  parameter   DEVICE_TYPE     = 1;
  parameter   IODELAY_CTRL    = 0;
  parameter   IODELAY_GROUP   = "dev_if_delay_group";
  // SDR = 0 / DDR = 1
  parameter   IF_TYPE         = 1;
  // serialization factor
  parameter   PARALLEL_WIDTH  = 8;

  localparam  DEVICE_6SERIES  = 0;
  localparam  DEVICE_7SERIES  = 1;
   localparam  DEVICE_ULTRASCALE  = 0;
  localparam  SDR             = 0;
  localparam  DDR             = 1;

  // reset and clocks

  input           rst;
  input           clk;
  input           div_clk;
   input 	  bitslip;
   
  // data interface

  output          data_s0;
  output          data_s1;
  output          data_s2;
  output          data_s3;
  output          data_s4;
  output          data_s5;
  output          data_s6;
  output          data_s7;
  input           data_in_p;
  input           data_in_n;

  // delay-data interface

  input           up_clk;
  input           up_dld;
  input    [ 4:0] up_dwdata;
  output   [ 4:0] up_drdata;

  // delay-control interface
  input           delay_clk;
  input           delay_rst;
  output          delay_locked;

  // internal signals

  wire            data_in_ibuf_s;
  wire            data_in_idelay_s;
  wire            data_shift1_s;
  wire            data_shift2_s;
   wire 	  FIFO_EMPTY;
   wire 	  INTERNAL_DIVCLK;
   wire 	  CASC_OUT;
   wire [7:0] 	  iserdes3_parallel_data;
   wire 	  temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp0;
   
   
  // delay controller

  generate
  if (IODELAY_CTRL == 1) begin
  (* IODELAY_GROUP = IODELAY_GROUP *)
  IDELAYCTRL i_delay_ctrl (
    .RST (delay_rst),
    .REFCLK (delay_clk),
    .RDY (delay_locked));
  end else begin
  assign delay_locked = 1'b1;
  end
  endgenerate

  // received data interface: ibuf -> idelay -> iserdes

  IBUFDS i_ibuf (
    .O(data_in_ibuf_s),
    .I(data_in_p),
    .IB(data_in_n)
  );

  if(DEVICE_TYPE == DEVICE_7SERIES) begin
    (* IODELAY_GROUP = IODELAY_GROUP *)

    IDELAYE2 #(
      .CINVCTRL_SEL ("FALSE"),
      .DELAY_SRC ("IDATAIN"),
      .HIGH_PERFORMANCE_MODE ("FALSE"),
      .IDELAY_TYPE ("VAR_LOAD"),
      .IDELAY_VALUE (0),
      .REFCLK_FREQUENCY (200.0),
      .PIPE_SEL ("FALSE"),
      .SIGNAL_PATTERN ("DATA"))
    i_rx_data_idelay (
      .CE (1'b0),
      .INC (1'b0),
      .DATAIN (1'b0),
      .LDPIPEEN (1'b0),
      .CINVCTRL (1'b0),
      .REGRST (1'b0),
      .C (up_clk),
      .IDATAIN (data_in_ibuf_s),
      .DATAOUT (data_in_idelay_s),
      .LD (up_dld), //Loads the IDELAYE2 primitive to the pre-programmed value
      .CNTVALUEIN (up_dwdata), //Counter value from FPGA logic for dynamically loadable tap value.
      .CNTVALUEOUT (up_drdata)); //Counter value going to FPGA logic for monitoring tap value.

     

    // Note: The first sample in time will be data_s7, the last data_s0!
    if(IF_TYPE == SDR) begin
      ISERDESE2 #(
        .DATA_RATE("SDR"),
        .DATA_WIDTH(PARALLEL_WIDTH),
        .DYN_CLKDIV_INV_EN("FALSE"),
        .DYN_CLK_INV_EN("FALSE"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("NETWORKING"),
        .IOBDELAY("IFD"),
        .NUM_CE(2),
        .OFB_USED("FALSE"),
        .SERDES_MODE("MASTER"),
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0))
      ISERDESE2_inst (
        .O(),
        .Q1(data_s0),
        .Q2(data_s1),
        .Q3(data_s2),
        .Q4(data_s3),
        .Q5(data_s4),
        .Q6(data_s5),
        .Q7(data_s6),
        .Q8(data_s7),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(1'b0),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLKDIVP(1'b0),
        .CLK(clk),
        .CLKB(~clk),
        .CLKDIV(div_clk),
        .OCLK(1'b0),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(1'b0),
        .DDLY(data_in_idelay_s),
        .OFB(1'b0),
        .OCLKB(1'b0),
        .RST(rst),
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0)
      );
    end else begin

      ISERDESE2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(PARALLEL_WIDTH),
        .DYN_CLKDIV_INV_EN("FALSE"),
        .DYN_CLK_INV_EN("FALSE"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("NETWORKING"),
        .IOBDELAY("IFD"),
        .NUM_CE(2),
        .OFB_USED("FALSE"),
        .SERDES_MODE("MASTER"),
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0))
      ISERDESE2_inst (
        .O(),
        .Q1(data_s0),
        .Q2(data_s1),
        .Q3(data_s2),
        .Q4(data_s3),
        .Q5(data_s4),
        .Q6(data_s5),
        .Q7(data_s6),
        .Q8(data_s7),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(1'b0),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLKDIVP(1'b0),
        .CLK(clk),
        .CLKB(~clk),
        .CLKDIV(div_clk),
        .OCLK(1'b0),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(1'b0),
        .DDLY(data_in_idelay_s),
        .OFB(1'b0),
        .OCLKB(1'b0),
        .RST(rst),
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0)
      );
    end
  end

    if(DEVICE_TYPE == DEVICE_6SERIES) begin
      (* IODELAY_GROUP = IODELAY_GROUP *)
      IODELAYE1 #(
        .CINVCTRL_SEL ("FALSE"),
        .DELAY_SRC ("I"),
        .HIGH_PERFORMANCE_MODE ("TRUE"),
        .IDELAY_TYPE ("VAR_LOADABLE"),
        .IDELAY_VALUE (0),
        .ODELAY_TYPE ("FIXED"),
        .ODELAY_VALUE (0),
        .REFCLK_FREQUENCY (200.0),
        .SIGNAL_PATTERN ("DATA"))
      i_rx_data_idelay (
        .T (1'b1),
        .CE (1'b0),
        .INC (1'b0),
        .CLKIN (1'b0),
        .DATAIN (1'b0),
        .ODATAIN (1'b0),
        .CINVCTRL (1'b0),
        .C (up_clk),
        .IDATAIN (data_in_ibuf_s),
        .DATAOUT (data_in_idelay_s),
        .RST (rst),
        .CNTVALUEIN (up_dwdata),
        .CNTVALUEOUT (up_drdata));

      ISERDESE1 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(PARALLEL_WIDTH),
        .DYN_CLKDIV_INV_EN("FALSE"),
        .DYN_CLK_INV_EN("FALSE"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("NETWORKING"),
        .IOBDELAY("NONE"),
        .NUM_CE(1),
        .OFB_USED("FALSE"),
        .SERDES_MODE("MASTER"),
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0))
      i_serdes_m (
        .O(),
        .Q1(data_s0),
        .Q2(data_s1),
        .Q3(data_s2),
        .Q4(data_s3),
        .Q5(data_s4),
        .Q6(data_s5),
        .SHIFTOUT1(data_shift1_s),
        .SHIFTOUT2(data_shift2_s),
        .BITSLIP(1'b0),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLK(clk),
        .CLKB(1'b0),
        .CLKDIV(div_clk),
        .OCLK(1'b0),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(data_in_idelay_s),
        .DDLY(1'b0),
        .OFB(1'b0),
        .RST(rst),
        .SHIFTIN1(1'b0),
        .SHIFTIN2(1'b0)
      );

      ISERDESE1 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(PARALLEL_WIDTH),
        .DYN_CLKDIV_INV_EN("FALSE"),
        .DYN_CLK_INV_EN("FALSE"),
        .INIT_Q1(1'b0),
        .INIT_Q2(1'b0),
        .INIT_Q3(1'b0),
        .INIT_Q4(1'b0),
        .INTERFACE_TYPE("NETWORKING"),
        .IOBDELAY("NONE"),
        .NUM_CE(1),
        .OFB_USED("FALSE"),
        .SERDES_MODE("SLAVE"),
        .SRVAL_Q1(1'b0),
        .SRVAL_Q2(1'b0),
        .SRVAL_Q3(1'b0),
        .SRVAL_Q4(1'b0))
      i_serdes_s (
        .O(),
        .Q1(),
        .Q2(),
        .Q3(data_s6),
        .Q4(data_s7),
        .Q5(),
        .Q6(),
        .SHIFTOUT1(),
        .SHIFTOUT2(),
        .BITSLIP(bitslip),
        .CE1(1'b1),
        .CE2(1'b1),
        .CLK(clk),
        .CLKB(1'b0),
        .CLKDIV(div_clk),
        .OCLK(1'b0),
        .DYNCLKDIVSEL(1'b0),
        .DYNCLKSEL(1'b0),
        .D(1'b0),
        .DDLY(1'b0),
        .OFB(1'b0),
        .RST(rst),
        .SHIFTIN1(data_shift1_s),
        .SHIFTIN2(data_shift2_s));
      end
//
   // ISERDESE3: Input SERial/DESerializer
   //            Kintex UltraScale
   // Xilinx HDL Language Template, version 2015.2
       if(DEVICE_TYPE == DEVICE_ULTRASCALE)
 begin
      (* IODELAY_GROUP = IODELAY_GROUP *)
   IDELAYE3 #(
      .CASCADE("NONE"),         // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
      .DELAY_FORMAT("TIME"),    // Units of the DELAY_VALUE (COUNT, TIME)
      .DELAY_SRC("IDATAIN"),    // Delay input (DATAIN, IDATAIN)
      .DELAY_TYPE("VAR_LOAD"),     // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
      .DELAY_VALUE(0),          // Input delay value setting
      .IS_CLK_INVERTED(1'b0),   // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),   // Optional inversion for RST
      .REFCLK_FREQUENCY(200.0), // IDELAYCTRL clock input frequency in MHz (200.0-2400.0)
      .UPDATE_MODE("ASYNC")     // Determines when updates to the delay will take effect (ASYNC, MANUAL, SYNC)
   )
   IDELAYE3_inst (
      .CASC_OUT(CASC_OUT),       // 1-bit output: Cascade delay output to ODELAY input cascade
      .CNTVALUEOUT(up_drdata), // 9-bit output: Counter value output
      .DATAOUT(data_in_idelay_s),         // 1-bit output: Delayed data output
      .CASC_IN(1'b0),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
      .CASC_RETURN(1'b0), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
      .CE(1'b0),                   // 1-bit input: Active high enable increment/decrement input
      .CLK(up_clk),                 // 1-bit input: Clock input
      .CNTVALUEIN(up_dwdata),   // 9-bit input: Counter value input
      .DATAIN(1'b0),           // 1-bit input: Data input from the logic
      .EN_VTC(1'b0),           // 1-bit input: Keep delay constant over VT
      .IDATAIN(data_in_ibuf_s),         // 1-bit input: Data input from the IOBUF
      .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
      .LOAD(up_dld),               // 1-bit input: Load DELAY_VALUE input
      .RST(rst)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
   );
   
   ISERDESE3 #(
      .DATA_WIDTH(8),           // Parallel data width (4,8)
      .FIFO_ENABLE("FALSE"),    // Enables the use of the FIFO
      .FIFO_SYNC_MODE("FALSE"), // Enables the use of internal 2-stage synchronizers on the FIFO
      .IS_CLK_B_INVERTED(1'b0), // Optional inversion for CLK_B
      .IS_CLK_INVERTED(1'b0),   // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0)    // Optional inversion for RST
   )
   ISERDESE3_inst (
      .FIFO_EMPTY(FIFO_EMPTY),           // 1-bit output: FIFO empty flag
      .INTERNAL_DIVCLK(INTERNAL_DIVCLK), // 1-bit output: Internally divided down clock used when FIFO is
                                         // disabled (do not connect)

      .Q(iserdes3_parallel_data),                             // 8-bit registered output
      .CLK(clk),                         // 1-bit input: High-speed clock
      .CLKDIV(div_clk),                   // 1-bit input: Divided Clock
      .CLK_B(~clk),                     // 1-bit input: Inversion of High-speed clock CLK
      .D(data_in_idelay_s),                             // 1-bit input: Serial Data Input
      .FIFO_RD_CLK(1'b0),         // 1-bit input: FIFO read clock
      .FIFO_RD_EN(1'b0),           // 1-bit input: Enables reading the FIFO when asserted
      .RST(rst)                          // 1-bit input: Asynchronous Reset
   );
	 assign data_s0=iserdes3_parallel_data[0];
	 assign data_s1=iserdes3_parallel_data[1];
	 assign data_s2=iserdes3_parallel_data[2];
	 assign data_s3=iserdes3_parallel_data[3];
	 assign data_s4=iserdes3_parallel_data[4];
	 assign data_s5=iserdes3_parallel_data[5];
	 assign data_s6=iserdes3_parallel_data[6];
	 assign data_s7=iserdes3_parallel_data[7];
/* -----\/----- EXCLUDED -----\/-----
    assign data_s0=temp0;
    assign data_s1=temp1;
    assign data_s2=temp2;
    assign data_s3=temp3;
    assign data_s4=temp4;
    assign data_s5=temp5;
    assign data_s6=temp6;
    assign data_s7=temp7;
 -----/\----- EXCLUDED -----/\----- */
       end // if (DEVICE_TYPE == DEVICE_ULTRASCALE)
   
	  
endmodule

