library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: Debouncer.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/23/25
--Prof: Scott Tippens
--Desc: Counter based debouncing component.
--      This component checks to see if the user input has remained in its position
--      for the full duration of the count. If that signal input is different than the 
--      output and the counter has also not yet reached its terminal value, then the 
--      input is not yet stable and the component keeps the signal from reflecting to 
--      the ouput.
------------------------------------------------------------------------------------

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

