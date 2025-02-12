library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DigitSplitterTB is
end entity DigitSplitterTB;

architecture behavioral of DigitSplitterTB is 
  component DigitSplitter is
  port (
    position: in std_logic_vector(3 downto 0);
    --digits (11 downto 8) represent a hex number (seg[3])
    --seg[3] is blank
    --digits (7 downto 4) will be the tens place (seg[1])
    --digits (3 donwto 0) will be the ones place (seg[0])
    digits  : out std_logic_vector(11 downto 0)
  );
  end component;
  signal position : std_logic_vector(3 downto 0) := "0000";
  signal digits : std_logic_vector(11 downto 0);

begin

  UUT : DigitSplitter port map(
  position => position,
  digits => digits);

  stimulus : process
  begin
    for k in 0 to 15 loop
      position <= std_logic_vector(to_unsigned(k,4));
      wait for 1 ns;
      end loop;
  wait;
  end process;
end behavioral;
