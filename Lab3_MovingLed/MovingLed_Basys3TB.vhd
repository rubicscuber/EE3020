library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MovingLed_Basys3TB is
end entity MovingLed_Basys3TB;

architecture MovingLed_Basys3TB_ARCH of MovingLed_Basys3TB is
  component MovingLed_Basys3 is
  port(
      btnL : in std_logic;
      btnR : in std_logic;
      btnC : in std_logic;
      clk  : in std_logic;

      an : out std_logic_vector(3 downto 0);
      seg: out std_logic_vector(6 downto 0);
      led: out std_logic_vector(15 downto 0)
    );
  end component;

  signal btnL : std_logic := '1';
  signal btnR : std_logic := '1';
  signal btnC : std_logic := '1';
  signal clock : std_logic := '0';

  signal an  : std_logic_vector(3 downto 0);
  signal seg : std_logic_vector(6 downto 0);
  signal led : std_logic_vector(15 downto 0);
  

begin

  UUT : MovingLed_Basys3 port map(
    btnL => btnL,
    btnR => btnR,
    btnC => btnC,
    clk => clock,

    an => an,
    seg => seg,
    led => led
  );
  clockgen : process
  begin
    clock <= not clock;
    wait for 5 ns;
  end process clockgen;

  stimulus : process
	begin
    btnC <= '0'; --actuate reset switch
    wait for 1 us;
    btnC <= '1';
    wait for 1 us;

		moveLeft : for k in 0 to 31 loop --move left
      btnL <= not btnL;
			wait for 1 us;
		end loop moveLeft;

    btnC <= '0'; --actuate reset switch
    wait for 1 us;
    btnC <= '1';
    wait for 1 us;

		moveRight : for k in 0 to 31 loop --move right
      btnR <= not btnR;
			wait for 1 us;
    end loop moveRight;

		moveLeftAgain : for k in 0 to 31 loop --move left
      btnL <= not btnL;
			wait for 1 us;
		end loop moveLeftAgain;

    moveRightAgain : for k in 0 to 31 loop --move right
      btnR <= not btnR;
      wait for 1 us;
    end loop moveRightAgain;
	wait;
	end process;

end architecture MovingLed_Basys3TB_ARCH;
