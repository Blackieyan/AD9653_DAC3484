-------------------------------------------------------------------------------
-- Title      : ZJUproject
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DAC_interface.vhd
-- Author     :   <Blackie@BLACKIE-PC>
-- Company    : 
-- Created    : 2015-05-07
-- Last update: 2017-05-09
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
    -- Data_en   : in  std_logic;
    -- Data_A    : in  std_logic_vector(15 downto 0);
    -- Data_B    : in  std_logic_vector(15 downto 0);
    -- Data_C    : in  std_logic_vector(15 downto 0);
    -- data_D    : in  std_logic_vector(15 downto 0);
--    rst_n     : in  std_logic;
    Gb_CLK_p  : in  std_logic;
    Gb_CLK_n  : in  std_logic;
    DataCLk_p : out std_logic;
    DataCLk_n : out std_logic;
    clk500M_p : out std_logic;
    clk500M_n : out std_logic;
    Frame_p   : out std_logic;
    Frame_n   : out std_logic;
    Q_p       : out std_logic_vector(15 downto 0);
    Q_n       : out std_logic_vector(15 downto 0);
	 data500M_p : out std_logic_vector(7 downto 0);
	 data500M_n : out std_logic_vector(7 downto 0);
    SYNC_p    : out std_logic;
    SYNC_n    : out std_logic;
    LED_out   : out std_logic_vector(7 downto 0);
   ---------------------------------------------------------------------------
--    reg_en    : in  std_logic;
--    reg_Addr  : in  std_logic_vector(7 downto 0);
--    reg_data  : in  std_logic_vector(15 downto 0);
   -- reg_rst_n : in  std_logic;
    SCLK    : out std_logic;
    SDIO    : out std_logic;
    SDENB   : out std_logic
    );

end entity DAC_interface;

-------------------------------------------------------------------------------

architecture str of DAC_interface is
  type state is (zero, one, two);
  signal pr_state, nx_state : state;
  signal Data_en            : std_logic;
  signal Data_A             : std_logic_vector(15 downto 0) := x"0000";
  signal Data_B             : std_logic_vector(15 downto 0) := x"1111";
  signal Data_C             : std_logic_vector(15 downto 0) := x"2222";
  signal data_D             : std_logic_vector(15 downto 0) := x"3333";
  signal Gb_cnt             : std_logic_vector(23 downto 0) := x"000000";
  signal CLK3_250m          : std_logic;
  signal CLK5_500m          : std_logic;
  signal rst                : std_logic;
  signal Gb_CLK             : std_logic;
  signal rst_n              : std_logic;
  signal SYNC               : std_logic;
   signal reg_en    : std_logic := '0';
   signal reg_Addr  : std_logic_vector(7 downto 0)  := x"02";
   signal reg_data  : std_logic_vector(15 downto 0) := x"F000";
   signal reg_rdy   : std_logic;
   signal reg_rdy_reg   : std_logic;
  -- signal CLK       : std_logic;
  signal Q                  : std_logic_vector(15 downto 0);
  signal Frame              : std_logic;
  signal clk500M             : std_logic;
  signal data500M :std_logic_vector(7 downto 0);
 
  signal LED_out_sig        : std_logic_vector(7 downto 0)  := x"00";
  signal Div_cnt_1ms        : std_logic_vector(19 downto 0);
  signal Div_cnt_400ms      : std_logic_vector(8 downto 0);
  constant Div_multi          : integer  := 250000;--for LED
  signal reach_1ms      	 : std_logic;
  signal reach_400ms      	 : std_logic;
  signal data_a_high9       : std_logic_vector(8 downto 0);
  signal DataCLk            : std_logic;
  signal ram_dout           : std_logic_vector(15 downto 0);
  signal ram_din            : std_logic_vector(15 downto 0);
  signal wea                : std_logic_vector(0 downto 0);
  signal wea_d : std_logic_vector(0 downto 0);
  signal ram_addr_cnt       : std_logic_vector(9 downto 0);
  signal rom_addr_cnt 		 : std_logic_vector(9 downto 0);
  signal rom_dout 			 : std_logic_vector(15 downto 0);
  
  component DDR_TRI
    port(
      Data_en : in std_logic;
      Data_A  : in std_logic_vector(15 downto 0);
      Data_B  : in std_logic_vector(15 downto 0);
      Data_C  : in std_logic_vector(15 downto 0);


      data_D        : in  std_logic_vector(15 downto 0);
      rst           : in  std_logic;
      CLK           : in  std_logic;
     -- CLKn            : in  std_logic;
      DataCLk       : out std_logic;
      Frame         : out std_logic;
      Q             : out std_logic_vector(15 downto 0);
      SYNC          : out std_logic;
      CLK3_250m_out : out std_logic;
      CLK5_500m_out : out std_logic
      );
  end component;

   component DAC_reg
     port(
       CLK       : in  std_logic;
       Addr_in   : in  std_logic_vector(7 downto 0);
       Addr_en   : in  std_logic;
       Data_in   : in  std_logic_vector(15 downto 0);
       reg_rst_n : in  std_logic;
       reg_rdy   : out  std_logic;
       SCLK      : out std_logic;
       SDIO      : out std_logic;
       SDENB     : out std_logic
       );
   end component;

