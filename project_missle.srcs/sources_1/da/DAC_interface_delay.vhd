-------------------------------------------------------------------------------
-- Title      : ZJUproject
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DAC_interface.vhd
-- Author     :   <Blackie@BLACKIE-PC>
-- Company    : 
-- Created    : 2015-05-07
-- Last update: 2017-05-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-05-07  1.0      Blackie Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.vcomponents.all;

-------------------------------------------------------------------------------

entity DAC_interface is



  port (
    rst_n     : in  std_logic;
    CLK       : in  std_logic;          -- clk 500MHz 0degree
    CLK_div   : in  std_logic;          --clk 250MHz
    clk_dly : in std_logic;             --clk 200MHz
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
end entity DAC_interface;

-------------------------------------------------------------------------------

architecture str of DAC_interface is
  signal Data_en      : std_logic;
  signal Data_A_inter : std_logic_vector(15 downto 0) := x"0000";
  signal Data_B_inter : std_logic_vector(15 downto 0) := x"1111";
  signal Data_C_inter : std_logic_vector(15 downto 0) := x"2222";
  signal data_D_inter : std_logic_vector(15 downto 0) := x"3333";
  -- signal rst_n              : std_logic;
  signal rom_addr_cnt : std_logic_vector(9 downto 0) := "0000000000";
  signal rom_dout     : std_logic_vector(15 downto 0);

  component rom
    port (
      clka  : in  std_logic;
      rsta  : in  std_logic;
      ena   : in  std_logic;
      addra : in  std_logic_vector(9 downto 0);
      douta : out std_logic_vector(15 downto 0)
      );
  end component;

  component DATAout_IOB is
    port (
      rst_n     : in  std_logic;
      CLK       : in  std_logic;
      CLK_div   : in  std_logic;
      clk_dly : in std_logic;
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
      DataCLk   : in  std_logic);
  end component DATAout_IOB;

begin  -- architecture str

  DATAout_IOB_1 : DATAout_IOB
    port map (
      rst_n     => rst_n,
      CLK       => CLK,
      CLK_div   => CLK_div,
       CLK_dly => clk_dly,
      Q_p       => Q_p,
      Q_n       => Q_n,
      frame_p   => frame_p,
      frame_n   => frame_n,
      SYNC_p    => SYNC_p,
      SYNC_n    => SYNC_n,
      DataCLk_p => DataCLk_p,
      DataCLk_n => DataCLk_n,
      Data_A    => Data_A_inter,
      Data_B    => Data_B_inter,
      Data_C    => Data_C_inter,
      Data_D    => Data_D_inter,
      DataCLk   => DataCLk);
-----------------------------------------------------------------------------
  --generate dac data for sim  line below
  Data_en <= '1';

  Inst_rom : rom
             port map (
               clka  => clk_div,
               rsta  => not rst_n,
               ena   => Data_en,
               addra => rom_addr_cnt,
               douta => rom_dout
               );

  main_counter_ps : process (clk_div, rst_n) is
  begin  -- process main_counter_ps
    if clk_div'event and clk_div = '1' then  -- rising clock edge
      rom_addr_cnt <= rom_addr_cnt + 1;
    end if;
  end process;


  Data_A_cnt_ps : process (clk_div, rst_n) is
  begin  -- process Data_A_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Data_A_inter <= x"0000";
    elsif clk_div'event and clk_div = '1' then  -- rising clock edge
      if data_en = '1' then
        Data_A_inter <= rom_dout;
      --   Data_A<=x"ffff";
      end if;
    end if;
  end process Data_A_cnt_ps;

  Data_B_cnt_ps : process (clk_div, rst_n) is
  begin  -- process Data_B_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Data_B_inter <= (others => '0');
      Data_C_inter <= (others => '0');
      Data_D_inter <= (others => '0');
    elsif clk_div'event and clk_div = '1' then  -- rising clock edge
      if data_en = '1' then
        -- Data_B_inter <= (Data_B_inter(15 downto 8)+1)&x"00";
        -- Data_C_inter <= (Data_C_inter(15 downto 8)+2)&x"00";
        -- Data_D_inter <= (Data_D_inter(15 downto 8)+4)&x"00";
        
        Data_B_inter <=(others => '0');
        Data_C_inter <=(others => '0');
        Data_D_inter <=(others => '0');
      -- Data_B <= ram_dout;
      end if;
    end if;
  end process Data_B_cnt_ps;
----------------------------------------------------------
end str;


