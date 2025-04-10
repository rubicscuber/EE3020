library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Types_package.all;

entity MemoryGameTB is
end entity;

architecture Behavioral of MemoryGameTB is

component MemoryGame
	port(
		switches         : in  std_logic_vector(15 downto 0);

		start            : in  std_logic;

		clock            : in  std_logic;
		reset            : in  std_logic;

		leds             : out std_logic_vector(15 downto 0);

		outputGameNumber : out std_logic_vector(7 downto 0);
		outputScore      : out std_logic_vector(7 downto 0);

		blanks           : out std_logic_vector(3 downto 0)
	);
end component MemoryGame;    

signal switches : std_logic_vector(15 downto 0) := (others => '0');
signal start : std_logic;
signal clock : std_logic;
signal reset : std_logic;
signal leds : std_logic_vector(15 downto 0);
signal gameNumberSegment : std_logic_vector(7 downto 0);
signal outputScore : std_logic_vector(7 downto 0);
signal blanks : std_logic_vector(3 downto 0);

begin

   UUT : MemoryGame
    port map(
        switches          => switches,
        start             => start,
        clock             => clock,
        reset             => reset,
        leds              => leds,
        outputGameNumber => gameNumberSegment,
        outputScore       => outputScore,
        blanks => blanks
    );


    CLOCK_GEN : process
    begin
        clock <= '0';
        wait for 5 ns;
        clock <= '1';
        wait for 5 ns;
    end process;

    RESET_GEN : process
    begin
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        reset <= '1';
        wait until rising_edge(clock);
        reset <= '0';
        wait;
    end process;

    STIMULUS : process
    begin
        wait for 500 ns;
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        start <= '1';
        wait until rising_edge(clock);
        start <= '0';
        wait for 200 ns;

        --guessing 1 number-----------
        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';
        wait for 200 ns;

        --guessing 2 numbers----------
        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';
        wait for 300 ns;

        --guessing 3 numbers----------
        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(1) <= '1';
        wait until rising_edge(clock);
        switches(1) <= '0';
        wait for 400 ns;

        --guessing 4 numbers---------
        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(1) <= '1';
        wait until rising_edge(clock);
        switches(1) <= '0';

        wait until rising_edge(clock);
        switches(8) <= '1';
        wait until rising_edge(clock);
        switches(8) <= '0';
        wait for 500 ns;
        
        --guessing 5 numbers---------
        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(1) <= '1';
        wait until rising_edge(clock);
        switches(1) <= '0';

        wait until rising_edge(clock);
        switches(8) <= '1';
        wait until rising_edge(clock);
        switches(8) <= '0';

        wait until rising_edge(clock);
        switches(10) <= '1';
        wait until rising_edge(clock);
        switches(10) <= '0';

        wait for 400 ns;
        
        --start new game and wait for display to be done---------------------------------
        wait until rising_edge(clock);
        start <= '1';
        wait until rising_edge(clock);
        start <= '0';
        wait for 200 ns;
         
        --guessing 1 number----------
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';
        wait for 200 ns;

        --guessing 2 numbers---------
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';
        wait for 300 ns;

        --guessing 3 numbers---------
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';
        wait for 400 ns;

        --guessing 4 numbers----------
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(14) <= '1';
        wait until rising_edge(clock);
        switches(14) <= '0';
        wait for 500 ns;
        
        --guessing 5 numbers---------
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(14) <= '1';
        wait until rising_edge(clock);
        switches(14) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait for 400 ns;

        --start new game and wait for display to be done
        wait until rising_edge(clock);
        start <= '1';
        wait until rising_edge(clock);
        start <= '0';
        wait for 200 ns;
         
        --guessing 1 number
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';
        wait for 200 ns;

        --guessing 2 numbers
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';
        wait for 300 ns;

        --guessing 3 numbers
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';
        wait for 400 ns;

        --guessing 4 numbers
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(14) <= '1';
        wait until rising_edge(clock);
        switches(14) <= '0';
        wait for 500 ns;
        
        --guessing 5 numbers
        wait until rising_edge(clock);
        switches(5) <= '1';
        wait until rising_edge(clock);
        switches(5) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait until rising_edge(clock);
        switches(12) <= '1';
        wait until rising_edge(clock);
        switches(12) <= '0';

        wait until rising_edge(clock);
        switches(14) <= '1';
        wait until rising_edge(clock);
        switches(14) <= '0';

        wait until rising_edge(clock);
        switches(7) <= '1';
        wait until rising_edge(clock);
        switches(7) <= '0';

        wait;
    end process;
    
end architecture Behavioral ;
