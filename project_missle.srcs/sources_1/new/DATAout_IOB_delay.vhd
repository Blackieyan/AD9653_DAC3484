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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DATAout_IOB is
  generic
    (
      dac_resolution :integer := 16
      );
  port (
    rst_n : in std_logic;
    CLK       : in  std_logic; -- clk 500MHz 0degree
    CLK_div : in std_logic;    --clk 250MHz
    CLK_dly : in std_logic;             --clk 200MHz
    Q_p       : out std_logic_vector(dac_resolution-1 downto 0);
    Q_n       : out std_logic_vector(dac_resolution-1 downto 0);
    frame_p   : out std_logic;
    frame_n   : out std_logic;
    SYNC_p    : out std_logic;
    SYNC_n    : out std_logic;
    DataCLk_p : out std_logic;
    DataCLk_n : out std_logic;
    Data_A    : in  std_logic_vector(dac_resolution-1 downto 0);
    Data_B    : in  std_logic_vector(dac_resolution-1 downto 0);
    Data_C    : in  std_logic_vector(dac_resolution-1 downto 0);
    Data_D    : in  std_logic_vector(dac_resolution-1 downto 0);
    DataCLk   : in  std_logic           -- clk 500MHz 90degree shift
    );
end DATAout_IOB;

architecture Behavioral of DATAout_IOB is
signal delay_locked : std_logic;
signal sync : std_logic;
  signal Frame : std_logic;
signal single_out : std_logic_vector(1 downto 0);
signal single_delay_out : std_logic_vector(1 downto 0);
signal data_A_d2 : std_logic_vector(dac_resolution-1 downto 0);
signal data_B_d2 : std_logic_vector(dac_resolution-1 downto 0);
signal data_C_d2 : std_logic_vector(dac_resolution-1 downto 0);
signal data_D_d2 : std_logic_vector(dac_resolution-1 downto 0);
signal data_A_d : std_logic_vector(dac_resolution-1 downto 0);
signal data_B_d : std_logic_vector(dac_resolution-1 downto 0);
signal data_C_d : std_logic_vector(dac_resolution-1 downto 0);
signal data_D_d : std_logic_vector(dac_resolution-1 downto 0);
signal data_combine : std_logic_vector(dac_resolution*4-1 downto 0);
signal out_delay_tap_in : std_logic_vector(dac_resolution*5-1 downto 0);
signal out_delay_tap_out : std_logic_vector(dac_resolution*5-1 downto 0);

signal Q : std_logic_vector(dac_resolution-1 downto 0);
  -- component ODDR_module
  --   port(
  --     CLK : in  std_logic;
  --     D0   : in  std_logic_vector(dac_resolution-1 downto 0);
  --     D1   : in  std_logic_vector(dac_resolution-1 downto 0);
  --     valid : in std_logic;
  --     Q    : out std_logic_vector(dac_resolution-1 downto 0);
  --     frame : out std_logic;
  --     sync : out std_logic
  --     );
  -- end component;
  component serdes_out
    port(
      rst      : in  std_logic;
      clk      : in  std_logic;
      div_clk  : in  std_logic;
      clk_dly : in std_logic;
      Frame    : out std_logic;
      sync     : out std_logic;
      data_s0  : in  std_logic_vector(dac_resolution-1 downto 0);
      data_s1  : in  std_logic_vector(dac_resolution-1 downto 0);
      data_s2  : in  std_logic_vector(dac_resolution-1 downto 0);
      data_s3  : in  std_logic_vector(dac_resolution-1 downto 0);
      Q_delay_tap : in std_logic_vector(dac_resolution*5-1 downto 0);
      data_out : out std_logic_vector(dac_resolution-1 downto 0)
      );
  end component;      
--      COMPONENT oserdes_core
--        PORT (
--         data_out_to_pins : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--          clk_in : IN STD_LOGIC;
--          clk_div_in : IN STD_LOGIC;
--          data_out_from_device : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
--          io_reset : IN STD_LOGIC;
--          out_delay_reset : IN STD_LOGIC;
--          out_delay_tap_in : IN STD_LOGIC_VECTOR(79 DOWNTO 0);
--          out_delay_tap_out : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
--          out_delay_data_ce : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--          out_delay_data_inc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--          ref_clock : IN STD_LOGIC;
--          delay_locked : OUT STD_LOGIC
--        );
--      END COMPONENT;
      
