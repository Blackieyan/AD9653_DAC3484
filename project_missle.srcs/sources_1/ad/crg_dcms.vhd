----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:21:17 12/08/2016 
-- Design Name: 
-- Module Name:    crg_dcms - Behavioral 
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity crg_dcms is
  port(
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
    CLK_250M          : out std_logic
    );
end crg_dcms;

architecture Behavioral of crg_dcms is

  constant dco_delay_tap : std_logic_vector(4 downto 0) := "00000";
  signal dcm1_locked_d   : std_logic;
  signal dcm1_locked_d2  : std_logic;
  signal dcm1_locked     : std_logic;
  signal clk1            : std_logic;
  signal clk2            : std_logic;
  signal clk3            : std_logic;
  signal clk4            : std_logic;
  signal dco_idelay      : std_logic;
  signal dco_ibuf        : std_logic;
  signal rst_int         : std_logic;

  attribute IODELAY_GROUP                      : string;
  attribute IODELAY_GROUP of dco_IDELAYE2_inst : label is "ADC_IDELAY_GROUP";

  component clk_wiz_0
    port
      (                                 -- Clock in ports
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic;
        -- Clock out ports
        clk_out1  : out std_logic;
        clk_out2  : out std_logic
        );
  end component;

  component clk_wiz_1
    port
      (                                 -- Clock in ports
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic;
        -- Clock out ports
        clk_out1  : out std_logic;
        clk_out2  : out std_logic;
        clk_out3  : out std_logic;
        clk_out4  : out std_logic;
        -- Status and control signals
        locked    : out std_logic
        );
  end component;

  component clk_wiz_2
    port
      (                                 -- Clock in ports
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic;
        -- Clock out ports
        clk_out1  : out std_logic
        );
  end component;
-------------------------------------------------------------------------------
begin

  CLK_200M      <= CLK2;
  CLK_250M      <= CLK1;
  CLK_500M      <= clk3;
  CLK_500M_quar <= clk4;

-- dcm_dco : clk_wiz_0
--    port map ( 
--    -- Clock in ports
--    clk_in1_p => dco_p,
--    clk_in1_n => dco_n,
--   -- Clock out ports  
--    clk_out1 => dco,
--    clk_out2 => dco_div              
--  );

  -----------------------------------------------------------------------------
  IBUFDS_inst : IBUFDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination 
      IBUF_LOW_PWR => false,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => dco_ibuf,                   -- Buffer output
      I  => dco_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => dco_n   -- Diff_n buffer input (connect directly to top-level port)
      );

  dco_IDELAYE2_inst : IDELAYE2
    generic map (
      CINVCTRL_SEL          => "FALSE",  -- Enable dynamic clock inversion (FALSE, TRUE)
      DELAY_SRC             => "IDATAIN",   -- Delay input (IDATAIN, DATAIN)
      HIGH_PERFORMANCE_MODE => "FALSE",  -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
      IDELAY_TYPE           => "VAR_LOAD",  -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      IDELAY_VALUE          => 0,       -- Input delay tap setting (0-31)
      PIPE_SEL              => "FALSE",  -- Select pipelined mode, FALSE, TRUE
      REFCLK_FREQUENCY      => 200.0,  -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      SIGNAL_PATTERN        => "DATA"   -- DATA, CLOCK input signal
      )
    port map (
      CNTVALUEOUT => open,              -- 5-bit output: Counter value output
      DATAOUT     => dco_idelay,        -- 1-bit output: Delayed data output
      C           => CLK1,              -- 1-bit input: Clock input
      CE          => '0',  -- 1-bit input: Active high enable increment/decrement input
      CINVCTRL    => '0',  -- 1-bit input: Dynamic clock inversion input
      CNTVALUEIN  => dco_delay_tap,     -- 5-bit input: Counter value input
      DATAIN      => '0',  -- 1-bit input: Internal delay data input
      IDATAIN     => dco_ibuf,          -- 1-bit input: Data input from the I/O
      INC         => '0',  -- 1-bit input: Increment / Decrement tap delay input
      LD          => '1',               -- 1-bit input: Load IDELAY_VALUE input
      LDPIPEEN    => '0',  -- 1-bit input: Enable PIPELINE register to load data input
      REGRST      => rst_int  -- 1-bit input: Active-high reset tap-delay input
      );

  BUFR_inst : BUFR
    generic map (
      BUFR_DIVIDE => "4",       -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      SIM_DEVICE  => "7SERIES"          -- Must be set to "7SERIES" 
      )
    port map (
      O   => dco_div,                   -- 1-bit output: Clock output port
      CE  => '1',  -- 1-bit input: Active high, clock enable (Divided modes only)
      CLR => '0',  -- 1-bit input: Active high, asynchronous clear (Divided modes only)
      I   => dco_idelay  -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
      );

  BUFIO_inst : BUFIO
    port map (
      O => dco,  -- 1-bit output: Clock output (connect to I/O clock loads).
      I => dco_idelay  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
      );


  IDELAYCTRL_inst : IDELAYCTRL
    port map (
      RDY    => open,                   -- 1-bit output: Ready output
      REFCLK => CLK2,                   -- 1-bit input: Reference clock input
      RST    => rst_int                 -- 1-bit input: Active high reset input
      );
-------------------------------------------------------------------------------
  dcm_global : clk_wiz_1
    port map (

      -- Clock in ports
      clk_in1_p => OSC_in_p,
      clk_in1_n => OSC_in_n,
      -- Clock out ports  
      clk_out1  => CLK1,
      clk_out2  => CLK2,
      clk_out3  => clk3,                --500MHz
      clk_out4  => clk4,                --500MHz 90degree
      -- Status and control signals                
      locked    => dcm1_locked
      );

  dcm_fco : clk_wiz_2
    port map (

      -- Clock in ports
      clk_in1_p => fco_p,
      clk_in1_n => fco_n,
      -- Clock out ports  
      clk_out1  => fco
      );

  dcm1_locked_d_ps : process (CLK1) is
  begin  -- process dcm1_locked_d_ps
    if CLK1'event and CLK1 = '1' then   -- rising clock edge
      dcm1_locked_d  <= dcm1_locked;
      dcm1_locked_d2 <= dcm1_locked_d;
    end if;
  end process dcm1_locked_d_ps;

  -- lck_rst_n <= not rst_int;
  lck_rst_n_ps : process (CLK1, user_pushbutton_g) is
  begin  -- process reset_n_ps
    if user_pushbutton_g = '1' then       -- asynchronous reset (active low)
      rst_int   <= '1';
      lck_rst_n <= '0';
    elsif CLK1'event and CLK1 = '1' then  -- rising clock edge
      if dcm1_locked_d = '1' and dcm1_locked_d2 = '0' then
        rst_int   <= '1';
        lck_rst_n <= '0';
      else
        rst_int   <= '0';
        lck_rst_n <= '1';
      end if;
    end if;
  end process lck_rst_n_ps;

end Behavioral;

