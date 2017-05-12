----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:09:37 05/04/2015 
-- Design Name: 
-- Module Name:    DDR_out - Behavioral 
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
library UNISIM;
use IEEE.STD_LOGIC_1164.all;
use UNISIM.vcomponents.all;

-- ODDR2: Output Double Data Rate Output Register with Set, Reset
--        and Clock Enable. 
--        Spartan-6
-- Xilinx HDL Language Template, version 13.3

entity ODDR_module is
  generic(
    ddr_num : integer := 16
    );
  port(
    CLK0  : in  std_logic;
    D0    : in  std_logic_vector(ddr_num-1 downto 0);
    D1    : in  std_logic_vector(ddr_num-1 downto 0);
    Q     : out std_logic_vector(ddr_num-1 downto 0);
    valid : in  std_logic;
    frame : out std_logic;
    sync  : out std_logic
    );
end entity ODDR_module;
-------------------------------------------------------------------------------
architecture Behavioral of ODDR_module is
  signal CE : std_logic;
  signal R  : std_logic;
  signal S  : std_logic;

begin

  CE <= '1';
  R  <= '0';
  S  <= '0';

  gen_ddr : for i in 0 to ddr_num-1 generate

-- ODDR_inst : ODDR
--    generic map(
--       DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
--       INIT => '0',   -- Initial value for Q port ('1' or '0')
--       SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
--    port map (
--       Q => Q(i),   -- 1-bit DDR output
--       C => CLK0,    -- 1-bit clock input
--       CE => CE,  -- 1-bit clock enable input
--       D1 => D0(i),  -- 1-bit data input (positive edge)
--       D2 => D1(i),  -- 1-bit data input (negative edge)
--       R => R,    -- 1-bit reset input
--       S => S     -- 1-bit set input
--    );
    --   ODDR_inst1 : ODDR
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
    ------------------------------------------------------------------------------
    ------------------------------------------------------------------------------
    --for ultrascale 
    ODDRE1_inst0 : ODDRE1               --default samedge for ultrscale series
      generic map (
        IS_C_INVERTED  => '0',          -- Optional inversion for C
        IS_D1_INVERTED => '0',          -- Optional inversion for D1
        IS_D2_INVERTED => '0',          -- Optional inversion for D2
        SRVAL          => '0'  -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
        )
      port map (
        Q  => Q(i),                     -- 1-bit output: Data output to IOB
        C  => CLK0,                     -- 1-bit input: High-speed clock input
        D1 => D0(i),                    -- 1-bit input: Parallel data input 1
        D2 => D1(i),                    -- 1-bit input: Parallel data input 2
        SR => R                         -- 1-bit input: Active High Async Reset
        );
  end generate gen_ddr;



  ODDRE1_inst1 : ODDRE1                 --default samedge for ultrscale series
    generic map (
      IS_C_INVERTED  => '0',            -- Optional inversion for C
      IS_D1_INVERTED => '0',            -- Optional inversion for D1
      IS_D2_INVERTED => '0',            -- Optional inversion for D2
      SRVAL          => '0'  -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
      )
    port map (
      Q  => frame,                      -- 1-bit output: Data output to IOB
      C  => CLK0,                       -- 1-bit input: High-speed clock input
      D1 => valid,                      -- 1-bit input: Parallel data input 1
      D2 => valid,                      -- 1-bit input: Parallel data input 2
      SR => R                           -- 1-bit input: Active High Async Reset
      );

  ODDRE1_inst2 : ODDRE1                 --default samedge for ultrscale series
    generic map (
      IS_C_INVERTED  => '0',            -- Optional inversion for C
      IS_D1_INVERTED => '0',            -- Optional inversion for D1
      IS_D2_INVERTED => '0',            -- Optional inversion for D2
      SRVAL          => '0'  -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
      )
    port map (
      Q  => sync,                       -- 1-bit output: Data output to IOB
      C  => CLK0,                       -- 1-bit input: High-speed clock input
      D1 => valid,                      -- 1-bit input: Parallel data input 1
      D2 => valid,                      -- 1-bit input: Parallel data input 2
      SR => R                           -- 1-bit input: Active High Async Reset
      );
--for the same
end Behavioral;
