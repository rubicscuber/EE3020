library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_2_SwitchLed
--Name: Nathaniel Roberts
--Date: 2/12/25
--Prof: Scott Tippens
--Desc: Fun module that strobes the leds so it looks more interesting
------------------------------------------------------------

entity BarLedStrobe is
  port (
    numLeds     : in std_logic_vector(2 downto 0);
    leftLedEN   : in std_logic;
    rightLedEN  : in std_logic;
    clock       : in std_logic;

    leftLeds    : out std_logic_vector(6 downto 0);
    rightLeds   : out std_logic_vector(6 downto 0)
    );
end entity BarLedStrobe;

architecture BarLedStrobe_ARCH of BarLedStrobe is
  signal leftLedBusEN : std_logic_vector(6 downto 0);
  signal rightLedBusEN : std_logic_vector(6 downto 0);
  signal strobe : integer range 0 to 6;
  constant PULSE_COUNT : integer := (100000000/20 - 1);
begin

  ------------------------------------------------------------
  --Fun module that now strobes through the leds 
  --for a more interesting visual
  ------------------------------------------------------------
  Clock4Hz: process(clock)
    variable clkCount : integer range 0 to (PULSE_COUNT);
    --variable clkCount : integer range 0 to (10 + 1);
  begin
    if rising_edge(clock) then
      if clkCount = PULSE_COUNT then
      --if clkCount = 10 + 1 then
        if strobe < 6 then
          strobe <= strobe + 1;
        else
          strobe <= 0;
        end if;
      clkCount := 0;
      else
        clkCount := clkCount + 1;
      end if;
    end if;
  end process Clock4Hz;

  ------------------------------------------------------------
  --selection statements to make a enabling vecotor for the leds
  ------------------------------------------------------------
  
  with strobe select
    leftLedBusEN <= "0111111" when 0,
                    "1011111" when 1,
                    "1101111" when 2,
                    "1110111" when 3,
                    "1111011" when 4,
                    "1111101" when 5,
                    "1111110" when 6,
                    (others => '0') when others;
with strobe select
    rightLedBusEN <= "1111110" when 0,
                     "1111101" when 1,
                     "1111011" when 2,
                     "1110111" when 3,
                     "1101111" when 4,
                     "1011111" when 5,
                     "0111111" when 6,
                     (others => '0') when others;


  ------------------------------------------------------------
  -- Main process block, grab the value of the input switches
  -- and assign signals to the led bus in a loop
  ------------------------------------------------------------
  BarLightProc: process(numLeds, leftLedEN, rightLedEN, clock)
    variable counter : integer range 0 to 7;
  begin
    counter := to_integer(unsigned(numLeds));

  ----------------------------------- Left leds
    if leftLedEN = '1' then
      for ii in 0 to 6 loop
        if counter = 0 then
          leftLeds <= (others => '0');
        elsif ii < counter then
          leftLeds(6 - ii) <= ('1' and leftLedBusEN(6 - ii));
        elsif ii >= counter then
          leftLeds(6 - ii) <= '0';
        else
          leftLeds <= (others => '0');
        end if;
      end loop;
    else
        leftLeds <= (others => '0');
    end if;
  ----------------------------------- Right leds
    if rightLedEN = '1' then
      for jj in 0 to 6 loop
        if counter = 0 then
          rightLeds <= (others => '0');
        elsif jj < counter then
          rightLeds(jj) <= ('1' and rightLedBusEN(jj));
        elsif jj >= counter then
          rightLeds(jj) <= '0';
        else
          rightLeds <= (others => '0');
        end if;
      end loop;
    else
        rightLeds <= (others => '0');
    end if;
  end process BarLightProc; 
  
end architecture BarLedStrobe_ARCH;
