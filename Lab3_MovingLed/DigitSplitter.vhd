library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts
--Date: 
--Prof: Scott Tippens
--Desc: 
--      
--      
--      
------------------------------------------------------------

entity DigitSplitter is
  port (
    position: in std_logic_vector(3 downto 0);
    --digits (11 downto 8) represent a hex number (seg[3])
    --seg[3] is blank
    --digits (7 downto 4) will be the tens place (seg[1])
    --digits (3 donwto 0) will be the ones place (seg[0])
    digits  : out std_logic_vector(11 downto 0)
  );
end entity DigitSplitter;

architecture DigitSplitter_ARCH of DigitSplitter is
begin
--------------------------------------------
  --split and decode section for currentPosition
  --this section splits apart the digit buss
  --digits(11 downto 8) will be decoded into hex directly by the sevenSeg driver
  --digits(7 downto 0) must be decoded first then sent to the devenSeg driver
  --------------------------------------------
  digits(11 downto 8) <= position; 

  --splitter for tens and ones place (0xA = 0b0001 0000 = 10)
  --when others catches any metavalues
  with to_integer(unsigned(position)) select
    digits(7 downto 0) <= "00000000" when 0,
                          "00000001" when 1,
                          "00000010" when 2,
                          "00000011" when 3,
                          "00000100" when 4,
                          "00000101" when 5,
                          "00000110" when 6,
                          "00000111" when 7,
                          "00001000" when 8,
                          "00001001" when 9,
    --------------------------------------------------
                          "00010000" when 10,
                          "00010001" when 11,
                          "00010010" when 12,
                          "00010011" when 13,
                          "00010100" when 14,
                          "00010101" when 15,
                          (others => '0') when others; 
end architecture;

