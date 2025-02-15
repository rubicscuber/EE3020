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
    resetButton : in std_logic;

    position    : out std_logic_vector(3 downto 0)
  );
end MovingLed;

architecture MovingLed_ARCH of MovingLed is

  --signals for solution 1--
  signal currentPosition : integer range 0 to 15;
  signal Left : std_logic;
  signal Right: std_logic;

  --signals for solution 2--
  --constant ACTIVE : std_logic := '0';
  --signal moveClock : std_logic;
  --signal currentPosition : integer range 0 to 15;

begin

  --solution 1
  moveLeft : process(leftButton)
  begin
    Left <= '0';
    if falling_edge(leftButton) then
      Left <= '1';
    end if;
  end process;

  moveRight : process(rightButton)
  begin
    Right <= '0';
    if falling_edge(rightButton) then
      Right <= '1';
    end if;
  end process;

  resolve : process(Left, Right, resetButton)
  begin
    if resetButton = '0' then
      currentPosition <= 0;
    elsif (Left = '1') and (Right = '0') and (currentPosition < 15) then
      currentPosition <= currentPosition + 1;
    elsif (Left = '0') and (Right = '1') and (currentPosition > 0) then
      currentPosition <= currentPosition - 1;
    end if;
    position <= std_logic_vector(to_unsigned(currentPosition, 4));
  end process;

 --solution 2
--  moveClock <= leftButton nand rightButton;
--  MOVE_AROUND: process(moveClock, resetButton) 
--  begin
--    if (resetButton = not ACTIVE) then
--      currentPosition <= 0;
--    elsif rising_edge(moveClock) then
--      if (leftButton = '1') and (rightButton = '0') and (currentPosition < 15) then
--        currentPosition <= (currentPosition + 1);
--      elsif (rightButton = '0') and (leftButton = '1') and (currentPosition > 0) then
--        currentPosition <= (currentPosition - 1);
--      end if;
--    end if;
--  end process MOVE_AROUND;
--  position <= std_logic_vector(to_unsigned(currentPosition, 4));

end architecture MovingLed_ARCH;

