library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: WinPattern.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/25/25
--Prof: Scott Tippens
--Desc: Win pattern generator
--      This module handles drawing a specific win patternt to the 16 leds.
--       
--      When inactive, the leds are put into high impedace to avoid multiple driven nets
--      
------------------------------------------------------------------------------------

entity WinPattern is
    generic(BLINK_COUNT : natural); --(100000000/4)-1;
    port(
        winPatternMode : in std_logic; 

        reset: in std_logic;
        clock: in std_logic;

        leds: out std_logic_vector(15 downto 0)
    );
end WinPattern;

architecture WinPattern_ARCH of WinPattern is

    constant ACTIVE: std_logic := '1';

    constant BLANK_LEDS : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
    constant PATTERN0_LEDS : std_logic_vector(15 downto 0) := "1010101010101010";
    constant PATTERN1_LEDS : std_logic_vector(15 downto 0) := "0101010101010101";

    signal displayMode : std_logic;
    signal toggle : std_logic;

begin

    ------------------------------------------------------------------------------------
    -- The if this module's WinPatternMode port is high then it will begin displaying
    -- a shifing patter of leds. The toggle signal flips back and fourth between 
    -- selecting one pattern or another. If this componenent is not selected, then
    -- the output is in high impedance.
    ------------------------------------------------------------------------------------
    WIN_SHIFT : process(clock, reset)
    begin
        if reset = '1' then
            leds <= BLANK_LEDS;
        elsif rising_edge(clock) then
            if winPatternMode = '1' then 
                if toggle = '1' then
                    leds <= PATTERN0_LEDS;
                elsif toggle = '0' then
                    leds <= PATTERN1_LEDS;
                end if;
            else
                leds <= BLANK_LEDS;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- This process handles how fast the toggle signal fill flip back and fourth.
    ------------------------------------------------------------------------------------
    DISPLAY_RATE: process(reset, clock)
        variable count: integer range 0 to BLINK_COUNT;
    begin
        if (reset = ACTIVE) then
            count := 0;
            toggle <=  not ACTIVE;
        elsif (rising_edge(clock)) then
            if winPatternMode = '1' then
                if (count >= BLINK_COUNT) then
                    count := 0;
                    toggle <= not toggle;
                else
                    count := count + 1;
                end if;
            else 
                count := 0;
                toggle <= not ACTIVE;
            end if;
        end if;
    end process DISPLAY_RATE;

end WinPattern_ARCH;
