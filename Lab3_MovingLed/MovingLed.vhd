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

entity MovingLed is
  port (
    leftButton  : in std_logic;
    rightButton : in std_logic;
    resetButton : in std_logic
  );
end MovingLed;

architecture MovingLed_ARCH of MovingLed is

  signal currentPosition : unsigned(3 downto 0);
  constant ACTIVE : std_logic := '1';

begin
  
  --------------------------------------------
  --This process keeps track of the leds position and 
  --then turns that position into a binary number
  --position output will send the binary number to the BarLedDriver module
  --------------------------------------------
  MoveAround: process(leftButton, rightButton, resetButton)
  begin
    if resetButton = ACTIVE then
      currentPosition <= (others => '0');
    elsif rising_edge(leftButton) and (currentPosition /= 15) then
      currentPosition <= currentPosition + 1;
    elsif rising_edge(rightButton) and (currentPosition /= 0) then
      currentPosition <= currentPosition - 1;
    end if;
  end process MoveAround; 
  position <= std_logic_vector(currentPosition);

   
end architecture MovingLed_ARCH;

