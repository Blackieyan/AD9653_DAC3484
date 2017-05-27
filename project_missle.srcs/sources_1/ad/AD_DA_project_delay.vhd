----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/06 21:49:25
-- Design Name: 
-- Module Name: AD_DA_project - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity AD_DA_project is
  port (
    user_pushbutton_g : in  std_logic;  --global reset_n by pushbutton on pcb
    osc_in_p          : in  std_logic;
    osc_in_n          : in  std_logic;
    ----------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    --ad9653 interface
    dco_p             : in  std_logic;
    dco_n             : in  std_logic;  --data clock output,500MHz ddr
    ----------------------------------------------------------------------------
    fco_p             : in  std_logic;
    fco_n             : in  std_logic;
    -- bitslip : in std_logic;
    ---------------------------------------------------------------------------
    a_d0_p            : in  std_logic;
    a_d0_n            : in  std_logic;
    a_d1_p            : in  std_logic;
    a_d1_n            : in  std_logic;
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    --dac3484 interface
    Q_p               : out std_logic_vector(15 downto 0);
    Q_n               : out std_logic_vector(15 downto 0);
    frame_p           : out std_logic;
    frame_n           : out std_logic;
    SYNC_p            : out std_logic;
    SYNC_n            : out std_logic;
    DataCLk_p         : out std_logic;
    DataCLk_n         : out std_logic;
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- spi interface
    SDIO              : out std_logic;
    SCLK              : out std_logic;
    SDENB             : out std_logic
    );
end AD_DA_project;

architecture Behavioral of AD_DA_project is

  signal clk_dly       : std_logic;
  signal lck_rst_n     : std_logic;
-- signal user_pushbutton_g : std_logic;   
-- signal a0_drdata : std_logic_vector(4 downto 0);
-- signal a1_drdata : std_logic_vector(4 downto 0);           --for chipscope and sim
  signal fifo_a_dout   : std_logic_vector(15 downto 0);  --data output from channel A
  signal CLK_500M_quar : std_logic;
  signal CLK_500M      : std_logic;
  signal clk_250M      : std_logic;
  signal clk_200M      : std_logic;
  signal fco           : std_logic;
  signal dco           : std_logic;
  signal dco_div       : std_logic;
  signal rst_n         : std_logic;
  signal bitslip       : std_logic;
  signal Addr_in       : std_logic_vector(7 downto 0);
  signal Addr_en       : std_logic;
  signal data_in       : std_logic_vector(15 downto 0);
  signal reg_rst_n     : std_logic;
  signal reg_rdy       : std_logic;
  signal Data_A        : std_logic_vector(15 downto 0) := x"0000";
  signal Data_B        : std_logic_vector(15 downto 0) := x"1111";
  signal Data_C        : std_logic_vector(15 downto 0) := x"2222";
  signal data_D        : std_logic_vector(15 downto 0) := x"3333";
  component ADC_interface is
    port (
      rst_n       : in  std_logic;
      a_d0_p      : in  std_logic;
      a_d0_n      : in  std_logic;
      a_d1_p      : in  std_logic;
      a_d1_n      : in  std_logic;
      dco         : in  std_logic;
      dco_div     : in  std_logic;
      fco         : in  std_logic;
      fifo_a_dout : out std_logic_vector(15 downto 0));
  end component ADC_interface;

  component DAC_interface is
    port (
      rst_n     : in  std_logic;
      CLK       : in  std_logic;
      CLK_div   : in  std_logic;
      clk_dly : in std_logic;
      Q_p       : out std_logic_vector(15 downto 0);
      Q_n       : out std_logic_vector(15 downto 0);
      frame_p   : out std_logic;
      frame_n   : out std_logic;
      SYNC_p    : out std_logic;
      SYNC_n    : out std_logic;
      DataCLk_p : out std_logic;
      DataCLk_n : out std_logic;
      Data_A    : in  std_logic_vector(15 downto 0);
      Data_B    : in  std_logic_vector(15 downto 0);
      Data_C    : in  std_logic_vector(15 downto 0);
      Data_D    : in  std_logic_vector(15 downto 0);
      DataCLk   : in  std_logic);
  end component DAC_interface;

  component crg_dcms is
    port (
      OSC_in_p          : in  std_logic;
      OSC_in_n          : in  std_logic;
      fco_p             : in  std_logic;
      fco_n             : in  std_logic;
      dco_p             : in  std_logic;
      dco_n             : in  std_logic;
      dco_div           : out std_logic;
      dco               : out std_logic;
      fco               : out std_logic;
      lck_rst_n         : out std_logic;
      user_pushbutton_g : in  std_logic;
      CLK_500M_quar     : out std_logic;
      CLK_500M          : out std_logic;
      CLK_200M          : out std_logic;
      CLK_250M          : out std_logic);
  end component crg_dcms;

  component spi_config is
    port (
      CLK       : in  std_logic;
      Addr_in   : in  std_logic_vector(7 downto 0);
      Addr_en   : in  std_logic;
      Data_in   : in  std_logic_vector(15 downto 0);
      reg_rst_n : in  std_logic;
      reg_rdy   : out std_logic;
      SCLK      : out std_logic;
      SDIO      : out std_logic;
      SDENB     : out std_logic);
  end component spi_config;

  component config_reg_data is
    port (
      clk     : in  std_logic;
      Addr_en : out std_logic;
      Addr_in : out std_logic_vector(7 downto 0);
      Data_in : out std_logic_vector(15 downto 0)
      );
  end component config_reg_data;
