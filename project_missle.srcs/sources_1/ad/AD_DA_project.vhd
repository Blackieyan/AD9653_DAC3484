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
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD_DA_project is
  port (
    user_pushbutton_g : in std_logic; --global reset_n by pushbutton on pcb
    osc_in_p : in std_logic;
    osc_in_n : in std_logic;
    ----------------------------------------------------------------------------
    dco_p : in std_logic;
    dco_n : in std_logic;               --data clock output,500MHz ddr
    ----------------------------------------------------------------------------
    fco_p : in std_logic;
    fco_n : in std_logic;
    bitslip : in std_logic;
    ---------------------------------------------------------------------------
    a_d0_p : in std_logic_vector(0 downto 0);
    a_d0_n : in std_logic_vector(0 downto 0);
    a_d1_p : in std_logic_vector(0 downto 0);
    a_d1_n : in std_logic_vector(0 downto 0)
    );
end AD_DA_project;

architecture Behavioral of AD_DA_project is
  
signal clk_dly : std_logic;
signal lck_rst_n : std_logic;
-- signal user_pushbutton_g : std_logic;   
signal a0_drdata : std_logic_vector(4 downto 0);
signal a1_drdata : std_logic_vector(4 downto 0);           --for chipscope and sim
signal fifo_a_dout : std_logic_vector(15 downto 0);         --data output from channel A
signal clk_250M : std_logic;
signal clk_200M : std_logic;
signal fco : std_logic;
signal dco : std_logic;
signal dco_div : std_logic;
signal rst_n : std_logic;

  component AD9653_top is
    port (
      rst_n       : in  std_logic;
      a_d0_p      : in  std_logic_vector(0 downto 0);
      a_d0_n      : in  std_logic_vector(0 downto 0);
      a_d1_p      : in  std_logic_vector(0 downto 0);
      a_d1_n      : in  std_logic_vector(0 downto 0);
      dco         : in  std_logic;
      dco_div     : in  std_logic;
      fco         : in  std_logic;
      clk_dly     : in  std_logic;
      a0_drdata   : out std_logic_vector(4 downto 0);
      a1_drdata   : out std_logic_vector(4 downto 0);
      bitslip : in std_logic;
      fifo_a_dout : out std_logic_vector(15 downto 0));
  end component AD9653_top;

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
      CLK_200M          : out std_logic;
      CLK_250M          : out std_logic);
  end component crg_dcms;

begin

  AD9653_top_inst : AD9653_top
    port map (
      rst_n       => rst_n,
      a_d0_p      => a_d0_p,
      a_d0_n      => a_d0_n,
      a_d1_p      => a_d1_p,
      a_d1_n      => a_d1_n,
      dco         => dco,
      dco_div     => dco_div,
      fco         => fco,
      clk_dly     => CLK_200M,
      a0_drdata   => a0_drdata,
      a1_drdata   => a1_drdata,
      bitslip => bitslip,
      fifo_a_dout => fifo_a_dout);

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
      CLK_200M          => CLK_200M,
      CLK_250M          => CLK_250M);

  rst_n<=user_pushbutton_g and lck_rst_n;
end Behavioral;
