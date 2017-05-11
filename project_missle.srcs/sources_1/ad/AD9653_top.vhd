----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/06 14:21:52
-- Design Name: 
-- Module Name: AD9653_top - Behavioral
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

entity AD9653_top is
  port (
    rst_n       : in  std_logic;
    ---------------------------------------------------------------------------
    a_d0_p      : in  std_logic_vector(0 downto 0);
    a_d0_n      : in  std_logic_vector(0 downto 0);
    a_d1_p      : in  std_logic_vector(0 downto 0);
    a_d1_n      : in  std_logic_vector(0 downto 0);        --1Gbps per lane,data from Channel A
    ---------------------------------------------------------------------------
    dco         : in  std_logic;        --500MHz 
    dco_div     : in  std_logic;        --dco divide by 8
    fco         : in  std_logic;  --frame clock from adc output, 125MHz sdr
    clk_dly     : in  std_logic;
    ----------------------------------------------------------------------------
    a0_drdata   : out std_logic_vector(4 downto 0);
    a1_drdata   : out std_logic_vector(4 downto 0);
    bitslip : in std_logic;
    ---------------------------------------------------------------------------
    fifo_a_dout : out std_logic_vector(15 downto 0)
    );
end AD9653_top;

architecture Behavioral of AD9653_top is

  signal data_a          : std_logic_vector(15 downto 0);
  signal data_a_tt : 	std_logic_vector(7 downto 0);
  -- signal fifo_a_dout :std_logic_vector(15 downto 0);
  signal fifo_a_full     : std_logic;
  signal fifo_a_empty    : std_logic;
  signal fifo_a_valid    : std_logic;
  signal a0_delay_locked : std_logic;
  signal a1_delay_locked : std_logic;
  signal rd_clk          : std_logic;
  signal a_d0_s0         : std_logic;
  signal a_d0_s1         : std_logic;
  signal a_d0_s2         : std_logic;
  signal a_d0_s3         : std_logic;
  signal a_d0_s4         : std_logic;
  signal a_d0_s5         : std_logic;
  signal a_d0_s6         : std_logic;
  signal a_d0_s7         : std_logic;
  signal a_d1_s0 : std_logic;
  signal a_d1_s1 : std_logic;
  signal a_d1_s2 : std_logic;
  signal a_d1_s3 : std_logic;
  signal a_d1_s4 : std_logic;
  signal a_d1_s5 : std_logic;
  signal a_d1_s6 : std_logic;
  signal a_d1_s7 : std_logic;

  
  component DATAs_IOB
    port(
      rst_n           : in  std_logic;
      clk             : in  std_logic;
      div_clk         : in  std_logic;
      clk_dly         : in  std_logic;
      up_dld          : in  std_logic;
      a_d0_p          : in  std_logic_vector(0 downto 0);
      a_d0_n          : in  std_logic_vector(0 downto 0);
      a_d1_p          : in  std_logic_vector(0 downto 0);
      a_d1_n          : in  std_logic_vector(0 downto 0);
      a0_dwdata       : in  std_logic_vector(4 downto 0);
      a1_dwdata       : in  std_logic_vector(4 downto 0);
      a_d0_s0         : out std_logic;
      a_d0_s1         : out std_logic;
      a_d0_s2         : out std_logic;
      a_d0_s3         : out std_logic;
      a_d0_s4         : out std_logic;
      a_d0_s5         : out std_logic;
      a_d0_s6         : out std_logic;
      a_d0_s7         : out std_logic;
      a_d1_s0         : out std_logic;
      a_d1_s1         : out std_logic;
      a_d1_s2         : out std_logic;
      a_d1_s3         : out std_logic;
      a_d1_s4         : out std_logic;
      a_d1_s5         : out std_logic;
      a_d1_s6         : out std_logic;
      a_d1_s7         : out std_logic;
      a0_drdata       : out std_logic_vector(4 downto 0);
      a1_drdata       : out std_logic_vector(4 downto 0);
      bitslip : in std_logic;
      a0_delay_locked : out std_logic;
      a1_delay_locked : out std_logic
      );
  end component;

  component fifo_generator_0
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(15 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(15 downto 0);
      full   : out std_logic;
      empty  : out std_logic;
      valid  : out std_logic
      );
  end component;

