----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:16 05/04/2015 
-- Design Name: 
-- Module Name:    DDR_TRI - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DDR_TRI is
  port(
    Data_en : in std_logic;
    Data_A  : in std_logic_vector(15 downto 0);
    Data_B  : in std_logic_vector(15 downto 0);
    Data_C  : in std_logic_vector(15 downto 0);
    data_D  : in std_logic_vector(15 downto 0);

    ---------------------------------------------------------------------------
    --clock & reset
    rst     : in  std_logic;
    CLK     : in  std_logic;
    ---------------------------------------------------------------------------
    --sync port
    DataCLk : out std_logic;
    Frame   : out std_logic;
    Q       : out std_logic_vector(15 downto 0);
    SYNC    : out std_logic;

    ---------------------------------------------------------------------------
    --test clock port
    CLK3_250m_out : out std_logic;
    CLK5_500m_out : out std_logic

    );
end DDR_TRI;
-------------------------------------------------------------------------------
architecture Behavioral of DDR_TRI is
  signal ABCD_combine : std_logic_vector(63 downto 0);
  signal dout_fifo    : std_logic_vector(31 downto 0);
  signal CLK1_500m    : std_logic;
  signal CLK2_500m    : std_logic;
  signal CLK4_500m    : std_logic;
  signal CLK5_500m    : std_logic;
  signal CLK1_temp    : std_logic;
  signal CLK2_temp    : std_logic;
  signal CLK1_tt      : std_logic;
  signal CLK2_tt      : std_logic;
  signal CLK3_250m    : std_logic;
  signal LOCKED       : std_logic;
  signal empty        : std_logic;
  signal rd_en        : std_logic;
  signal wr_en        : std_logic;
  signal valid        : std_logic;

  signal CLKFB_OUT0 : std_logic;
  signal CLKFB_OUT1 : std_logic;
  signal clk_OUT1   : std_logic;
--  signal CLKFB_IN :std_logic;
--  signal CLKFB_OUT :std_logic;
---------------------------------------------------------------------------------
  -- component ODDR_module
  --   port(
  --     CLK0 : in  std_logic;
  --     D0   : in  std_logic_vector(15 downto 0);
  --     D1   : in  std_logic_vector(15 downto 0);
  --     valid : in std_logic;
  --     Q    : out std_logic_vector(15 downto 0);
  --     frame : out std_logic;
  --     sync : out std_logic
  --     );
  -- end component;



  component fifo_64in32out512depth
    port (
      wr_clk    : in  std_logic;
      rst       : in  std_logic;
      rd_clk    : in  std_logic;
      din       : in  std_logic_vector(63 downto 0);
      wr_en     : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(31 downto 0);
      full      : out std_logic;
      empty     : out std_logic;
      valid     : out std_logic;
      prog_full : out std_logic
      );
  end component;

  component DCM_dac
    port
      (                                 -- Clock in ports
        CLK_IN1  : in  std_logic;
        -- Clock out ports
        CLK_OUT1 : out std_logic;
        CLK_OUT2 : out std_logic;
        CLK_OUT3 : out std_logic;
        CLK_OUT4 : out std_logic;
        CLK_OUT5 : out std_logic;
        -- Status and control signals
        RESET    : in  std_logic;
        LOCKED   : out std_logic
        );
  end component;

-------------------------------------------------------------------------------
begin

  -- DDR_out_ABCD : DDR_out
  --   port map(
  --     CLK0 => CLK1_500m,
  --     D0   => dout_fifo(31 downto 16),
  --     D1   => dout_fifo(15 downto 0),
  --     valid => valid,
  --     frame => frame,
  --     Q    => Q
  --     );

  fifoABCD : fifo_64in32out512depth
    port map (
      wr_clk    => CLK3_250m,
      rst       => rst,
      rd_clk    => CLK1_500m,
      din       => ABCD_combine,
      wr_en     => wr_en,
      rd_en     => rd_en,
      dout      => dout_fifo,
      full      => open,
      empty     => empty,
      prog_full => open,
      valid     => valid
      );

  DCMdac : DCM_dac
    port map
    (                                   -- Clock in ports
      CLK_IN1  => CLK,
      -- Clock out ports
      CLK_OUT1 => CLK1_500m,            --500mhz
      CLK_OUT2 => CLK2_500m,            --500mhz,180shift
      CLK_OUT3 => CLK3_250m,
      CLK_OUT4 => CLK4_500m,
      CLK_OUT5 => CLK5_500m,
      RESET    => '0',
      LOCKED   => LOCKED
      );


  DataCLk <= CLK5_500m;

  CLK3_250m_out <= CLK3_250m;
  CLK5_500m_out <= CLK5_500m;

  ABCD_combine <= Data_A & Data_B & Data_C & Data_D;
  wr_en        <= Data_en;

  process (CLK1_500m, rst) is
  begin  -- process Data_en_reg
    if rst = '1' then                   -- asynchronous reset (active low)
      rd_en <= '0';
    elsif CLK1_500m'event and CLK1_500m = '1' then  -- rising clock edge
      rd_en <= not empty;
    end if;
  end process;


  -- ODDR_inst1 : ODDR
  --   generic map(
  --     DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
  --     INIT         => '0',  -- Initial value for Q port ('1' or '0')
  --     SRTYPE       => "ASYNC")          -- Reset Type ("ASYNC" or "SYNC")
  --   port map (
  --     Q  => Frame,                      -- 1-bit DDR output
  --     C  => CLK1_500m,                  -- 1-bit clock input
  --     CE => '1',                        -- 1-bit clock enable input
  --     D1 => valid,                      -- 1-bit data input (positive edge)
  --     D2 => valid,                      -- 1-bit data input (negative edge)
  --     R  => '0',                        -- 1-bit reset input
  --     S  => '0'                         -- 1-bit set input
  --     );

  -- ODDR_inst2 : ODDR
  --   generic map(
  --     DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE" 
  --     INIT         => '0',  -- Initial value for Q port ('1' or '0')
  --     SRTYPE       => "ASYNC")          -- Reset Type ("ASYNC" or "SYNC")
  --   port map (
  --     Q  => SYNC,                       -- 1-bit DDR output
  --     C  => CLK1_500m,                  -- 1-bit clock input
  --     CE => '1',                        -- 1-bit clock enable input
  --     D1 => valid,                      -- 1-bit data input (positive edge)
  --     D2 => valid,                      -- 1-bit data input (negative edge)
  --     R  => '0',                        -- 1-bit reset input
  --     S  => '0'                         -- 1-bit set input
  --     );

end Behavioral;