--     COMPONENT oserdes_single
--        PORT (
--          data_out_to_pins : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--          clk_in : IN STD_LOGIC;
--          clk_div_in : IN STD_LOGIC;
--          data_out_from_device : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--          io_reset : IN STD_LOGIC
--        );
--      END COMPONENT;

  component OBUFDS_module is
    port (
      Q_p       : out std_logic_vector(dac_resolution-1 downto 0);
      Q_n       : out std_logic_vector(dac_resolution-1 downto 0);
      Q         : in  std_logic_vector(dac_resolution-1 downto 0);
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
 data_A_d_ps: process (clk_div) is
 begin  -- process data_A_d
   if clk_div'event and clk_div = '1' then   -- rising clock edge
          data_A_d <= data_A;
     data_B_d <= data_B;
     data_C_d <= data_C;
     data_D_d <= data_D;
     data_A_d2 <= data_A_d;
     data_B_d2 <= data_B_d;
     data_C_d2 <= data_C_d;
     data_D_d2 <= data_D_d;
   end if;
 end process data_A_d_ps;
 data_combine <= data_A_d & data_B_d & data_C_d & data_D_d;

   delay_gen1:
   for l_inst in 0 to 2 generate
   begin
       out_delay_tap_in((l_inst+1)*5-1 downto l_inst*5) <= "01000";
   end generate;
   delay_gen2:
   for l_inst in 8 to 13 generate
   begin
       out_delay_tap_in((l_inst+1)*5-1 downto l_inst*5) <= "01000";
   end generate; 
   delay_gen3:
   for l_inst in 3 to 7 generate
   begin
       out_delay_tap_in((l_inst+1)*5-1 downto l_inst*5) <= "00000";
   end generate;
   delay_gen4:
   for l_inst in 14 to 15 generate
   begin
       out_delay_tap_in((l_inst+1)*5-1 downto l_inst*5) <= "00000";
   end generate;    
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
      clk_dly  => clk_dly,
      data_s0  => data_A_d2,
      data_s1  => data_B_d2,
      data_s2  => data_C_d2,
      data_s3  => data_D_d2,
      Frame    => Frame,
      sync     => sync,
      Q_delay_tap => out_delay_tap_in,
      data_out => Q
      );
--serdes_out_core : oserdes_core
--  PORT MAP (
--    data_out_to_pins => Q,
--    clk_in => clk,
--    clk_div_in => not clk_div,
--    data_out_from_device => data_combine,
--    io_reset => not rst_n,
--    out_delay_reset => not rst_n,
--    out_delay_tap_in => out_delay_tap_in,
--    out_delay_tap_out => out_delay_tap_out,
--    out_delay_data_ce => x"0000",
--    out_delay_data_inc => x"0000",
--    ref_clock => clk_dly,
--    delay_locked => open
--  );
--  Frame <= single_delay_out(0);
--  sync  <= single_delay_out(1);
  
--  serdes_out_sync : oserdes_single
--    PORT MAP (
--      data_out_to_pins => single_out,
--      clk_in => clk,
--      clk_div_in => clk_div,
--      data_out_from_device => x"CC",
--      io_reset => not rst_n
--    );
   
--   delay_gen5:
--   for l_inst in 0 to 1 generate
--   begin 
--     ODELAYE2_inst : ODELAYE2
--      generic map (
--         CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
--         DELAY_SRC => "CLKIN",           -- Delay input (ODATAIN, CLKIN)
--         HIGH_PERFORMANCE_MODE => "TRUE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
--         ODELAY_TYPE => "VAR_LOAD_PIPE",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
--         ODELAY_VALUE => 0,                -- Output delay tap setting (0-31)
--         PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
--         REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
--         SIGNAL_PATTERN => "CLOCK"          -- DATA, CLOCK input signal
--      )
--      port map (
--         CNTVALUEOUT => open, -- 5-bit output: Counter value output
--         DATAOUT => single_delay_out(l_inst),         -- 1-bit output: Delayed data/clock output
--         C => clk_dly,                     -- 1-bit input: Clock input
--         CE => '0',                   -- 1-bit input: Active high enable increment/decrement input
--         CINVCTRL => '0',       -- 1-bit input: Dynamic clock inversion input
--         CLKIN => single_out(l_inst),             -- 1-bit input: Clock delay input
--         CNTVALUEIN => "00000",   -- 5-bit input: Counter value input
--         INC => '0',                 -- 1-bit input: Increment / Decrement tap delay input
--         LD => not rst_n,                   -- 1-bit input: Loads ODELAY_VALUE tap delay in VARIABLE mode, in VAR_LOAD or
--                                     -- VAR_LOAD_PIPE mode, loads the value of CNTVALUEIN
   
--         LDPIPEEN => '0',       -- 1-bit input: Enables the pipeline register to load data
--         ODATAIN => '0',         -- 1-bit input: Output delay data input
--         REGRST => not rst_n            -- 1-bit input: Active-high reset tap-delay input
--      ); 
--   end generate;
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
