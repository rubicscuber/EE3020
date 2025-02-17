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

    constant ACTIVE : std_logic := '1';
    constant WIDTH : integer := (7 - 1);

begin

    ------------------------------------------------------------
    -- Main process block, grab the value of the input switches
    -- and assign signals to the led bus in a loop
    ------------------------------------------------------------
    LIGHT_LEDS: process(numLeds, leftLedEN, rightLedEN)

        variable countOfLeds : integer range 0 to 7;

    begin

        --numLeds converted to an integer
        --for readable conditionals and easier syntax
        countOfLeds := to_integer(unsigned(numLeds));

        ----------------------------------- Left leds
        if leftLedEN = ACTIVE then
            for i in 0 to WIDTH loop
                if i < countOfLeds then
                    leftLeds(WIDTH - i) <= ACTIVE;
                elsif i >= countOfLeds then
                    leftLeds(WIDTH - i) <= (not ACTIVE);
                else
                    leftLeds <= (others => '0');
                end if;
            end loop;
        else
            leftLeds <= (others => '0');
        end if;

        ----------------------------------- Right leds
        if rightLedEN = ACTIVE then
            for k in 0 to WIDTH loop
                if k < countOfLeds then
                    rightLeds(k) <= ACTIVE;
                elsif k >= countOfLeds then
                    rightLeds(k) <= (not ACTIVE);
                else
                    rightLeds <= (others => '0');
                end if;
            end loop;
        else
            rightLeds <= (others => '0');
        end if;

    end process LIGHT_LEDS; 

end architecture BarLed_ARCH;
