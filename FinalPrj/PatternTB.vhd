library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PatternTB is
end entity ;


architecture behavioral of PatternTB is

    component WinPattern is
        generic(BLINK_COUNT : natural); --(100000000/4)-1;
        port(
                winPatternStart : in std_logic; 

                reset: in std_logic;
                clock: in std_logic;

                leds: out std_logic_vector(15 downto 0)
        );
    end component;

    signal winPatternStart : std_logic;
    signal reset : std_logic;
    signal clock : std_logic;
    signal leds : std_logic_vector(15 downto 0);

begin

    UUT : WinPattern 
        generic map (BLINK_COUNT => 10)
        port map(
            winPatternStart => winPatternStart,
            reset => reset,
            clock => clock,
            leds => leds
        );

    CLOCK_GEN : process is
    begin
        clock <= '1';
        wait for 5 ns;
        clock <= '0';
        wait for 5 ns;
    end process;

    STUMULUS : process is
    begin
        reset <= '1';
        wait until rising_edge(clock);
        reset <= '0';
        wait until rising_edge(clock);
        wait;
    end process;

    winPatternStart <= '1';


end architecture behavioral;
