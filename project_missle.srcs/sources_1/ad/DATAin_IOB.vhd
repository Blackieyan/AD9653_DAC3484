----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/06 16:12:48
-- Design Name: 
-- Module Name: DATAin_IOB - Behavioral
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
library UNISIM;
library UNIMACRO;
use UNIMACRO.vcomponents.all;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use UNISIM.vcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATAin_IOB is
  port (
    rst_n   : in  std_logic;
    clk     : in  std_logic;
    -- clkB    : in  std_logic;
    div_clk : in  std_logic;
    a_d0_p  : in  std_logic;
    a_d0_n  : in  std_logic;
    a_d1_p  : in  std_logic;
    a_d1_n  : in  std_logic;
    ----------------------------------------------------------------------------
    data_A  : out std_logic_vector(15 downto 0)
    );
end DATAin_IOB;

architecture Behavioral of DATAin_IOB is
attribute KEEP : string;
attribute KEEP of data_A: signal is "TRUE";
  -- component ad_serdes_in
  --   port(
  --     rst          : in  std_logic;
  --     clk          : in  std_logic;
  --     div_clk      : in  std_logic;
  --     data_in_p    : in  std_logic_vector(0 downto 0);
  --     data_in_n    : in  std_logic_vector(0 downto 0);
  --     up_clk       : in  std_logic;
  --     up_dld       : in  std_logic;
  --     up_dwdata    : in  std_logic_vector(4 downto 0);
  --     delay_clk    : in  std_logic;
  --     delay_rst    : in  std_logic;
  --     data_s0      : out std_logic;
  --     data_s1      : out std_logic;
  --     data_s2      : out std_logic;
  --     data_s3      : out std_logic;
  --     data_s4      : out std_logic;
  --     data_s5      : out std_logic;
  --     data_s6      : out std_logic;
  --     data_s7      : out std_logic;
  --     up_drdata    : out std_logic_vector(4 downto 0);
  --     bitslip : in std_logic;
  --     delay_locked : out std_logic
  --     );
  -- end component;

  component iserdes is
    port (
      rst          : in  std_logic;
      clk          : in  std_logic;
      -- clkB         : in  std_logic;
      div_clk      : in  std_logic;
      data_in0_p   : in  std_logic;
      data_in0_n   : in  std_logic;
      data_in1_p   : in  std_logic;
      data_in1_n   : in  std_logic;
      BITSLIP_low  : in  std_logic;
      BITSLIP_high : in  std_logic;
      data_combine : out std_logic_vector(15 downto 0));
  end component iserdes;
-------------------------------------------------------------------------------
begin

  -- Inst_a_d0_serdes_in : ad_serdes_in port map(
  --   rst          => not rst_n,
  --   clk          => clk,
  --   div_clk      => div_clk,
  --   data_s0      => a_d0_s0,
  --   data_s1      => a_d0_s1,
  --   data_s2      => a_d0_s2,
  --   data_s3      => a_d0_s3,
  --   data_s4      => a_d0_s4,
  --   data_s5      => a_d0_s5,
  --   data_s6      => a_d0_s6,
  --   data_s7      => a_d0_s7,
  --   data_in_p    => a_d0_p,
  --   data_in_n    => a_d0_n,
  --   up_clk       => clk_dly,
  --   up_dld       => up_dld,  --Loads the IDELAYE2 primitive to the pre-programmed value
  --   up_dwdata    => a0_dwdata,  --Counter value from FPGA logic for dynamically loadable tap value.
  --   up_drdata    => a0_drdata,  --Counter value going to FPGA logic for monitoring tap value.
  --   delay_clk    => clk_dly,            --clk_200M
  --   delay_rst    => not rst_n,
  --   bitslip => bitslip,
  --   delay_locked => a0_delay_locked     --output flag
  --   );

  -- Inst_a_d1_serdes_in : ad_serdes_in port map(
  --   rst          => not rst_n,
  --   clk          => clk,
  --   div_clk      => div_clk,
  --   data_s0      => a_d1_s0,
  --   data_s1      => a_d1_s1,
  --   data_s2      => a_d1_s2,
  --   data_s3      => a_d1_s3,
  --   data_s4      => a_d1_s4,
  --   data_s5      => a_d1_s5,
  --   data_s6      => a_d1_s6,
  --   data_s7      => a_d1_s7,
  --   data_in_p    => a_d1_p,
  --   data_in_n    => a_d1_n,
  --   up_clk       => clk_dly,
  --   up_dld       => up_dld,  --Loads the IDELAYE2 primitive to the pre-programmed value
  --   up_dwdata    => a1_dwdata,  --Counter value from FPGA logic for dynamically loadable tap value.
  --   up_drdata    => a1_drdata,  --Counter value going to FPGA logic for monitoring tap value.
  --   delay_clk    => clk_dly,            --clk_200M
  --   delay_rst    => not rst_n,
  --   bitslip =>bitslip,
  --   delay_locked => a1_delay_locked     --output flag
  --   );

  --Note: The first sample in time will be data_s7, the last data_s0!
  iserdes_1 : entity work.iserdes
    port map (
      rst          => not rst_n,
      clk          => clk,
      -- clkB         => clkB,
      div_clk      => div_clk,
      data_in0_p   => a_d0_p,
      data_in0_n   => a_d0_n,
      data_in1_p   => a_d1_p,
      data_in1_n   => a_d1_n,
      BITSLIP_low  => '0',
      BITSLIP_high => '0',
      data_combine => data_A);

end Behavioral;
