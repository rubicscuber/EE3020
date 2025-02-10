library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MovingLedTB is
end MovingLedTB;

architecture Behavioral of MovingLedTB is

  ------------------------------------------
  --Component definition
  ------------------------------------------
  entity MovingLed is
    port (
      leftButton  : in std_logic;
      rightButton : in std_logic;
      resetButton : in std_logic;

      --digits (11 downto 8) will represent a hex number (seg[3])
      --seg[3] is blank
      --digits (7 downto 4) will be the tens place (seg[1])
      --digits (3 donwto 0) will be the ones place (seg[0])

      digits : out std_logic_vector(11 downto 0));

  end MovingLed;

  ------------------------------------------
  --signals to connect to components
  ------------------------------------------
  signal leftButton  : std_logic;
  signal rightButton : std_logic;
  signal resetButton : std_logic;
  signal digits : std_logic_vector(11 downto 0);

 
begin

  ------------------------------------------
  --instantiatine components within design
  --component_pin => tb_signal,
  ------------------------------------------
  UUT : MovingLed port map(
    leftButton  => leftButton, 
    rightButton => rightButton,
    resetButton => resetButton,
    digits => digits);

  ------------------------------------------
  --clockgen process
  ------------------------------------------
  --clkGen : process
  --begin
  --    wait for 5 ns; --100MHz clock
  --    clk <= not clk;
  --end process clkGen;
------------------------input stimulus--------------------------
	stimulus : process
	begin
    dataIn <= '0';
    wait for 18 ms;
    dataIn <= '1';
    wait for 16 ms;
		--test_loop : for k in 0 to  loop
    --  inputs <= std_logic_vector(to_unsigned(k, 4)); --to_unsigned(integer, length)
		--	wait for 1 ns;
		--end loop test_loop;
	wait;
	end process;

end Behavioral;
