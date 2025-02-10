library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
  signal numLedsInt : integer;

begin

numLedsInt <= to_integer(unsigned(numLeds));

leftBarLightProc: process(numLedsInt, leftLedEN, rightLedEN)
begin
  if leftLedEN = '1' then
    for ii in 0 to 6 loop
      if numLedsInt = 0 then
        leftLeds <= "0000000";
      elsif ii < numLedsInt then
        leftLeds(6 - ii) <= '1';
      elsif ii = numLedsInt then
        leftLeds(6 - ii) <= '0';
      elsif ii > numLedsInt  then
        leftLeds(6 - ii) <= '0';
      else
        leftLeds <= "0000000";
      end if;
    end loop;
  else
      leftLeds <= "0000000";
  end if;
end process leftBarLightProc;

rightBarLightProc: process(numLedsInt, rightLedEN, leftLedEN)
begin
  if rightLedEN = '1' then
    for jj in 0 to 6 loop
      if numLedsInt = 0 then
        rightLeds <= "0000000";
      elsif jj < numLedsInt then
        rightLeds(jj) <= '1';
      elsif jj = numLedsInt then
        rightLeds(jj) <= '0';
      elsif jj > numLedsInt then
        rightLeds(jj) <= '0';
      else
        rightLeds <= "0000000";
      end if;
    end loop;
  else
      rightLeds <= "0000000";
  end if;
end process rightBarLightProc; 
  
end architecture BarLed_ARCH;
