`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/05/29 10:16:44
// Design Name: 
// Module Name: Frame_Check
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


module Frame_Check(
    input Frame,
    input clk,
    input clk_div,
    output bitslip_out,
    input rst_in
    );
    
    //1. Frame 进入 ISERDES模块
    //2. 检查输出的数据是否是F0
    //3. 如果是F0 结束 如果不是F0 发出bitslip信号，等待3个时钟周期回到2
   reg       bitslip;
   wire [7:0] serdes_out;
   ISERDESE2 #(
      .DATA_RATE("DDR"),           // DDR, SDR
      .DATA_WIDTH(8),              // Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN("FALSE"), // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN("FALSE"),    // Enable DYNCLKINVSEL inversion (FALSE, TRUE)
      // INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1(1'b0),
      .INIT_Q2(1'b0),
      .INIT_Q3(1'b0),
      .INIT_Q4(1'b0),
      .INTERFACE_TYPE("NETWORKING"),   // MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY("NONE"),           // NONE, BOTH, IBUF, IFD
      .NUM_CE(2),                  // Number of clock enables (1,2)
      .OFB_USED("FALSE"),          // Select OFB path (FALSE, TRUE)
      .SERDES_MODE("MASTER"),      // MASTER, SLAVE
      // SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1(1'b0),
      .SRVAL_Q2(1'b0),
      .SRVAL_Q3(1'b0),
      .SRVAL_Q4(1'b0) 
   )
   ISERDESE2_inst (
      .O(),                       // 1-bit output: Combinatorial output
      // Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1(serdes_out[0]),
      .Q2(serdes_out[1]),
      .Q3(serdes_out[2]),
      .Q4(serdes_out[3]),
      .Q5(serdes_out[4]),
      .Q6(serdes_out[5]),
      .Q7(serdes_out[6]),
      .Q8(serdes_out[7]),
      // SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1(),
      .SHIFTOUT2(),
      .BITSLIP(bitslip),           // 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
                                   // CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
                                   // to Q8 output ports will shift, as in a barrel-shifter operation, one
                                   // position every time Bitslip is invoked (DDR operation is different from
                                   // SDR).

      // CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE1(1),
      .CE2(1),
      .CLKDIVP(0),           // 1-bit input: TBD
      // Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK(clk),                   // 1-bit input: High-speed clock
      .CLKB(~clk),                 // 1-bit input: High-speed secondary clock
      .CLKDIV(clk_div),             // 1-bit input: Divided clock
      .OCLK(),                 // 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
      // Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL(0), // 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL(0),       // 1-bit input: Dynamic CLK/CLKB inversion
      // Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D(Frame),                       // 1-bit input: Data input
      .DDLY(0),                 // 1-bit input: Serial data from IDELAYE2
      .OFB(0),                   // 1-bit input: Data feedback from OSERDESE2
      .OCLKB(),               // 1-bit input: High speed negative edge output clock
      .RST(rst_in),                   // 1-bit input: Active high asynchronous reset
      // SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1(0),
      .SHIFTIN2(0) 
   );    
  //判断ISERDES输出是否是F0 
  wire check_enable;
  assign check_enable = (judge_cnt[2:0] == 0) ? 1 : 0;
  assign bitslip_out  = bitslip;
  reg [7:0] serdes_out_reg;
  reg [2:0] judge_cnt=0;
  always @(posedge clk_div) begin
      serdes_out_reg  <= serdes_out;
  end     
  
  always @(posedge clk_div) begin
      if(serdes_out_reg != 8'hF0 & check_enable == 1)begin
         bitslip <= 1;
      end
      else begin
         bitslip <= 0;
      end
  end
  always @(posedge clk_div) begin
      if(rst_in)
         judge_cnt <= 0;
      else if(serdes_out_reg != 8'hF0 & check_enable == 1)begin
         judge_cnt <= 1;
      end
      else begin
         if(judge_cnt != 0)
           judge_cnt <= judge_cnt + 1;
      end
  end       
endmodule