-------------------------------------------------------------------------------
begin

  ADC_interface_inst : ADC_interface
    port map (
      rst_n       => rst_n,
      a_d0_p      => a_d0_p,
      a_d0_n      => a_d0_n,
      a_d1_p      => a_d1_p,
      a_d1_n      => a_d1_n,
      dco         => dco,
      dco_div     => dco_div,
      fco         => fco,
      fifo_a_dout => fifo_a_dout);

  DAC_interface_inst : DAC_interface
    port map (
      rst_n     => rst_n,
      CLK       => CLK_500M,            -- clk 500MHz 0degree
      CLK_div   => CLK_250M,            --clk 250MHz
      clk_dly => CLK_200M,
      Q_p       => Q_p,
      Q_n       => Q_n,
      frame_p   => frame_p,
      frame_n   => frame_n,
      SYNC_p    => SYNC_p,
      SYNC_n    => SYNC_n,
      DataCLk_p => DataCLk_p,
      DataCLk_n => DataCLk_n,
      Data_A    => Data_A,
      Data_B    => Data_B,
      Data_C    => Data_C,
      Data_D    => Data_D,
      DataCLk   => CLK_500M_quar);      -- clk 500MHz 90degree shift

  spi_config_inst : spi_config
    port map (
      CLK       => CLK_250M,
      Addr_in   => Addr_in,
      Addr_en   => Addr_en,
      Data_in   => Data_in,
      reg_rst_n => rst_n,
      reg_rdy   => reg_rdy,
      SCLK      => SCLK,
      SDIO      => SDIO,
      SDENB     => SDENB);

  crg_dcms_inst : crg_dcms
    port map (
      OSC_in_p          => OSC_in_p,
      OSC_in_n          => OSC_in_n,
      fco_p             => fco_p,
      fco_n             => fco_n,
      dco_p             => dco_p,
      dco_n             => dco_n,
      dco_div           => dco_div,
      dco               => dco,
      fco               => fco,
      lck_rst_n         => lck_rst_n,
      user_pushbutton_g => user_pushbutton_g,
      CLK_500M_quar     => CLK_500M_quar,
      CLK_500M          => CLK_500M,
      CLK_200M          => CLK_200M,
      CLK_250M          => CLK_250M);


  rst_n_ps: process (user_pushbutton_g, lck_rst_n) is
  begin  -- process rst_n_ps
      reg_rst_n <= (not user_pushbutton_g) and lck_rst_n;
  end process rst_n_ps;

     BUFG_inst : BUFG
   port map (
      O => rst_n, -- 1-bit output: Clock output
      I => reg_rst_n  -- 1-bit input: Clock input
   );

  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  --spi control  data
  config_reg_data_inst : config_reg_data
    port map (
      clk     => CLK_250M,
      Addr_en => Addr_en,
      Addr_in => Addr_in,
      Data_in => Data_in);


end Behavioral;
