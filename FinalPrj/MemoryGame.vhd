library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types_package.all;

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
        clock : in std_logic;
        reset : in std_logic


    );
end entity MemoryGame;


architecture MemoryGame_ARCH of MemoryGame is
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
begin
    ------------------------------------------------------------------------------------
    -- This process toggles a level control signal (tps_toggle) each second.
    -- The process is enabled by the tps_mode level control.
    -- 
    -- If the state machine is in the BLANK state, the counter is 0 and is deactivated
    -- If the state machine is outside of the BLANK state, then the counter is active
    --
    -- These next two processes are what make the state machine change every second and
    -- also enable the numbers to be displayed.
    ------------------------------------------------------------------------------------
    TPS_TOGGLER : process(clock, reset)
        variable counter : integer range 0 to TPS_MAX_COUNT;
    begin
       if reset = '1' then
            counter := 0;
            tpsToggle <= '0';
       elsif rising_edge(clock) then
            if tpsModeControl = '1' then
                counter := counter + 1;
                if counter >= TPS_MAX_COUNT then
                    tpsToggle <= not tpsToggle;
                    counter := 0;
                end if;
            end if;
            if tpsModeControl = '0' then
                counter := 0;
                tpsToggle <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- tps_toggle is shifted with this flip flop.
    --
    -- The state machine will read the value of tps_toggle and tps_toggle_shift meaning
    -- it will transition only if tps_toggle went from low to high.
    ------------------------------------------------------------------------------------
    TPS_TOGGLE_SHIFTER : process(clock, reset)
    begin
        if reset = '1' then
            tpsToggleShift <= '0';
        elsif rising_edge(clock) then
            tpsToggleShift <= tpsToggle;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The state register keeps the state machine synchronized with the clock.
    ------------------------------------------------------------------------------------
    STATE_REG : process(clock, reset)
    begin
        if reset = '1' then
            currentState <= WAIT_FOR_READY;
        elsif rising_edge(clock) then
            currentState <= nextState;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The main state machine.
    --
    -- This process has a steady state at BLANK and is kicked out of that state when
    -- it gets the readyEN pulse, after that it marches onto each state given by the 
    -- tps_toggle signal. 
    --
    -- The state machine only reads the vaue of the readyEN pulse at the default state
    -- and ignores that signal at all other times.
    --
    -- It also controls when the LOAD_IN_NUMBERS process runs.
    ------------------------------------------------------------------------------------
    CONRTOL_STATE_MACHINE : process (currentState, readyEN, tpsToggle, tpsToggleShift)
    begin
        case (currentState) Is
            ------------------------------------------BLANK
            when WAIT_FOR_READY =>
                tpsModeControl <= '0';     --turn off counter and reset it
                blanks <= (others => '1'); --deactivate segments
                ledMode <= '0';            --deactivate leds

                if readyEN = '1' then      --readyEN kicks off the state machine
                    nextState <= NUM0;
                else 
                    nextState <= WAIT_FOR_READY;
                end if;
            -------------------------------------------NUM0
            when NUM0 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number0Register;
                    nextState <= NUM0;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM1;
                end if;
            -------------------------------------------NUM1
            when NUM1 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number1Register;
                    nextState <= NUM1;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM2;
                end if;
            -------------------------------------------NUM2
            when NUM2 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number2Register;
                    nextState <= NUM2;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM3;
                end if;
            -------------------------------------------NUM3
            when NUM3 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number3Register;
                    nextState <= NUM3;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM4;
                end if;
            -------------------------------------------NUM4
            when NUM4 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number4Register;
                    nextState <= NUM4;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= WAIT_FOR_READY;
                end if;
        end case;
    end process;

end architecture MemoryGame_ARCH;
