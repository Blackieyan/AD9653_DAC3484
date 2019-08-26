//*****************************************************************************
// File    : 
// Project :        
// Tool    : Xilinx Vivado 2015.2
//
// Modify history
// Version :
// Date    :
// Note    :
//*****************************************************************************

module spi_intf
(
   input        clk             ,
   output       rst_adc0        ,
   output       rst_adc1        ,
   output       rst_dac0        ,
   output       rst_dac1        ,
   output       adc0_csb        ,
   inout        adc0_sdio       ,
   output       adc0_sclk       ,
   output       adc1_csb        ,
   inout        adc1_sdio       ,
   output       adc1_sclk       ,
//   input        dac0_sdo        ,
   inout        dac0_sdio       ,
   output       dac0_sclk       ,
   output       dac0_sdenb_n    ,   
//   input        dac1_sdo        ,
   inout        dac1_sdio       ,
   output       dac1_sclk       ,
   output       dac1_sdenb_n    ,   
// input         alarm_dac0     ,
   output       txenable_dac0   ,
   output       reset_dac0_n    ,
   output       sleep_dac0      ,
// input         alarm_dac1      ,
   output       txenable_dac1   ,   
   output       reset_dac1_n    ,
   output       sleep_dac1      ,
   input        spi_arm_a7_clk  ,  
   input        spi_arm_a7_c0   ,  
   output reg   spi_arm_a7_miso ,  
   input        spi_arm_a7_mosi ,  
   input        gpio0_arm_a7    , 
   input        gpio1_arm_a7    , 
   input        gpio2_arm_a7    , 
   input        gpio3_arm_a7    , 
   input        gpio4_arm_a7    , 
   input        gpio5_arm_a7    , 
   input        gpio6_arm_a7    ,
   input        gpio7_arm_a7 
 );

///*********************************************************************
/// SPI hub
///*********************************************************************
//ila_4k u_ila
//(
//  .clk    ( clk ),
//  .probe0 ( {adc0_sclk,adc0_csb,adc1_sclk,adc1_csb,spi_arm_a7_clk,spi_arm_a7_c0,spi_arm_a7_mosi,spi_arm_a7_miso,gpio0_arm_a7,gpio1_arm_a7,gpio2_arm_a7,gpio3_arm_a7,gpio3_arm_a7,gpio4_arm_a7,gpio5_arm_a7,gpio6_arm_a7} )
//);

//ADC0
assign adc0_sclk = spi_arm_a7_clk;
assign adc0_csb  = gpio1_arm_a7 ? spi_arm_a7_c0 : 1'b1;
assign adc0_sdio = ((!gpio0_arm_a7) && gpio1_arm_a7)? spi_arm_a7_mosi : 1'bz;

//ADC1
assign adc1_sclk = spi_arm_a7_clk;
assign adc1_csb  = gpio2_arm_a7 ? spi_arm_a7_c0 : 1'b1;
assign adc1_sdio = ((!gpio0_arm_a7) && gpio2_arm_a7)? spi_arm_a7_mosi : 1'bz;

//DAC0
assign dac0_sclk     = spi_arm_a7_clk;
assign dac0_sdenb_n  = gpio3_arm_a7 ? spi_arm_a7_c0 : 1'b1;
assign dac0_sdio     = ((!gpio0_arm_a7)&& gpio3_arm_a7)? spi_arm_a7_mosi : 1'bz;
assign dac0_sdo      = 1'b0;
assign txenable_dac0 = gpio3_arm_a7 && gpio6_arm_a7;  
assign reset_dac0_n  = ((!gpio3_arm_a7) | gpio5_arm_a7);  
assign sleep_dac0    = 1'b0 ;  

//DAC1
assign dac1_sclk     = spi_arm_a7_clk;
assign dac1_sdenb_n  = gpio4_arm_a7 ? spi_arm_a7_c0 : 1'b1;
assign dac1_sdio     = ((!gpio0_arm_a7) && gpio4_arm_a7)? spi_arm_a7_mosi : 1'bz;
assign dac1_sdo      = 1'b0;
assign txenable_dac1 = gpio4_arm_a7 && gpio6_arm_a7;  
assign reset_dac1_n  = ((!gpio4_arm_a7) | gpio5_arm_a7);  
assign sleep_dac1    = 1'b0 ;  

always	@(*)
begin
	case({gpio4_arm_a7,gpio3_arm_a7,gpio2_arm_a7,gpio1_arm_a7})
			4'b0001 : spi_arm_a7_miso = adc0_sdio; 
			4'b0010 : spi_arm_a7_miso = adc1_sdio;
			4'b0100 : spi_arm_a7_miso = dac0_sdio;
			4'b1000 : spi_arm_a7_miso = dac1_sdio;
			default : spi_arm_a7_miso = 1'bz;
	endcase
end

assign rst_adc0 = gpio7_arm_a7 & gpio1_arm_a7;
assign rst_adc1 = gpio7_arm_a7 & gpio2_arm_a7;
assign rst_dac0 = gpio7_arm_a7 & gpio3_arm_a7;
assign rst_dac1 = gpio7_arm_a7 & gpio4_arm_a7;

endmodule