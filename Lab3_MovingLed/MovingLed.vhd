library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

architecture MovingLed_ARCH of MovingLed is

  signal currentPosition : unsigned(3 downto 0) := "0000";
  constant ACTIVE : std_logic := '1';

begin

  MoveAround: process(leftButton, rightButton, resetButton)
  begin
      if resetButton = ACTIVE then
        currentPosition <= (others => '0');
      elsif rising_edge(leftButton) and (currentPosition /= 15) then
        currentPosition <= currentPosition + 1;
      elsif rising_edge(rightButton) and (currentPosition /= 0) then
        currentPosition <= currentPosition -1;
      else
        currentPosition <= (others => '0');
      end if;
  end process MoveAround; 
  
  --this will be a hex number into the display module, no decoding for this
  digits(11 downto 8) <= std_logic_vector(currentPosition); 

  --splitter for tens and ones place (0xA = 0b0001 0000 = 10)
  with currentPosition select
    digits(7 downto 0) <= "00000000" when "0000", --0
                          "00000001" when "0001", --1
                          "00000010" when "0010", --2
                          "00000011" when "0011", --3
                          "00000100" when "0100", --4
                          "00000101" when "0101", --5
                          "00000110" when "0110", --6
                          "00000111" when "0111", --7
                          "00001000" when "1000", --8
                          "00001001" when "1001", --9
    --------------------------------------------------
                          "00010000" when "1010", --10
                          "00010001" when "1011", --11
                          "00010010" when "1100", --12
                          "00010011" when "1101", --13
                          "00010100" when "1110", --14
                          "00010101" when "1111", --15
                          "00000000" when others; 
 
end architecture MovingLed_ARCH;

