----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/07 14:40:50
-- Design Name: 
-- Module Name: AD_DA_project_TB - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AD_DA_project_TB is
--  Port ( );
end AD_DA_project_TB;

architecture Behavioral of AD_DA_project_TB is

component AD_DA_project is
  port (
    user_pushbutton_g : in  std_logic;
    osc_in_p          : in  std_logic;
    osc_in_n          : in  std_logic;
    dco_p             : in  std_logic;
    dco_n             : in  std_logic;
    fco_p             : in  std_logic;
    fco_n             : in  std_logic;
    a_d0_p            : in  std_logic;
    a_d0_n            : in  std_logic;
    a_d1_p            : in  std_logic;
    a_d1_n            : in  std_logic;
    Q_p               : out std_logic_vector(15 downto 0);
    Q_n               : out std_logic_vector(15 downto 0);
    frame_p           : out std_logic;
    frame_n           : out std_logic;
    SYNC_p            : out std_logic;
    SYNC_n            : out std_logic;
    DataCLk_p         : out std_logic;
    DataCLk_n         : out std_logic;
    SDIO              : out std_logic;
    SCLK              : out std_logic;
    SDENB             : out std_logic);
end component AD_DA_project;
  
  --   component OSERDES_CORE is
  --   port (
  --     rst : in std_logic;
  --     serial_data : out std_logic;
  --     serial_clk : in std_logic;
  --     parallel_clk : in std_logic;
  --     parallel_data   : in std_logic_vector(7 downto 0)
  --   );
  -- end component OSERDES_CORE;
  constant OSC_in_period : time := 4 ns;
  constant dco_period : time := 2 ns;
  constant fco_period : time := 8 ns;
  constant clk_1g_period : time := 1 ns;
  signal parallel_data : std_logic_vector(15 downto 0);
  signal a_d0_p : std_logic;
  signal a_d0_n : std_logic;
  signal a_d1_p : std_logic;
  signal a_d1_n : std_logic;
  signal OSC_in_p : std_logic;
  signal OSC_in_n : std_logic;
  -- signal serial_data_0 : std_logic := 0;
  -- signal serial_data_1 : std_logic := 0;
  signal DCO_p : std_logic;
  signal DCO_n : std_logic;
  signal fCO_n : std_logic;
  signal fCO_p : std_logic;
  signal clk_1g : std_logic;
  signal rst_n : std_logic;
  signal user_pushbutton_g : std_logic ;
  signal bitslip : std_logic;
  signal Q_p : std_logic_vector(15 downto 0);
signal Q_n : std_logic_vector(15 downto 0);
signal frame_p : std_logic;
signal frame_n : std_logic;
signal sync_p : std_logic;
signal SYNC_n : std_logic;
signal DataCLk_p : std_logic;
signal DataCLk_n : std_logic;
signal SDIO : std_logic;
signal SCLK : std_logic;
signal SDENB : std_logic;
begin

   -- OSERDES_CORE_inst1 :OSERDES_CORE
   --  port map (
   --    rst => not user_pushbutton_g,
   --    serial_clk => dco_p,
   --    parallel_clk => fco_p,
   --    parallel_data => parallel_data(7 downto 0),
   --    serial_data => a_d0_p(0)
   --  );
   --   OSERDES_CORE_inst2 :OSERDES_CORE
   --     port map (
   --       rst => not user_pushbutton_g,
   --       serial_clk => dco_p,
   --       parallel_clk => fco_p,
   --       parallel_data => parallel_data(15 downto 8),
   --       serial_data => a_d1_p(0)
   --     );
AD_DA_project_1: entity work.AD_DA_project
  port map (
    user_pushbutton_g => user_pushbutton_g,
    osc_in_p          => osc_in_p,
    osc_in_n          => osc_in_n,
    dco_p             => dco_p,
    dco_n             => dco_n,
    fco_p             => fco_p,
    fco_n             => fco_n,
    a_d0_p            => a_d0_p,
    a_d0_n            => a_d0_n,
    a_d1_p            => a_d1_p,
    a_d1_n            => a_d1_n,
    Q_p               => Q_p,
    Q_n               => Q_n,
    frame_p           => frame_p,
    frame_n           => frame_n,
    SYNC_p            => SYNC_p,
    SYNC_n            => SYNC_n,
    DataCLk_p         => DataCLk_p,
    DataCLk_n         => DataCLk_n,
    SDIO              => SDIO,
    SCLK              => SCLK,
    SDENB             => SDENB);

  osc_ps : process
  begin
    OSC_in_p <= '1';
    OSC_in_n <= '0';
    wait for OSC_in_period/2;
    OSC_in_p <= '0';
    OSC_in_n <= '1';
    wait for OSC_in_period/2;
  end process;

   -- serial_data_ps: process (clk_1g, <reset name>) is
   -- begin  -- process serial_data_ps
   --   if clk_1g'event and clk_1g = '1' then  -- rising clock edge
   --     serial_data_d<=serial_data;
   --     serial_data_d2<=serial_data;
   --   end if;
   -- end process serial_data_ps;

  dco_ps : process
  begin
    DCO_p <= '1';
    DCO_n <= '0';
    wait for DCO_period/2;
    DCO_p <= '0';
    DCO_n <= '1';
    wait for DCO_period/2;
  end process;

  fco_ps : process
  begin
    FCO_p <= '0';
    FCO_n <= '1';
    wait for FCO_period/2;
    FCO_p <= '1';
    FCO_n <= '0';
    wait for FCO_period/2;
  end process;

    clk_1g_ps : process
  begin
    clk_1g <= '1';
    wait for clk_1g_period/2;
    clk_1g <= '0';
    wait for clk_1g_period/2;
  end process;
  
  parallel_data_sim: process (fco_p, user_pushbutton_g) is
  begin  -- process a_d0_p_sim
    if user_pushbutton_g = '0' then                 -- asynchronous reset (active low)
      parallel_data <=x"0000";
    elsif fco_p'event and fco_p = '1' then  -- rising clock edge
      parallel_data <= parallel_data+1;
    end if;
  end process parallel_data_sim;
  
 -- a_d0_p_sim: process (clk_1g, user_pushbutton_g) is
 -- begin  -- process a_d0_p_sim
 --   if user_pushbutton_g = '0' then                 -- asynchronous reset (active low)
 --     a_d0_p <="0";
 --   elsif clk_1g'event and clk_1g = '1' then  -- rising clock edge
 --     a_d0_p <=a_d0_p+1;
 --   end if;
 -- end process a_d0_p_sim;  
a_d0_n <= not a_d0_p;
  
 --   a_d1_p_sim: process (clk_1g, user_pushbutton_g) is
 -- begin  -- process a_d0_p_sim
 --   if user_pushbutton_g = '0' then                 -- asynchronous reset (active low)
 --     a_d1_p <="0";
 --   elsif clk_1g'event and clk_1g = '1' then  -- rising clock edge
 --     a_d1_p <=a_d1_p+1;
 --   end if;
 -- end process a_d1_p_sim;
a_d1_n <= not a_d1_p;
  
  stim_proc : process
    begin
      bitslip <='0';
      user_pushbutton_g <= '1';
      wait for clk_1g_period*500;
      user_pushbutton_g<='1';
      wait for clk_1g_period*500;
      user_pushbutton_g<='0';
      
      wait for clk_1g_period*1000;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';

      wait for clk_1g_period*100;
      bitslip<='1';
      wait for clk_1g_period*8 ;
      bitslip <='0';
      wait;
    end process;
      
end Behavioral;
