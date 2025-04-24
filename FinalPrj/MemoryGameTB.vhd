library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: MemoryGameTB.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/24/25
--Prof: Scott Tippens
--Desc: Memory Game testbench file
--      This file uses seperate processes to find what the numerical display numbers
--      are and output the cooresponding one pulse wide switch signal 
--      
--      The testbench can be configured for any timing range based on the generic 
--      parameters.
------------------------------------------------------------------------------------

entity MemoryGameTB is
end entity;

architecture Behavioral of MemoryGameTB is

    ------------------------------------------------------------------------------------
    --Unit under test definition
    ------------------------------------------------------------------------------------
    component MemoryGame
        generic(
            MAX_COUNT_SCALER : integer;
            SCALE_AMOUNT     : integer;
            MAX_TOGGLE_COUNT : integer;
            BLINK_COUNT      : integer
        );
        port(
            switches    : in  std_logic_vector(15 downto 0);
            start       : in  std_logic;
            clock       : in  std_logic;
            reset       : in  std_logic;
            leds        : out std_logic_vector(15 downto 0);
            outputScore : out std_logic_vector(7 downto 0);
            blanks      : out std_logic_vector(3 downto 0)
        );
    end component MemoryGame;    

    ------------------------------------------------------------------------------------
    --testbench signals
    ------------------------------------------------------------------------------------
    signal switches : std_logic_vector(15 downto 0) := (others => '0');
    signal start : std_logic;
    signal clock : std_logic;
    signal reset : std_logic;
    signal leds : std_logic_vector(15 downto 0);
    signal blanks : std_logic_vector(3 downto 0);
    signal outputScore : std_logic_vector(7 downto 0);

    constant CLOCK_PERIOD     : time := 10 ns;
    constant MAX_COUNT_SCALER : integer := 0;
    constant SCALE_AMOUNT     : integer := 50;
    constant MAX_TOGGLE_COUNT : integer := 100;
    constant BLINK_COUNT      : integer := 25;

    type testVector_t is array(0 to 4) of integer;
    signal number_reg : testVector_t;

    signal load_number_regEN : std_logic := '0';
    signal load_number_reg_completeEN : std_logic := '0';

    --MAX_TOGGLE_COUNT * CLOCK_PERIOD = 1000
    constant getNumberDelay : time := 1000 ns;
    --BLINK_COUNT * COCK_PERIOD = 250
    --25 * 10 = 250
    constant patternDelay : time := 250 ns;


begin

    ------------------------------------------------------------------------------------
    --Design instantiation
    ------------------------------------------------------------------------------------
    UUT : MemoryGame
    generic map(
        MAX_COUNT_SCALER => MAX_COUNT_SCALER,
        SCALE_AMOUNT     => SCALE_AMOUNT,
        MAX_TOGGLE_COUNT => MAX_TOGGLE_COUNT,
        BLINK_COUNT      => BLINK_COUNT
    )
    port map(
        switches          => switches,
        start             => start,
        clock             => clock,
        reset             => reset,

        ------------------outputs
        leds              => leds,
        outputScore       => outputScore,
        blanks            => blanks
    );


    ------------------------------------------------------------------------------------
    -- Clock generator
    ------------------------------------------------------------------------------------
    CLOCK_GEN : process
    begin
        clock <= '0';
        wait for (CLOCK_PERIOD / 2);
        clock <= '1';
        wait for (CLOCK_PERIOD / 2);
    end process;

    ------------------------------------------------------------------------------------
    -- Reset button generator
    ------------------------------------------------------------------------------------
    RESET_GEN : process
    begin
        wait until rising_edge(clock);
        wait until rising_edge(clock);
        reset <= '1';
        wait until rising_edge(clock);
        reset <= '0';
        wait;
    end process;

    ------------------------------------------------------------------------------------
    -- This process can scan the output of the switches and assign those values into 
    -- an array of integers.
    ------------------------------------------------------------------------------------
    TEST_REGISTER : process
    begin
        wait until rising_edge(load_number_regEN);
        wait for getNumberDelay;
        for k in 0 to 4 loop
            for i in 0 to 15 loop
                if leds(i) = '1' then
                    number_reg(k) <= i;
                end if;
            end loop;
            wait for getNumberDelay; --dont start i loop until next number pops up
            wait for getNumberDelay; 
        end loop;

        load_number_reg_completeEN <= '1';
        wait until rising_edge(clock); 
        load_number_reg_completeEN <= '0';
        wait until rising_edge(clock); 


    end process;

    ------------------------------------------------------------------------------------
    -- Main stimulus process with necessary timing procedures
    ------------------------------------------------------------------------------------
    STIMULUS : process
    begin
        wait for 500 ns;

        start <= '1';                   --start button pressed
        wait until rising_edge(clock);
        start <= '0';
        wait until rising_edge(clock);

        --first round-------------------------------------------------------------------
        load_number_regEN <= '1';        --trigger the TEST_REGISTER process
        wait until rising_edge(clock);   --to load numbers as the numbers are brought up.
        load_number_regEN <= '0';
        wait until rising_edge(clock);

        wait until rising_edge(load_number_reg_completeEN); --wait for the loop to be done

        switches(number_reg(0)) <= '1'; --plug in numbers
        wait until rising_edge(clock);
        switches(number_reg(0)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(1)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(1)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(2)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(2)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(3)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(3)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(4)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(4)) <= '0';
        wait until rising_edge(clock);

        --second round------------------------------------------------------------------
        wait for 2000 ns;

        load_number_regEN <= '1';        --trigger the TEST_REGISTER process
        wait until rising_edge(clock);   --to load numbers as the numbers are brought up.
        load_number_regEN <= '0';
        wait until rising_edge(clock);

        wait until rising_edge(load_number_reg_completeEN); --wait for the loop to be done

        switches(number_reg(0)) <= '1'; --plug in numbers
        wait until rising_edge(clock);
        switches(number_reg(0)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(1)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(1)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(2)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(2)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(3)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(3)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(4)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(4)) <= '0';
        wait until rising_edge(clock);

        --third round--------------------------------------------------------------------
        wait for 1100 ns;

        load_number_regEN <= '1';        --trigger the TEST_REGISTER process
        wait until rising_edge(clock);   --to load numbers as the numbers are brought up.
        load_number_regEN <= '0';
        wait until rising_edge(clock);

        wait until rising_edge(load_number_reg_completeEN); --wait for the loop to be done

        switches(number_reg(0)) <= '1'; --plug in numbers
        wait until rising_edge(clock);
        switches(number_reg(0)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(1)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(1)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(2)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(2)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(3)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(3)) <= '0';
        wait until rising_edge(clock);

        switches(number_reg(4)) <= '1';
        wait until rising_edge(clock);
        switches(number_reg(4)) <= '0';
        wait until rising_edge(clock);
        wait;
    end process;
    
end architecture Behavioral ;