COMPONENT rom
  PORT (
    clka : IN STD_LOGIC;
    rsta : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

begin  -- architecture str

  IBUFGDS_inst : IBUFGDS
    generic map (
      IBUF_LOW_PWR => true,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "DEFAULT")
    port map (
      O  => Gb_CLK,                     -- Clock buffer output
      I  => Gb_CLK_p,                   -- Diff_p clock buffer input
      IB => Gb_CLK_n                    -- Diff_n clock buffer input
      );
    
  
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
  
  gen_data500M : for i in 0 to 7 generate

    OBUFDS_inst6 : OBUFDS
      generic map (
        IOSTANDARD => "DEFAULT")
      port map (
        O  => data500M_p(i),  -- Diff_p output (connect directly to top-level port)
        OB => data500M_n(i),  -- Diff_n output (connect directly to top-level port)
        I  => data500M(i)                      -- Buffer input 
        );
  end generate gen_data500M;
  
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

  OBUFDS_inst5 : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT")
    port map (
      O  => clk500M_p,  -- Diff_p output (connect directly to top-level port)
      OB => clk500M_n,  -- Diff_n output (connect directly to top-level port)
      I  => clk500M                     -- Buffer input 
      );


  Inst_DDR_TRI : DDR_TRI port map(
    Data_en       => Data_en,
    Data_A        => Data_A,
    Data_B        => Data_B,
    Data_C        => Data_C,
    data_D        => data_D,
    rst           => rst,
    CLK           => Gb_CLK,
   -- CLK           => Gb_CLK_p,
   -- CLKn           => Gb_CLK_n,
    DataCLk       => DataCLk,
    Frame         => Frame,
    Q             => Q,
    SYNC          => SYNC,
    CLK3_250m_out => CLK3_250m,
    CLK5_500m_out => CLK5_500m
    );

  Inst_rom : rom
  PORT MAP (
    clka =>CLK3_250m,
    rsta => rst,
    ena => Data_en,
    addra => rom_addr_cnt,
    douta => rom_dout
  );
  
   Inst_DAC_reg : DAC_reg port map(
     CLK       => CLK3_250m,
     Addr_in   => reg_Addr,
     Addr_en   => reg_en,
     Data_in   => reg_Data,
     reg_rdy   => reg_rdy,
     reg_rst_n => rst,
     SCLK      => SCLK,
     SDIO      => SDIO,
     SDENB     => SDENB
     );

  rst <= not rst_n;
  clk500M <= DataCLk;

  rom_cnt_ps : process(CLK3_250m, rst_n) is
  begin
    if rst_n = '0' then
      rom_addr_cnt <="0000000000";
    elsif CLK3_250m'event and CLK3_250m = '1' then
      if data_en ='1' then
        rom_addr_cnt <= rom_addr_cnt + 1;
      else
        rom_addr_cnt <= rom_addr_cnt;
      end if;
    end if;
  end process;

  main_counter_ps : process (CLK3_250m, rst_n) is
  begin  -- process main_counter_ps
	 if CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
      Gb_cnt <= Gb_cnt + 1;
    end if;
  end process;
  spi_ps : process (CLK3_250m, rst_n) is
  begin  -- process main_counter_ps
	 if CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
        reg_rdy_reg <= reg_rdy;
        if(reg_rdy_reg = '0' and reg_rdy = '1') then
            reg_en  <= '1';
            reg_Addr <= reg_Addr + 1;
            reg_Data <= reg_Data + 2;
        else
            reg_en  <= '0';
        end if;
    end if;
  end process;
-- purpose: initialize the rst_n
-- type   : sequential
-- inputs : CLK, reg_rst_n
  rst_n_pro : process (CLK3_250m, rst_n) is
  begin
    if CLK3_250m'event and CLK3_250m = '1' then
      if Gb_cnt >= 100 and Gb_cnt <= 150 then
        rst_n <= '0';
      else
        rst_n <= '1';
      end if;
    end if;
  end process rst_n_pro;


  data_en_ps : process (CLK3_250m, rst_n) is
  begin
    if CLK3_250m'event and CLK3_250m = '1' then
      if rst_n = '0' then
        data_en <= '0';
      elsif Gb_cnt >= 200 then
        data_en <= '1';
      else
        data_en <= '0';
      end if;
    end if;
  end process;

  Data_A_cnt_ps : process (CLK3_250m, rst_n) is
  begin  -- process Data_A_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Data_A <= x"0000";
    elsif CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
      if data_en = '1' then
        Data_A <= rom_dout;
   --   Data_A<=x"ffff";
      end if;
    end if;
  end process Data_A_cnt_ps;

  Data_B_cnt_ps : process (CLK3_250m, rst_n) is
  begin  -- process Data_B_cnt_ps
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Data_B <= x"1111";
    elsif CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
      if data_en = '1' then
         Data_B <= (Data_B(15 downto 8)-1)&x"00";
       -- Data_B <= ram_dout;
      end if;
    end if;
  end process Data_B_cnt_ps;
	----------------------------------------------------------
	data500M_cnt_ps : process(CLK5_500m, rst_n) is
		begin
		if rst_n = '0' then
			data500M <= x"00";
		elsif CLK5_500m'event and CLK5_500m = '1' then
			if data_en ='1' then
			data500M <= data500M + 1;
			end if;
		end if;
	end process;
	------------------------------------------
  --generate 1ms signal
  count_1ms_ps : process (CLK3_250m, rst_n) is
  begin  -- 
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Div_cnt_1ms <= x"00000";
		reach_1ms	   <= '0';
    elsif CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
      if Div_cnt_1ms < Div_multi then
        Div_cnt_1ms <= Div_cnt_1ms+1;
		  reach_1ms	  <= '0';
      else
        Div_cnt_1ms <= x"00000";
		  reach_1ms	  <= '1';
      end if;
    end if;
  end process;

  count_400ms_ps : process (CLK3_250m, rst_n) is
  begin  -- process LED_sig_400ms
    if rst_n = '0' then                 -- asynchronous reset (active low)
      Div_cnt_400ms <= (others => '0');
		reach_400ms	<= '0';
    elsif CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
      if reach_1ms = '1' then
		  if(Div_cnt_400ms < 400) then
          Div_cnt_400ms <= Div_cnt_400ms + 1;
			 reach_400ms	<= '1';
		  else 
			 Div_cnt_400ms <= (others => '0');
			 reach_400ms	<= '0';
		  end if;
      else
        Div_cnt_400ms <= Div_cnt_400ms;
		  reach_400ms	<= '0';
      end if;
    end if;
  end process count_400ms_ps;

  switch_led_ps : process (CLK3_250m, rst_n) is
  begin  -- process state1
    if rst_n = '0' then                 -- asynchronous reset (active low)
		LED_out_sig	<= x"00";
    elsif CLK3_250m'event and CLK3_250m = '1' then  -- rising clock edge
		if(reach_400ms = '1') then
			LED_out_sig	<= LED_out_sig + '1';
		end if;
	 end if;
  end process switch_led_ps;
  
  LED_out <= LED_out_sig;
--end architecture str;
end str;


-------------------------------------------------------------------------------
