----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/05/12 00:58:11
-- Design Name: 
-- Module Name: OBUFDS_module - Behavioral
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity OBUFDS_module is
 Port (
   Q_p : out std_logic_vector(15 downto 0);
   Q_n : out std_logic_vector(15 downto 0);
   Q : in std_logic_vector(15 downto 0);
   frame_p : out std_logic;
   frame_n : out std_logic;
   frame : in std_logic;
   SYNC_p : out std_logic;
   SYNC_n : out std_logic;
   sync : in std_logic;
   DataCLk_p : out std_logic;
   DataCLk_n : out std_logic;
   DataCLk : in std_logic
 );
end OBUFDS_module;

architecture Behavioral of OBUFDS_module is

begin
  


  gen_Q : for i in 0 to 15 generate

    OBUFDS_inst1 : OBUFDS
      generic map (
        IOSTANDARD => "DEFAULT")
      port map (
        O  => Q_p(i),  -- Diff_p output (connect directly to top-level port)
        OB => Q_n(i),  -- Diff_n output (connect directly to top-level port)
        I  => Q(i)                      -- Buffer input 
        );
  end generate gen_Q;


  OBUFDS_inst2 : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O  => Frame_p,  -- Diff_p output (connect directly to top-level port)
      OB => Frame_n,  -- Diff_n output (connect directly to top-level port)
      I  => Frame                       -- Buffer input 
      );

  OBUFDS_inst3 : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O  => SYNC_p,  -- Diff_p output (connect directly to top-level port)
      OB => SYNC_n,  -- Diff_n output (connect directly to top-level port)
      I  => SYNC                        -- Buffer input 
      );

  OBUFDS_inst4 : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O  => DataCLk_p,  -- Diff_p output (connect directly to top-level port)
      OB => DataCLk_n,  -- Diff_n output (connect directly to top-level port)
      I  => DataCLk                     -- Buffer input 
      );

  -- OBUFDS_inst5 : OBUFDS
  --   generic map (
  --     IOSTANDARD => "DEFAULT")
  --   port map (
  --     O  => clk500M_p,  -- Diff_p output (connect directly to top-level port)
  --     OB => clk500M_n,  -- Diff_n output (connect directly to top-level port)
  --     I  => clk500M                     -- Buffer input 
  --     );

end Behavioral;
