----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/12 00:35:38
-- Design Name: 
-- Module Name: DATAout_IOB - Behavioral
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

entity DATAout_IOB is
  port (
    rst_n : in std_logic;
    CLK       : in  std_logic; -- clk 500MHz 0degree
    CLK_div : in std_logic;    --clk 250MHz
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
    DataCLk   : in  std_logic           -- clk 500MHz 90degree shift
    );
end DATAout_IOB;

architecture Behavioral of DATAout_IOB is
signal sync : std_logic;
  signal Frame : std_logic;
signal Q : std_logic_vector(15 downto 0);
  -- component ODDR_module
  --   port(
  --     CLK : in  std_logic;
  --     D0   : in  std_logic_vector(15 downto 0);
  --     D1   : in  std_logic_vector(15 downto 0);
  --     valid : in std_logic;
  --     Q    : out std_logic_vector(15 downto 0);
  --     frame : out std_logic;
  --     sync : out std_logic
  --     );
  -- end component;
  component serdes_out
    port(
      rst      : in  std_logic;
      clk      : in  std_logic;
      div_clk  : in  std_logic;
      Frame    : out std_logic;
      sync     : out std_logic;
      data_s0  : in  std_logic_vector(15 downto 0);
      data_s1  : in  std_logic_vector(15 downto 0);
      data_s2  : in  std_logic_vector(15 downto 0);
      data_s3  : in  std_logic_vector(15 downto 0);
      data_out : out std_logic_vector(15 downto 0)
      );
  end component;

  component OBUFDS_module is
    port (
      Q_p       : out std_logic_vector(15 downto 0);
      Q_n       : out std_logic_vector(15 downto 0);
      Q         : in  std_logic_vector(15 downto 0);
      frame_p   : out std_logic;
      frame_n   : out std_logic;
      frame     : in  std_logic;
      SYNC_p    : out std_logic;
      SYNC_n    : out std_logic;
      sync      : in  std_logic;
      DataCLk_p : out std_logic;
      DataCLk_n : out std_logic;
      DataCLk   : in  std_logic);
  end component OBUFDS_module;
  -----------------------------------------------------------------------------

begin

  -- ODDR_signals_inst : ODDR_module
  --   port map(
  --     CLK => CLK,
  --     D0   => dout_fifo(31 downto 16),
  --     D1   => dout_fifo(15 downto 0),
  --     valid => valid,
  --     frame => frame,
  --     Q    => Q
  --     );
  serdes_out_core : serdes_out
    port map(
      rst      => not rst_n,
      clk      => clk,
      div_clk  => clk_div,
      data_s0  => data_A,
      data_s1  => data_B,
      data_s2  => data_C,
      data_s3  => data_D,
      Frame    => Frame,
      sync     => sync,
      data_out => Q
      );

  OBUFDS_signals_inst : OBUFDS_module
    port map (
      Q_p       => Q_p,
      Q_n       => Q_n,
      Q         => Q,
      frame_p   => frame_p,
      frame_n   => frame_n,
      frame     => frame,
      SYNC_p    => SYNC_p,
      SYNC_n    => SYNC_n,
      sync      => sync,
      DataCLk_p => DataCLk_p,
      DataCLk_n => DataCLk_n,
      DataCLk   => DataCLk);

end Behavioral;
