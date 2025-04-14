library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debouncer is
    generic(
        DELAY_COUNT : positive
    );
    port(
        bitIn : in std_logic;
        clock : in std_logic;
        reset : in std_logic;

        debouncedOut : out std_logic
    );
end entity Debouncer;


architecture Debouncer_ARCH of Debouncer is
    signal counter : integer range 0 to DELAY_COUNT;
    signal bitReg : std_logic;
begin
    SCAN_INPUT : process(clock, reset)
    begin
        if reset = '1' then
            counter <= 0;
        elsif rising_edge(clock) then
            if bitIn /= bitReg and counter < DELAY_COUNT then
                counter <= counter + 1;
            elsif counter >= DELAY_COUNT then
                bitReg <= bitIn;
                counter <= 0;
            else
                counter <= 0;
            end if;
        end if;
    end process;
    debouncedOut <= bitReg;
end architecture Debouncer_ARCH;

