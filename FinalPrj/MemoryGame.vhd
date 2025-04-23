library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: 
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Memory Game design file
--      This module contains the main operating instructions of the Memory game.
--       
--      To start the game a player must press the center push button.
--      Then 5 seperate leds will light on the 16 wide led display once each second.
--      
--      They player must recall the order of the leds by fliping the coresponding 
--      slide switch. Once all numbers were guessed correctly, a short victory patter
--      lights, the score increments and the next round starts automatically.
--      
--      Each successive round is faster than the last. The game ends at any point the
--      player guesses the wrong number during their turn.
------------------------------------------------------------------------------------

entity MemoryGame is
    port(
        switches : in std_logic_vector(15 downto 0);
        start : in std_logic;

        clock : in std_logic;
        reset : in std_logic;

        leds : out std_logic_vector(15 downto 0);

        outputScore : out std_logic_vector(7 downto 0);

        blanks : out std_logic_vector(3 downto 0)
    );
end entity MemoryGame;


architecture MemoryGame_ARCH of MemoryGame is

    ------------------------------------------------------------------------------------
    --constants and status signals
    ------------------------------------------------------------------------------------
    --this is subtracted from the toggling counter, making the blink faster
    signal countScaler : integer range 0 to 90_000_000; 

    --the ammount added to count countScaler after each win
    constant SCALE_AMOUNT : integer := 15_000_000;

    --the absolute max rate that the numbers can flash is once per second
    --countScaler subtracts this down to make the display faster.
    constant MAX_TOGGLE_COUNT : integer := 100_000_000;

    --1/4 second blinking rate for LosePattern, and WinPattern
    constant BLINK_COUNT : integer := 25_000_000;

    ------------------------------------------------------------------------------------
    --component definitions
    ------------------------------------------------------------------------------------
    component RandomNumbers is
        port(
            generateEN : in  std_logic;
            clock      : in  std_logic;
            reset      : in  std_logic;

            readyEN    : out std_logic;

            number0    : out std_logic_vector(3 downto 0);
            number1    : out std_logic_vector(3 downto 0);
            number2    : out std_logic_vector(3 downto 0);
            number3    : out std_logic_vector(3 downto 0);
            number4    : out std_logic_vector(3 downto 0)
        );
    end component RandomNumbers;

    component NumberChecker is
        port(
            switches    : in  std_logic_vector(15 downto 0);

            number0     : in  std_logic_vector(3 downto 0);
            number1     : in  std_logic_vector(3 downto 0);
            number2     : in  std_logic_vector(3 downto 0);
            number3     : in  std_logic_vector(3 downto 0);
            number4     : in  std_logic_vector(3 downto 0);

            readMode    : in  std_logic;

            clock       : in  std_logic;
            reset       : in  std_logic;

            gameOverEN  : out std_logic;
            gameWinEN   : out std_logic
        );
    end component NumberChecker;

    component WinPattern
        generic(BLINK_COUNT : natural);
        port(
            winPatternMode   : in  std_logic;
            reset            : in  std_logic;
            clock            : in  std_logic;
            leds             : out std_logic_vector(15 downto 0)
        );
    end component WinPattern;

    component LosePattern
        generic(BLINK_COUNT : natural);
        port(
            losePatternEN     : in  std_logic;
            reset             : in  std_logic;
            clock             : in  std_logic;
            leds              : out std_logic_vector(15 downto 0);
            losePatternIsBusy : out std_logic
        );
    end component LosePattern;

    component LedSegments
        port(
            binary4Bit : in  std_logic_vector(3 downto 0);
            outputEN   : in  std_logic;
            leds       : out std_logic_vector(15 downto 0)
        );
    end component LedSegments;

    component BCD
        port(
            binary4Bit  : in  std_logic_vector(3 downto 0);
            decimalOnes : out std_logic_vector(3 downto 0);
            decimalTens : out std_logic_vector(3 downto 0)
        );
    end component BCD;

    ------------------------------------------------------------------------------------
    -- connecting signals
    ------------------------------------------------------------------------------------
    --Signals for RNG_GENERATOR
    signal readyEN : std_logic;
    signal number0 : std_logic_vector(3 downto 0);
    signal number1 : std_logic_vector(3 downto 0);
    signal number2 : std_logic_vector(3 downto 0);
    signal number3 : std_logic_vector(3 downto 0);
    signal number4 : std_logic_vector(3 downto 0);
    signal outputNumber : std_logic_vector(3 downto 0);

    --Control signal for the RNG_GENERATOR
    signal startControl : std_logic;

    --Signals for CHECK_NUMBERS
    signal readMode : std_logic;
    signal nextRoundEN : std_logic;
    signal gameOverEN : std_logic;
    signal gameWinEN : std_logic;
    signal ledMode : std_logic;

    --Score represented as a integer and later converted to vector
    signal score : integer range 0 to 15;
    signal scoreVector : std_logic_vector(3 downto 0);

    --Level signal to make sure user cannot press the start button
    --while the lose pattern is playing.
    signal losePatternIsBusy : std_logic;

    --Timer controlled state signal
    signal SMTimer : integer;

    --Level controls for the win and lose patters
    signal loseMode : std_logic;
    signal winMode : std_logic;

