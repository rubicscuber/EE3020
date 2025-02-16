library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MovingLedTB is
end MovingLedTB;

architecture Behavioral of MovingLedTB is

  ------------------------------------------
  --Component definition
  ------------------------------------------
  component MovingLed is
    port (
      leftButton  : in std_logic;
      rightButton : in std_logic;
      resetButton : in std_logic;
      clock : in std_logic;
      position: out std_logic_vector(3 downto 0));
  end component;

  ------------------------------------------
  --signals to connect to components
  ------------------------------------------
  signal leftButton  : std_logic := '1';
  signal rightButton : std_logic := '1';
  signal resetButton : std_logic := '1';
  signal clk : std_logic := '0';
  signal position : std_logic_vector(3 downto 0);
 
begin

  ------------------------------------------
  --instantiatine components within design
  --component_pin => tb_signal,
  ------------------------------------------
  UUT : MovingLed port map(
    leftButton  => leftButton, 
    rightButton => rightButton,
    resetButton => resetButton,
    clock => clk,
    position => position);

  ------------------------------------------
  --clockgen process
  ------------------------------------------
  clkGen : process
  begin
      wait for 1 ns; --100MHz clock = 5ns to toggle
      clk <= not clk;
  end process clkGen;
  ------------------------------------------
  --input stimulus
  ------------------------------------------
  stimulus : process
	begin
    resetButton <= '0'; --actuate reset switch
    wait for 300 ns;
    resetButton <= '1';
    wait for 300 ns;

		moveLeft : for k in 0 to 31 loop
      leftButton <= not leftButton;
			wait for 300 ns;
		end loop moveLeft;

    resetButton <= '0'; --actuate reset switch
    wait for 300 ns;
    resetButton <= '1';
    wait for 300 ns;

		moveRight : for k in 0 to 31 loop
      rightButton <= not rightButton;
			wait for 300 ns;
    end loop moveRight;

		moveLeftAgain : for k in 0 to 31 loop
      leftButton <= not leftButton;
			wait for 300 ns;
		end loop moveLeftAgain;

		moveRightAgain : for k in 0 to 31 loop
      rightButton <= not rightButton;
			wait for 300 ns;
		end loop moveRightAgain;

	wait;
	end process;

end Behavioral;
