library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity BarLedTB is
end BarLedTB;

architecture Behavioral of BarLedTB is

  ---------------------Component declerations---------------------
  component BarLed is
  port (
    numLeds     : in std_logic_vector(2 downto 0);
    leftLedEN   : in std_logic;
    rightLedEN  : in std_logic;

    leftLeds    : out std_logic_vector(6 downto 0);
    rightLeds   : out std_logic_vector(6 downto 0)
    );
  end component;

  ----------------------signals for components-------------------
  signal inputs    : std_logic_vector(4 downto 0) := "00000";

  signal leftLeds   : std_logic_vector(6 downto 0);
  signal rightLeds  : std_logic_vector(6 downto 0);



begin
  ------------instantiatine components within design-------------
  --component_pin => tb_signal,
  UUT : BarLed port map(
    numLeds    =>  inputs(2 downto 0),
    leftLedEN  =>  inputs(3),
    rightLedEN =>  inputs(4),

    leftLeds   =>  leftLeds,
    rightLeds  =>  rightLeds);

  --------------------clockgen process--------------------------
 -- clkGen : process
 -- begin
 --     wait for 5 ns;
 --     clk <= not clk;
 -- end process clkGen;
------------------------input stimulus--------------------------
	stimulus : process
	begin

      wait for 1 ns;
      test_loop : for k in 0 to 31 loop
        inputs <= std_logic_vector(to_unsigned(k, 5)); --to_unsigned(integer, length)
        wait for 1 ns;
      end loop test_loop;

      wait for 1 ns;
      test_loop1 : for k in 31 downto 0 loop
        inputs <= std_logic_vector(to_unsigned(k, 5)); --to_unsigned(integer, length)
        wait for 1 ns;
      end loop test_loop1;

	wait;
	end process;

end Behavioral;
