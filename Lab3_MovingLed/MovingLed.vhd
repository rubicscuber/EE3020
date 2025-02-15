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
    --rightButton : in std_logic;
    resetButton : in std_logic;

    position    : out std_logic_vector(3 downto 0)
  );
end MovingLed;

architecture MovingLed_ARCH of MovingLed is

  constant ACTIVE : std_logic := '1';
  signal Right : std_logic;
  signal Left : std_logic;
  --signal currentPosition : unsigned(3 downto 0);
  signal IntPosition : integer range 0 to 15;

begin --todo: test this code
  MoveLeft: process(leftButton, resetButton) 
  begin
    if rising_edge(leftButton) then
      IntPosition <= (IntPosition + 1);
    end if;
  end process MoveLeft;
  --end process MoveLeft;

  --MoveRight: process(rightButton, rightButton, resetButton)
  --begin
  --  Right <= not ACTIVE;
  --  if rising_edge(rightButton) then
  --    Right <= ACTIVE;
  --  end if;
  --end process MoveRight;

  --ResolveMovement: process(Left, Right, resetButton)
  --begin
  --  if resetButton = ACTIVE then
  --    CurrentPosition <= (others => '0');
  --  else
  --    if (Left = '1') and (Right = '0') and (currentPosition < 15) then
  --      currentPosition <= currentPosition + 1;
  --    elsif (Left = '0') and (Right = '1') and (currentPosition > 0) then
  --      currentPosition <= currentPosition - 1;
  --    end if;
  --  end if;
  --end process ResolveMovement;

  --position <= std_logic_vector(currentPosition);
  position <= std_logic_vector(to_unsigned(IntPosition, 4));

end architecture MovingLed_ARCH;

