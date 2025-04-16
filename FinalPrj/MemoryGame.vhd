library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Types_package.all; --TODO: remove types_package, only states needed are in the DISPLAY_STATE_MACHINE process

------------------------------------------------------------------------------------
--Title: 
--Name: Nathaniel Roberts, Mitch Walker
--Date: 
--Prof: Scott Tippens
--Desc: Memory Game design file
--      
--      
--      
------------------------------------------------------------------------------------

entity MemoryGame is
    port(
        switches : in std_logic_vector(15 downto 0);
        start : in std_logic;
        
        clock : in std_logic;
        reset : in std_logic;

        leds : out std_logic_vector(15 downto 0);

        outputGameNumber : out std_logic_vector(7 downto 0);
        outputScore : out std_logic_vector(7 downto 0);

        blanks : out std_logic_vector(3 downto 0)
    );
end entity MemoryGame;


architecture MemoryGame_ARCH of MemoryGame is

    --this is subtracted from the toggling counter, making in toggle faster
    signal countScaler : integer range 0 to 90_000; 

    --the ammount added to count countScaler after each win
    constant SCALE_AMOUNT : integer := 15_000;
    
    --the absolute max rate that the numbers can flash
    constant MAX_TOGGLE_COUNT : integer := 100_000;

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

            gameState   : in  GameStates_t;

            clock       : in  std_logic;
            reset       : in  std_logic;

            nextRoundEN : out std_logic;
            gameOverEN  : out std_logic;
            gameWinEN   : out std_logic
        );
    end component NumberChecker;

    component WinPattern
        generic(BLINK_COUNT : natural);
        port(
            winPatternEN     : in  std_logic;
            reset            : in  std_logic;
            clock            : in  std_logic;
            leds             : out std_logic_vector(15 downto 0);
            winPatternIsBusy : out std_logic
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

    component BarLedDriver_Basys3
        port(
            binary4Bit : in  std_logic_vector(3 downto 0);
            outputEN   : in  std_logic;
            leds       : out std_logic_vector(15 downto 0)
        );
    end component BarLedDriver_Basys3;

    component BCD
        port(
            binary4Bit  : in  std_logic_vector(3 downto 0);
            decimalOnes : out std_logic_vector(3 downto 0);
            decimalTens : out std_logic_vector(3 downto 0)
        );
    end component BCD;

    --general signals for design
    signal tpsToggle : std_logic;
    signal tpsModeControl : std_logic;
    signal tpsToggleShift : std_logic;

    --signals for RNG_GENERATOR
    signal readyEN : std_logic;
    signal number0 : std_logic_vector(3 downto 0);
    signal number1 : std_logic_vector(3 downto 0);
    signal number2 : std_logic_vector(3 downto 0);
    signal number3 : std_logic_vector(3 downto 0);
    signal number4 : std_logic_vector(3 downto 0);

    
    --signals for number checker
    signal readMode : std_logic;
    signal nextRoundEN : std_logic;
    signal gameOverEN : std_logic;
    signal gameWinEN : std_logic;
    signal ledMode : std_logic;

    --game state signals
    signal currentGameState : GameStates_t;

    --display state signals
    signal currentDisplayState : DisplayStates_t;
    signal nextDisplayState : DisplayStates_t;

    signal score : integer range 0 to 15;

    signal winPatternIsBusy : std_logic;
    signal losePatternIsBusy : std_logic;
    
    signal outputNumber : std_logic_vector(3 downto 0);
    signal startControl : std_logic;
    
    signal scoreVector : std_logic_vector(3 downto 0);

    signal SMTimer : integer;

begin
    --startControl <= start and inputControl and (not winPatternIsBusy) and (not losePatternIsBusy);
    startControl <= start and (not winPatternIsBusy) and (not losePatternIsBusy);
    RNG_GENERATOR : component RandomNumbers port map(
        generateEN => startControl,

        clock      => clock,
        reset      => reset,

        readyEN    => readyEN,

        number0    => number0,
        number1    => number1,
        number2    => number2,
        number3    => number3,
        number4    => number4
    );

    currentGameState <= ROUND5;

    CHECK_NUMBERS : component NumberChecker port map(
        switches    => switches,

        number0     => number0,
        number1     => number1,
        number2     => number2,
        number3     => number3,
        number4     => number4,

        readMode    => readMode,
        gameState   => currentGameState, --TODO: change this port and change NumberChecker functionality

        clock       => clock,
        reset       => reset,

        nextRoundEN => nextRoundEN,
        gameOverEN  => gameOverEN,
        gameWinEN   => gameWinEN
    );
    
    WIN_PATTERN_DRIVER : component WinPattern
        generic map(
            BLINK_COUNT => 25_000_000 - 1 --quarter second sequence
        )
        port map(
            winPatternEN     => gameWinEN,
            reset            => reset,
            clock            => clock,
            leds             => leds,
            winPatternIsBusy => winPatternIsBusy
    );
    
    LOSE_PATTERN_DRRIVER : LosePattern
        generic map(
            BLINK_COUNT => 25_000_000 - 1 --quarter second sequence
        )
        port map(
            losePatternEN     => gameOverEN,
            reset             => reset,
            clock             => clock,
            leds              => leds,
            losePatternIsBusy => losePatternIsBusy
    );

    GAME_LED_DRIVER : BarLedDriver_Basys3 port map(
        binary4Bit => outputNumber,
        outputEN   => ledMode,
        leds       => leds
    );
    
    scoreVector <= std_logic_vector(to_unsigned(score, 4));
    SCORE_NUMBER_BCD : BCD port map(
        binary4Bit  => scoreVector,
        decimalOnes => outputScore(3 downto 0),
        decimalTens => outputScore(7 downto 4)
    );
    
    GAME_NUMBER_BCD : BCD port map(
            binary4Bit  => outputNumber,
            decimalOnes => outputGameNumber(3 downto 0),
            decimalTens => outputGameNumber(7 downto 4)
    );
    
    --TODO: increment the clock speed in this process
    ------------------------------------------------------------------------------------
    -- Process that increments score with each successful win
    ------------------------------------------------------------------------------------   
    GAME_DRIVER : process (clock, reset)
    begin
        if reset = '1' then
            score <= 0;
            countScaler <= 0;
        elsif rising_edge(clock) then
            if gameWinEN  = '1' then
                score <= score + 1;
            end if;
            if gameOverEN = '1' then
                score <= 0;
            end if;
        end if;
    end process;

--    ------------------------------------------------------------------------------------
--    --
--    ------------------------------------------------------------------------------------
--    TPS_TOGGLER : process(clock, reset)
--        variable counter : integer range 0 to MAX_TOGGLE_COUNT; 
--    begin
--        if reset = '1' then
--            counter := 0;
--            tpsToggle <= '0';
--        elsif rising_edge(clock) then
--            if tpsModeControl = '1' then
--                counter := counter + 1;
--                if counter >= (MAX_TOGGLE_COUNT - countScaler) then
--                    tpsToggle <= not tpsToggle;
--                    counter := 0;
--                end if;
--            end if;
--            if tpsModeControl = '0' then
--                counter := 0;
--                tpsToggle <= '0';
--            end if;
--        end if;
--    end process;
--
--    ------------------------------------------------------------------------------------
--    --
--    ------------------------------------------------------------------------------------
--    TPS_TOGGLE_SHIFTER : process(clock, reset)
--    begin
--        if reset = '1' then
--            tpsToggleShift <= '0';
--        elsif rising_edge(clock) then
--            tpsToggleShift <= tpsToggle;
--        end if;
--    end process;

    ------------------------------------------------------------------------------------
    -- The state register keeps the state machine synchronized with the clock.
    ------------------------------------------------------------------------------------
    DISPLAY_STATE_REG : process(clock, reset)
    begin
        if reset = '1' then
            currentDisplayState <= IDLE;
        elsif rising_edge(clock) then
            currentDisplayState <= nextDisplayState;
        end if;
    end process;

    DISPLAY_SM_TIMER : process(clock,reset)
        variable counter : integer range 0 to MAX_TOGGLE_COUNT - 1;
    begin
        if reset = '1' then
            SMTimer <= 0;
            counter := 0;
        elsif rising_edge(clock) then
            if tpsModeControl = '1' then
                counter := counter + 1;
                if (counter >= (MAX_TOGGLE_COUNT - 1)) then
                    SMTimer <= SMTimer + 1;
                    counter := 0;
                end if;
            elsif tpsModeControl = '0' then
                counter := 0;
                SMTimer <= 0;
            end if;
        end if;
    end process;
    ------------------------------------------------------------------------------------
    -- State machine responsible for driving the main number output
    ------------------------------------------------------------------------------------
    DISPLAY_STATE_MACHINE : process (currentDisplayState, readyEN, SMTimer,
                                    number0, number1, number2, number3, number4)
    begin
        case (currentDisplayState) Is
            ------------------------------------------------------------------BLANK
            when IDLE =>
                tpsModeControl <= '0';     --turn off counter and reset it
                blanks <= "0011";          --deactivate segments
                ledMode <= '0';            --deactivate leds
                readMode <= '1';
                if readyEN = '1' then
                    nextDisplayState <= NUM1;
                end if;

            ------------------------------------------------------------------NUM1
            when NUM1 =>
                tpsModeControl <= '1';
                readMode <= '0';
                outputNumber <= number0;
                if (SMTimer = 0) then
                    ledMode <= '1';                 --activate leds
                    blanks <= (others => '0');      --activate segments
                    nextDisplayState <= NUM1;   --stay 
                elsif (SMTimer = 1) then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM2;   --move 
                else
                    nextDisplayState <= NUM1;   --handle metavalues
                end if;

            ------------------------------------------------------------------NUM2
            when NUM2 =>
                tpsModeControl <= '1';
                readMode <= '0';
                outputNumber <= number1;
                if (SMTimer = 2) then
                    ledMode <= '1';                 --activate leds
                    blanks <= (others => '0');      --activate segments
                    nextDisplayState <= NUM2;   --stay 
                elsif (SMTimer = 1) then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM2;   --stay 
                elsif (SMTimer = 3) then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM3;   --move
                else
                    nextDisplayState <= NUM2;   --handle metavalues
                end if;


            ------------------------------------------------------------------NUM3
            when NUM3 =>
                tpsModeControl <= '1';
                readMode <= '0';
                outputNumber <= number2;
                if (SMTimer = 4) then
                    ledMode <= '1';                 --activate leds
                    blanks <= (others => '0');      --activate segments
                    nextDisplayState <= NUM3;   --stay 
                elsif SMTimer = 3 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM3;   --stay 
                elsif SMTimer = 5 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM4;   --move
                else
                    nextDisplayState <= NUM3;   --handle metavalues
                end if;


            ------------------------------------------------------------------NUM4
            when NUM4 =>
                tpsModeControl <= '1';
                readMode <= '0';
                outputNumber <= number3;
                if (SMTimer = 6) then
                    ledMode <= '1';                 --activate leds
                    blanks <= (others => '0');      --activate segments
                    nextDisplayState <= NUM4;   --stay 
                elsif SMTimer = 5 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM4;   --stay 
                elsif SMTimer = 7 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM5;   --move 
                else
                    nextDisplayState <= NUM4;   --handle metavalues
                end if;


            ------------------------------------------------------------------NUM5
            when NUM5 =>
                tpsModeControl <= '1';
                readMode <= '0';
                outputNumber <= number4;
                if (SMTimer = 8) then
                    ledMode <= '1';                 --activate leds
                    blanks <= (others => '0');      --activate segments
                    nextDisplayState <= NUM5;   --stay 
                elsif SMTimer = 7 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= NUM5;   --stay 
                elsif SMTimer = 9 then
                    ledMode <= '0';                 --deactivate leds
                    blanks <= "0011";               --deactivate segments
                    nextDisplayState <= IDLE;   --move 
                else
                    nextDisplayState <= NUM5;   --handle metavalues
                end if;

        end case;
    end process;



end architecture MemoryGame_ARCH;
