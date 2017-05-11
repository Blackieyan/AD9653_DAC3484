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
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity crg_dcms is
  port(
    OSC_in_p: in std_logic;
    OSC_in_n: in std_logic;
    fco_p : in std_logic;
    fco_n : in std_logic;
    dco_p : in std_logic;
    dco_n : in std_logic;
    dco_div : out std_logic;
    dco : out std_logic;
    fco : out std_logic;
    lck_rst_n : out std_logic;
    user_pushbutton_g : in std_logic;
    CLK_200M : out std_logic;
    CLK_250M : out std_logic
    );
end crg_dcms;

architecture Behavioral of crg_dcms is
  signal dcm1_locked_d : std_logic;
  signal dcm1_locked_d2 : std_logic;
  signal dcm1_locked : std_logic;
  signal clk1 : std_logic;
  signal clk2 : std_logic;


  
component clk_wiz_0
port
 (-- Clock in ports
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic
 );
end component;

component clk_wiz_1
port
 (-- Clock in ports
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  -- Status and control signals
  locked            : out    std_logic
 );
end component;

component clk_wiz_2
port
 (-- Clock in ports
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic;
  -- Clock out ports
  clk_out1          : out    std_logic
 );
end component;
-------------------------------------------------------------------------------
begin
  
  CLK_200M<=CLK2;
  CLK_250M<=CLK1;
  
dcm_dco : clk_wiz_0
   port map ( 
   -- Clock in ports
   clk_in1_p => dco_p,
   clk_in1_n => dco_n,
  -- Clock out ports  
   clk_out1 => dco,
   clk_out2 => dco_div              
 );

dcm_global : clk_wiz_1
   port map ( 

   -- Clock in ports
   clk_in1_p => OSC_in_p,
   clk_in1_n => OSC_in_n,
  -- Clock out ports  
   clk_out1 => CLK1,
   clk_out2 => CLK2,
  -- Status and control signals                
   locked => dcm1_locked            
 );

  dcm_fco : clk_wiz_2
   port map ( 

   -- Clock in ports
   clk_in1_p => fco_p,
   clk_in1_n => fco_n,
  -- Clock out ports  
   clk_out1 => fco              
 );
  
  dcm1_locked_d_ps : process (CLK1) is
  begin  -- process dcm1_locked_d_ps
    if CLK1'event and CLK1 = '1' then  -- rising clock edge
      dcm1_locked_d  <= dcm1_locked;
      dcm1_locked_d2 <= dcm1_locked_d;
    end if;
  end process dcm1_locked_d_ps;

  lck_rst_n_ps : process (CLK1, user_pushbutton_g) is
  begin  -- process reset_n_ps
    if user_pushbutton_g = '0' then     -- asynchronous reset (active low)
      lck_rst_n <= '1';
    elsif CLK1'event and CLK1 = '1' then  -- rising clock edge
        if dcm1_locked_d = '1' and dcm1_locked_d2 = '0' then
          lck_rst_n <= '0';
        else
          lck_rst_n <= '1';
        end if;
      end if;
  end process lck_rst_n_ps;

end Behavioral;

