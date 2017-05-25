----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/23 21:22:25
-- Design Name: 
-- Module Name: iserdes - Behavioral
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

entity iserdes is
  generic(
    PARALLEL_WIDTH : integer := 8
    );
  port (
    rst          : in  std_logic;
    clk          : in  std_logic;
    -- clkB : in std_logic;
    div_clk      : in  std_logic;
    -- up_clk : in std_logic;
    -- up_dld : in std_logic;
    -- up_dwdata : in std_logic_vector(9 downto 0);
    data_in0_p   : in  std_logic;
    data_in0_n   : in  std_logic;
    data_in1_p   : in  std_logic;
    data_in1_n   : in  std_logic;
    BITSLIP_low  : in  std_logic;
    BITSLIP_high : in  std_logic;
    data_combine : out std_logic_vector(15 downto 0)
    );
end iserdes;

architecture Behavioral of iserdes is
  signal data_in : std_logic_vector(1 downto 0);
  signal BITSLIP : std_logic_vector(1 downto 0);
  signal SHIFTIN1 : std_logic_vector(1 downto 0);
  signal SHIFTIN2 : std_logic_vector(1 downto 0);
begin
BITSLIP(0)<=  BITSLIP_low;
BITSLIP(1)<=BITSLIP_high ;

  IBUFDS_inst0 : IBUFDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination 
      IBUF_LOW_PWR => false,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => data_in(0),                 -- Buffer output
      I  => data_in0_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => data_in0_n  -- Diff_n buffer input (connect directly to top-level port)
      );

  IBUFDS_inst1 : IBUFDS
    generic map (
      DIFF_TERM    => true,             -- Differential Termination 
      IBUF_LOW_PWR => false,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => data_in(1),                 -- Buffer output
      I  => data_in1_p,  -- Diff_p buffer input (connect directly to top-level port)
      IB => data_in1_n  -- Diff_n buffer input (connect directly to top-level port)
      );

  channel_iserdes_inst : for i in 0 to 1 generate
  begin
    -- IDELAYE2_inst : IDELAYE2
    --  generic map (
    --     CINVCTRL_SEL => "FALSE",          -- Enable dynamic clock inversion (FALSE, TRUE)
    --     DELAY_SRC => "IDATAIN",           -- Delay input (IDATAIN, DATAIN)
    --     HIGH_PERFORMANCE_MODE => "FALSE", -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
    --     IDELAY_TYPE => "VAR_LOAD",           -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    --     IDELAY_VALUE => 0,                -- Input delay tap setting (0-31)
    --     PIPE_SEL => "FALSE",              -- Select pipelined mode, FALSE, TRUE
    --     REFCLK_FREQUENCY => 200.0,        -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    --     SIGNAL_PATTERN => "DATA"          -- DATA, CLOCK input signal
    --  )
    --  port map (
    --     CNTVALUEOUT =>up_drdata(i), -- 5-bit output: Counter value output
    --     DATAOUT => data_in_idelay_s(i),         -- 1-bit output: Delayed data output
    --     C => up_clk,                     -- 1-bit input: Clock input
    --     CE => '0',                   -- 1-bit input: Active high enable increment/decrement input
    --     CINVCTRL => '0',       -- 1-bit input: Dynamic clock inversion input
    --     CNTVALUEIN => up_dwdata(i*5+4 downto i*5),   -- 5-bit input: Counter value input
    --     DATAIN => '0',           -- 1-bit input: Internal delay data input
    --     IDATAIN => data_in_ibuf_s(i),         -- 1-bit input: Data input from the I/O
    --     INC => '0',                 -- 1-bit input: Increment / Decrement tap delay input
    --     LD => up_dld,                   -- 1-bit input: Load IDELAY_VALUE input
    --     LDPIPEEN => '0',       -- 1-bit input: Enable PIPELINE register to load data input
    --     REGRST => '0'            -- 1-bit input: Active-high reset tap-delay input
    --  );

    ISERDESE2_inst : ISERDESE2
      generic map (
        DATA_RATE         => "DDR",     -- DDR, SDR
        DATA_WIDTH        => PARALLEL_WIDTH,  -- Parallel data width (2-8,10,14)
        DYN_CLKDIV_INV_EN => "FALSE",  -- Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
        DYN_CLK_INV_EN    => "FALSE",  -- Enable DYNCLKINVSEL inversion (FALSE, TRUE)
        -- INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
        INIT_Q1           => '0',
        INIT_Q2           => '0',
        INIT_Q3           => '0',
        INIT_Q4           => '0',
        INTERFACE_TYPE    => "NETWORKING",  -- MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
        IOBDELAY          => "none",     -- NONE, BOTH, IBUF, IFD
        NUM_CE            => 2,         -- Number of clock enables (1,2)
        OFB_USED          => "FALSE",   -- Select OFB path (FALSE, TRUE)
        SERDES_MODE       => "MASTER",  -- MASTER, SLAVE
        -- SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
        SRVAL_Q1          => '0',
        SRVAL_Q2          => '0',
        SRVAL_Q3          => '0',
        SRVAL_Q4          => '0'
        )
      port map (
        O         => open,                 -- 1-bit output: Combinatorial output
        -- Q1 - Q8: 1-bit (each) output: Registered data outputs
        Q1        => data_combine(8*i+0),
        Q2        => data_combine(8*i+1),
        Q3        => data_combine(8*i+2),
        Q4        => data_combine(8*i+3),
        Q5        => data_combine(8*i+4),
        Q6        => data_combine(8*i+5),
        Q7        => data_combine(8*i+6),
        Q8        => data_combine(8*i+7),
        -- SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        BITSLIP   => BITSLIP(i),  -- 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
        -- CLKDIV when asserted (active High). Subsequently, the data seen on the
        -- Q1 to Q8 output ports will shift, as in a barrel-shifter operation, one
        -- position every time Bitslip is invoked (DDR operation is different from
        -- SDR).

        -- CE1, CE2: 1-bit (each) input: Data register clock enable inputs
        CE1          => '1',
        CE2          => '1',
        CLKDIVP      => div_clk,        -- 1-bit input: TBD
        -- Clocks: 1-bit (each) input: ISERDESE2 clock input ports
        CLK          => CLK,            -- 1-bit input: High-speed clock
        CLKB         => not clk,  -- 1-bit input: High-speed secondary clock
        CLKDIV       => div_clk,        -- 1-bit input: Divided clock
        OCLK         => '0',  -- 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
        -- Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
        DYNCLKDIVSEL => '0',  -- 1-bit input: Dynamic CLKDIV inversion
        DYNCLKSEL    => '0',  -- 1-bit input: Dynamic CLK/CLKB inversion
        -- Input Data: 1-bit (each) input: ISERDESE2 data input ports
        D            => data_in(i),            -- 1-bit input: Data input
        DDLY         => '0',  -- 1-bit input: Serial data from IDELAYE2
        OFB          => '0',  -- 1-bit input: Data feedback from OSERDESE2
        OCLKB        => '0',  -- 1-bit input: High speed negative edge output clock
        RST          => RST,  -- 1-bit input: Active high asynchronous reset
        -- SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
        SHIFTIN1     => SHIFTIN1(i),
        SHIFTIN2     => SHIFTIN2(i)
        );

  end generate;

end Behavioral;