begin

  Inst_DATAs_IOB : DATAs_IOB
    port map(
      rst_n           => rst_n,
      clk             => dco,
      div_clk         => dco_div,
      clk_dly         => clk_dly,
      up_dld          => '1',
      a_d0_p          => a_d0_p,
      a_d0_n          => a_d0_n,
      a_d1_p          => a_d1_p,
      a_d1_n          => a_d1_n,
      a0_dwdata       => "00000",
      a1_dwdata       => "00000",
      a_d0_s0         => a_d0_s0,
      a_d0_s1         => a_d0_s1,
      a_d0_s2         => a_d0_s2,
      a_d0_s3         => a_d0_s3,
      a_d0_s4         => a_d0_s4,
      a_d0_s5         => a_d0_s5,
      a_d0_s6         => a_d0_s6,
      a_d0_s7         => a_d0_s7,
      a_d1_s0         => a_d1_s0,
      a_d1_s1         => a_d1_s1,
      a_d1_s2         => a_d1_s2,
      a_d1_s3         => a_d1_s3,
      a_d1_s4         => a_d1_s4,
      a_d1_s5         => a_d1_s5,
      a_d1_s6         => a_d1_s6,
      a_d1_s7         => a_d1_s7,
      a0_drdata       => a0_drdata,
      a1_drdata       => a1_drdata,
      bitslip => bitslip,
      a0_delay_locked => a0_delay_locked,
      a1_delay_locked => a1_delay_locked
      );

  channel_A_fifo : fifo_generator_0
    port map (
      rst    => not rst_n,
      wr_clk => fco,
      rd_clk => rd_clk,
      din    => data_a,
      wr_en  => '1',
      rd_en  => '1',
      dout   => fifo_a_dout,
      full   => fifo_a_full,
      empty  => fifo_a_empty,
      valid  => fifo_a_valid
      );

  rd_clk <= fco;                        --modulated by the postprocess module
  -----------------------------------------------------------------------------

 data_tt_ps : process (fco, rst_n) is
  begin  -- process data_A_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_a_tt <= (others => '0');
    elsif fco'event and fco = '1' then  -- rising clock edge
      -- data_a <= a_d1_s7&a_d1_s6&a_d1_s5&a_d1_s4&a_d1_s3&a_d1_s2&a_d1_s1&a_d1_s0&a_d0_s7&a_d0_s6&a_d0_s5&a_d0_s4&a_d0_s3&a_d0_s2&a_d0_s1&a_d0_s0;
      -- data_a <=a_d1_s7&a_d1_s0&a_d1_s1&a_d1_s2&a_d1_s3&a_d1_s4&a_d1_s5&a_d1_s6&a_d0_s7&a_d0_s0&a_d0_s1&a_d0_s2&a_d0_s3&a_d0_s4&a_d0_s5&a_d0_s6;
      -- --Series 7
      
      data_a_tt <=a_d0_s7&a_d0_s6&a_d0_s5&a_d0_s4&a_d0_s3&a_d0_s2&a_d0_s1&a_d0_s0; 
      -- ultrascale
    end if;
  end process data_tt_ps;
  
  data_A_ps : process (fco, rst_n) is
  begin  -- process data_A_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      data_a <= (others => '0');
    elsif fco'event and fco = '1' then  -- rising clock edge
      -- data_a <= a_d1_s7&a_d1_s6&a_d1_s5&a_d1_s4&a_d1_s3&a_d1_s2&a_d1_s1&a_d1_s0&a_d0_s7&a_d0_s6&a_d0_s5&a_d0_s4&a_d0_s3&a_d0_s2&a_d0_s1&a_d0_s0;
      -- data_a <=a_d1_s7&a_d1_s0&a_d1_s1&a_d1_s2&a_d1_s3&a_d1_s4&a_d1_s5&a_d1_s6&a_d0_s7&a_d0_s0&a_d0_s1&a_d0_s2&a_d0_s3&a_d0_s4&a_d0_s5&a_d0_s6;
      -- --Series 7
      
      data_a<= a_d1_s5&a_d1_s4&a_d1_s3&a_d1_s2&a_d1_s1&a_d1_s0&a_d1_s7&a_d1_s6&a_d0_s5&a_d0_s4&a_d0_s3&a_d0_s2&a_d0_s1&a_d0_s0&a_d0_s7&a_d0_s6; 
      -- ultrascale
          -- data_a<= a_d1_s5&a_d1_s4&a_d1_s3&a_d1_s2&a_d1_s1&a_d1_s0&a_d1_s7&a_d1_s6&a_d0_s5&a_d0_s4&a_d0_s3&a_d0_s2&a_d0_s1&a_d0_s0&data_a_tt(7)&data_a_tt(6);  
    end if;
  end process data_A_ps;

end Behavioral;
