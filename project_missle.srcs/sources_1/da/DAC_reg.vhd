-------------------------------------------------------------------------------
-- Title      : ZJU_project
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DAC_reg.
-- Author     : Blackie  <blackie@BlackietekiMacBook-Air.local>
-- Company    : 
-- Created    : 2015-04-28
-- Last update: 2015-05-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: my puppy love
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-04-28  1.0      blackie Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
-------------------------------------------------------------------------------

entity DAC_reg is



  port (
    CLK       : in  std_logic;
    Addr_in   : in  std_logic_vector(7 downto 0);
    Addr_en   : in  std_logic;
    Data_in   : in  std_logic_vector(15 downto 0);
    reg_rst_n : in  std_logic;
    reg_rdy   : out  std_logic;
-------------------------------------------------------------------------------
    SCLK      : out std_logic;
    SDIO      : out std_logic;
    SDENB     : out std_logic
    );

end entity DAC_reg;

-------------------------------------------------------------------------------

architecture str of DAC_reg is
  signal Addr_en_reg   : std_logic;
  signal Addr_data_reg : std_logic_vector(7 downto 0)  := x"00";
  signal Data_data_reg : std_logic_vector(15 downto 0) := x"0000";
  signal Reg_Value     : std_logic_vector(23 downto 0) := x"027000";  -- DATA
-------------------------------------------------------------------------------
  signal SCLK_Freq     : integer                       := 29;       -- 分频
  signal SCLK_Cnt      : std_logic_vector(7 downto 0)  := x"00";
  signal CLK_Cnt       : std_logic_vector(7 downto 0)  := x"00";
  signal Wait_Cnt      : std_logic_vector(4 downto 0)  := "00000";  -- wait for generating SDENB
  signal SCLK_Rising   : std_logic;
  signal SDENB_reg     : std_logic;

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------


begin  -- architecture str
  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      Addr_en_reg <= '0';
    elsif rising_edge(CLK) then
      if(SCLK_Rising='1')then
      Addr_en_reg <= Addr_en;
    end if;
  end if;
  end process;
--generate Addr_en_reg


  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      Addr_data_reg <= x"00";
      Data_data_reg <= x"0000";
    elsif rising_edge(CLK) then
      if(Addr_en = '1')and(Addr_en_reg = '0')then
        Addr_data_reg <= Addr_in;
        Data_data_reg <= Data_in;
      else
        Addr_data_reg <= Addr_data_reg;
        Data_data_reg <= Data_data_reg;
      end if;
    end if;
  end process;
--put the data from port to the registor

-----------------------------------------------------------------------------

  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      CLK_Cnt <= x"00";
    elsif rising_edge(CLK) then
      if(CLK_Cnt<=SCLK_Freq)then
			CLK_Cnt <= CLK_Cnt+1;
      else
        CLK_Cnt<=x"00";
    end if;
  end if;
  end process;
--generate CLK_Cnt

  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      SCLK <= '0';
    elsif rising_edge(CLK)then
      if(CLK_Cnt < SCLK_Freq/2)then
        SCLK <= '0';
      else
        SCLK <= '1';
      end if;
    end if;
  end process;
--generate SCLK

  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      SCLK_Rising <= '0';
    elsif rising_edge(CLK) then
      if(CLK_Cnt = ((SCLK_Freq/2)-1))then
        SCLK_Rising <= '1';
      else
        SCLK_Rising <= '0';
      end if;
    end if;
  end process;
--generate SCLK_Rising

  process(CLK, reg_rst_n)
begin
  if(reg_rst_n = '0')then
      Wait_Cnt <= "00000";
  elsif rising_edge(CLK) then
    if(SCLK_Rising = '1')then
      if((Addr_en = '1')and(Addr_en_reg = '0'))then        
        Wait_Cnt <= "00001";    
      else
        if(Wait_Cnt >= "00001")then
          Wait_Cnt <= Wait_Cnt+1;
        end if;
    end if;
    end if;
end if;
end process;

  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      reg_rdy <= '1';
    elsif rising_edge(CLK) then
      if (Wait_Cnt >= 27)then
          reg_rdy <= '1';
      elsif (Wait_Cnt >= 1) then
          reg_rdy <= '0';
      end if;
    end if;
  end process;
  
  process(CLK, reg_rst_n)
  begin
    if(reg_rst_n = '0')then
      SCLK_Cnt <= x"00";
    elsif rising_edge(CLK) then
      if (Wait_Cnt >= 2)and (Wait_Cnt <= 26)then
        if(SCLK_Rising='1')then
          SCLK_Cnt <= SCLK_Cnt+1;
        end if;
      else
          SCLK_Cnt <= x"00";
      end if;
    end if;
  end process;
--generate SCLK_Cnt,syn to SCLK_Rising,count after SDENB, range 01 to .. , represent that the data
--starts to come

  process(CLK, reg_rst_n)begin
    if(reg_rst_n = '0')then
      SDIO <= '0';
    elsif rising_edge(CLK) then
      if(SCLK_Cnt >= 2)and (SCLK_Cnt <= 26)then
        SDIO <= Reg_Value(23);
        SDENB <= '0';
      else
        SDIO <= '0';
        SDENB <= '1';
      end if;
    end if;
  end process;
-- output the Reg_Value to the SDIO

  process(CLK, reg_rst_n)begin
    if(reg_rst_n = '0') then
      Reg_Value <= x"000000";
    elsif rising_edge(CLK)then
      if(Wait_Cnt = 1)then
        Reg_Value <= Addr_data_reg & Data_data_reg;
      else
        if(SCLK_Cnt >= 2)and(SCLK_Cnt <= 26)and(SCLK_Rising = '1')then
          Reg_Value <= Reg_Value(22 downto 0)&'0';
        else
          Reg_Value <= Reg_Value;
        end if;
      end if;
    end if;
  end process;
--data shift












-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------

end architecture str;

-------------------------------------------------------------------------------
