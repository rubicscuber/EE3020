library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MovingLed is
  port (
    leftButton  : in std_logic;
    rightButton : in std_logic;
    resetButton : in std_logic;

    --digits 11 downto 8 will represent a hex number (seg[3])
    --digitns 7 downto 4 will be the tens place (seg[1])
    --digits 3 donwto 0 will be the ones place (seg[0])
    --seg[2] will be blank
    digits : out std_logic_vector(11 downto 0));

end MovingLed;

architecture MovingLed_ARCH of MovingLed is

  signal currentPosition : unsigned(3 downto 0) := "0000";

begin

  main: process(leftButton, rightButton, resetButton)
  begin
      if rising_edge(leftButton) and (currentPosition /= 15) then
        currentPosition <= currentPosition + 1;
      elsif rising_edge(rightButton) and (currentPosition /= 0) then
        currentPosition <= currentPosition -1;
      elsif resetButton = '1' then
        currentPosition <= "0000";
      end if;
  end process main; 

  digits(11 downto 8) <= currentPosition;

  digitsplitter: process() --todo: make a splitter for tens and ones place
  begin
    
  end process digitsplitter;
 
end architecture MovingLed_ARCH;