begin


    ------------------------------------------------------------------------------------
    -- Random number generator component controlled by a combinational control signal
    ------------------------------------------------------------------------------------
    startControl <= (start and readMode and (not losePatternIsBusy)) or nextRoundEN;
    RNG_GENERATOR : component RandomNumbers port map(
        generateEN => startControl,

        clock      => clock,
        reset      => reset,

        --------------outputs
        readyEN    => readyEN,

        number0    => number0,
        number1    => number1,
        number2    => number2,
        number3    => number3,
        number4    => number4
    );

    ------------------------------------------------------------------------------------
    -- Number checker component that ouputs a pulse when all numbers intered are correct
    ------------------------------------------------------------------------------------
    CHECK_NUMBERS : component NumberChecker port map(
        switches    => switches,

        number0     => number0,
        number1     => number1,
        number2     => number2,
        number3     => number3,
        number4     => number4,

        readMode    => readMode,

        clock       => clock,
        reset       => reset,

        --------------outputs
        gameOverEN  => gameOverEN,
        gameWinEN   => gameWinEN
    );

    ------------------------------------------------------------------------------------
    -- Win pattern generator that is mode controlled, outpus a pulse to start next round
    ------------------------------------------------------------------------------------
    WIN_PATTERN_DRIVER : component WinPattern
        generic map(
            BLINK_COUNT => BLINK_COUNT
        )
        port map(
            winPatternMode   => winMode,
            reset            => reset,
            clock            => clock,

            --------------outputs
            leds             => leds
    );

    ------------------------------------------------------------------------------------
    -- Lose pattern generator that is pulse controlled, 
    -- ouputs a level control high if it is activley controlling the leds.
    ------------------------------------------------------------------------------------
    LOSE_PATTERN_DRRIVER : LosePattern
        generic map(
            BLINK_COUNT => BLINK_COUNT
        )
        port map(
            losePatternEN     => gameOverEN,
            reset             => reset,
            clock             => clock,

            --------------outputs
            leds              => leds,
            losePatternIsBusy => losePatternIsBusy
    );

    ------------------------------------------------------------------------------------
    -- Takes a 4 bit binary word and converts to a positional 16 bit wide vector for leds.
    -- This component drives all leds to Z if the outputMode port is low.
    ------------------------------------------------------------------------------------
    GAME_LED_DRIVER : LedSegments port map(
        binary4Bit => outputNumber,
        outputMode => ledMode, --if outputMode is low, then this output is (others => 'Z')

        --------------outputs
        leds       => leds
    );

    ------------------------------------------------------------------------------------
    -- Code conversion component to change a binary number to BCD
    ------------------------------------------------------------------------------------
    scoreVector <= std_logic_vector(to_unsigned(score, 4));
    SCORE_NUMBER_BCD : BCD port map(
        binary4Bit  => scoreVector,

        --------------outputs
        decimalOnes => outputScore(3 downto 0),
        decimalTens => outputScore(7 downto 4)
    );


    ------------------------------------------------------------------------------------
    -- Process that increments score and speed with each win.
    -- Whenever the gameOverEN signal pulses, the loseMode latch is set, which activates
    -- the LOSE_MODE_TIMER process.
    ------------------------------------------------------------------------------------
    GAME_DRIVER : process (clock, reset)
    begin
        if reset = '1' then
            score <= 0;
            countScaler <= 0;
            loseMode <= '0';
        elsif rising_edge(clock) then
            if gameWinEN  = '1' then
                score <= score + 1;
                if countScaler <= 90_000_000 then
                    countScaler <= countScaler + SCALE_AMOUNT;
                end if;
            end if;
            if gameOverEN = '1' then
                countScaler <= 0;
                loseMode <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Timer that handles blinking the final score until reset happens.
    -- This process can only run the LosePattern module if loseMode was set by GAME_DRIVER.
    ------------------------------------------------------------------------------------
    LOSE_MODE_TIMER : process(clock, reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT - 1;
        variable toggle : std_logic;
    begin
        if reset = '1' then
            counter := 0;
            toggle := '0';
        elsif rising_edge(clock) then
            if loseMode = '1' then
                counter := counter + 1;
                if (counter >= (MAX_TOGGLE_COUNT - 1)) then
                    toggle := not toggle;
                    counter := 0;
                end if;
                if toggle = '1' then
                    blanks <= "0011";
                elsif toggle = '0' then
                    blanks <= "1111";
                end if;

            elsif loseMode = '0' then
                counter := 0;
                blanks <= "0011";
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    --Timer that handles automatic start and level controlled win pattern.
    ------------------------------------------------------------------------------------
    WIN_MODE_TIMER : process(clock, reset)
        variable counter : integer range 0 to (2 * MAX_TOGGLE_COUNT) - 1;
        variable latch : std_logic;
        variable godMode : std_logic;
    begin
        if reset = '1' then
            counter := 0;
            latch := '0';
            nextRoundEN <= '0';
            godMode := '0';
        elsif rising_edge(clock) then

            --Once the number checker component sends the gameWinEN pulse
            --then the latch variable goes high. Same for the godMode latch.
            nextRoundEN <= '0';
            if gameWinEN = '1' then
                latch := '1';
            elsif score = 15 then
                godMode := '1';
            end if;

            --Depending if one latch or another was set, then then
            --mode controlled WinPattern component takes over the leds.
            if godMode = '1' then
                winMode <= '1';
            elsif latch = '1' then
                winMode <= '1';
                counter := counter + 1;
                if (counter >= ((2 * MAX_TOGGLE_COUNT) - 1)) then
                    latch := '0';
                    counter := 0;
                    nextRoundEN <= '1';
                end if;
            elsif latch = '0' then
                counter := 0;
                winMode <= '0';
            else 
                counter := 0;
                winMode <= '0';
            end if;
        end if;
    end process;


    ------------------------------------------------------------------------------------
    --Timer that directs the display the values of RNG_GENERATOR.
    ------------------------------------------------------------------------------------
    DISPLAY_SM_TIMER : process(clock,reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT - 1;
        variable countMode : std_logic;
    begin
        if reset = '1' then
            SMTimer <= 0;
            counter := 0;
            countMode := '0';
        elsif rising_edge(clock) then

            --The readyEN pulse from the RNG_GENERATOR component will latch this
            --internal variable high, enabling the next if statement.
            if readyEN = '1' then
                countMode := '1'; --latch in and start counting
            end if;

            --The counter variable reaches it's terminal value once each second.
            --Each time the terminal value is reached, the SMTimer signal increments.
            --After reaching that terminal value 9 times, it goes back to a steady state.
            if countMode = '1' then
                counter := counter + 1;
                if (counter >= (MAX_TOGGLE_COUNT - countScaler - 1)) then
                    SMTimer <= SMTimer + 1;
                    counter := 0;
                end if;
            elsif countMode = '0' then
                SMTimer <= 0;
                counter := 0;
            end if;

            if SMTimer = 10 then
                SMTimer <= 0;
                countMode := '0';
                counter := 0;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- State machine responsible for multiplexing the random number to leds
    -- in addition to writing control signals.
    -- This state machine was designed this way to cut down dignificantly on the
    -- unintentional latches of previous display state machine designs.
    ------------------------------------------------------------------------------------
    DISPLAY_SM : process(SMTimer, number0, number1, number2, number3, number4, loseMode) is
    begin
        case (SMTimer) is
            ------------------------------------------------------------------BLANK
            when 0 =>
                readMode <= '1';                --allow the start button to be pressed
                ledMode <= '0';                 --deactivate LedSegments component

            ------------------------------------------------------------------NUM1
            when 1 =>
                readMode <= '0';
                ledMode <= '1';                 --activate LedSegments component
                outputNumber <= number0;

            ------------------------------------------------------------------BLANK
            when 2 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate LedSegments component

            ------------------------------------------------------------------NUM2
            when 3 =>
                readMode <= '0';
                ledMode <= '1';                 --activate LedSegments component
                outputNumber <= number1;

            ------------------------------------------------------------------BLANK
            when 4 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate LedSegments component

            ------------------------------------------------------------------NUM3
            when 5 =>
                readMode <= '0';
                ledMode <= '1';                 --activate LedSegments component
                outputNumber <= number2;

            ------------------------------------------------------------------BLANK
            when 6 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate LedSegments component

            ------------------------------------------------------------------NUM4
            when 7 =>
                readMode <= '0';
                ledMode <= '1';                 --activate LedSegments component
                outputNumber <= number3;

            ------------------------------------------------------------------BLANK
            when 8 =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate LedSegments component

            ------------------------------------------------------------------NUM5
            when 9 =>
                readMode <= '0';
                ledMode <= '1';                 --activate LedSegments component
                outputNumber <= number4;

            ----------------------------------------------------------DEFAULT case
            when others =>
                readMode <= '0';
                ledMode <= '0';                 --deactivate LedSegments component

        end case;

    end process;

end architecture MemoryGame_ARCH;
