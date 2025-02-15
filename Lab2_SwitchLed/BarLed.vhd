library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_2_SwitchLed
--Name: Nathaniel Roberts
--Date: 2/12/25
--Prof: Scott Tippens
--Desc: This module takes a binary value of switches and 
--      assignes an ammount of leds based on that number
--      left button will enable a bar that grows from the left
--      right button will enable a bar that grown from the right
------------------------------------------------------------

entity BarLed is
  port (
    numLeds     : in std_logic_vector(2 downto 0);
    leftLedEN   : in std_logic;
    rightLedEN  : in std_logic;

    leftLeds    : out std_logic_vector(6 downto 0);
    rightLeds   : out std_logic_vector(6 downto 0)
    );
end entity BarLed;

architecture BarLed_ARCH of BarLed is

begin

  ------------------------------------------------------------
  -- Main process block, grab the value of the input switches
  -- and assign signals to the led bus in a loop
  ------------------------------------------------------------
  LIGHT_LEDS: process(numLeds, leftLedEN, rightLedEN)

    variable countOfLeds : integer range 0 to 7;

  begin
    --numLeds converted to an integer number for 
    --readable conditional signals
    countOfLeds := to_integer(unsigned(numLeds));

  ----------------------------------- Left leds
    if leftLedEN = '1' then
      for i in 0 to 6 loop
        if i < countOfLeds then
          leftLeds(6 - i) <= '1';
        elsif i >= countOfLeds then
          leftLeds(6 - i) <= '0';
        else
          leftLeds <= (others => '0');
        end if;
      end loop;
    else
      leftLeds <= (others => '0');
    end if;
  ----------------------------------- Right leds
    if rightLedEN = '1' then
      for k in 0 to 6 loop
        if k < countOfLeds then
          rightLeds(k) <= '1';
        elsif k >= countOfLeds then
          rightLeds(k) <= '0';
        else
          rightLeds <= (others => '0');
        end if;
      end loop;
    else
      rightLeds <= (others => '0');
    end if;
  end process LIGHT_LEDS; 
  
end architecture BarLed_ARCH;
