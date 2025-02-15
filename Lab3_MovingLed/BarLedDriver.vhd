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

entity BarLedDriver is
  port (
    position : in std_logic_vector(3 downto 0);
    bar : out std_logic_vector(15 downto 0)
  );
end entity BarLedDriver;

architecture BarLedDriver_ARCH of BarLedDriver is
begin
barLeds: process(position)
  begin
    barLoop : for k in 0 to 15 loop
      if to_integer(unsigned(position)) = k then
        bar(k) <= '1';
      else 
        bar(k) <= '0';
      end if;
    end loop;
  end process barLeds;


end BarLedDriver_ARCH;
