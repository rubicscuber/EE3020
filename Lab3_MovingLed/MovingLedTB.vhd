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
      position: out std_logic_vector(3 downto 0));
  end component;

  ------------------------------------------
  --signals to connect to components
  ------------------------------------------
  signal leftButton  : std_logic := '0';
  signal rightButton : std_logic := '0';
  signal resetButton : std_logic := '0';
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
    position => position);

  ------------------------------------------
  --clockgen process
  ------------------------------------------
  --clkGen : process
  --begin
  --    wait for 5 ns; --100MHz clock
  --    clk <= not clk;
  --end process clkGen;
  ------------------------------------------
  --input stimulus
  ------------------------------------------
  stimulus : process
	begin
    resetButton <= '1'; --anctuate reset switch
    wait for 1 ns;
    resetButton <= '0';
    wait for 1 ns;

		moveLeft : for k in 0 to 31 loop
      leftButton <= not leftButton;
			wait for 1 ns;
		end loop moveLeft;

    resetButton <= '1'; --anctuate reset switch
    wait for 1 ns;
    resetButton <= '0';
    wait for 1 ns;

		moveRight : for k in 0 to 31 loop
      rightButton <= not rightButton;
			wait for 1 ns;
    end loop moveRight;

		moveLeftAgain : for k in 0 to 31 loop
      leftButton <= not leftButton;
			wait for 1 ns;
		end loop moveLeftAgain;

	wait;
	end process;

end Behavioral;
