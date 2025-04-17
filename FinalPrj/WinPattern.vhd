library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WinPattern is
    generic(BLINK_COUNT : natural); --(100000000/4)-1;
    port(

        winPatternEN : in std_logic; 

        reset: in std_logic;
        clock: in std_logic;

        leds: out std_logic_vector(15 downto 0);

        winPatternIsBusy : out std_logic
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

    WIN_SHIFT : process(clock, reset)
    begin
        if reset = '1' then
            leds <= BLANK_LEDS;
        elsif rising_edge(clock) then
            if winPatternEN = '1' then 
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

    DISPLAY_RATE: process(reset, clock)
        variable count: integer range 0 to BLINK_COUNT;
    begin
        if (reset = ACTIVE) then
            count := 0;
            winPatternIsBusy <= '0';
            toggle <=  not ACTIVE;
        elsif (rising_edge(clock)) then
            if winPatternEN = '1' then
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
