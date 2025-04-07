library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WinPattern is
    generic(BLINK_COUNT : natural); --(100000000/4)-1;
    port(

        --this port may need to be a level control depending on if there 
        --needs to be a set number of loops through this pattern
        --in the case that this is a pulse, this component should ouput a busy 
        --signal and have a set number of looping iterations of the pattern.
        winPatternEN : in std_logic; 

        reset: in std_logic;
        clock: in std_logic;

        --the outputs of all these seperate pattern drivers MUST be multiplexed on the design diagram
        --due to the fact that Z is not synthesizable on the fabric
        leds: out std_logic_vector(15 downto 0);

        winPatternIsBusy : out std_logic
    );
end WinPattern;

architecture WinPattern_ARCH of WinPattern is

    type States_t is (BLANK, PATTERN0, PATTERN1);
    signal currentState: States_t;
    signal nextState: States_t;

    constant ACTIVE: std_logic := '1';

    constant BLANK_LEDS : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";
    constant PATTERN0_LEDS : std_logic_vector(15 downto 0) := "1010101010101010";
    constant PATTERN1_LEDS : std_logic_vector(15 downto 0) := "0101010101010101";

    signal stateMachineControl: std_logic;

begin

    STATE_REGISTER: process(reset, clock)
        begin
            if (reset=ACTIVE) then
                currentState <= BLANK;
            elsif (rising_edge(clock)) then
                currentState <= nextState;
            end if;
    end process;

    WIN_PATTERN_SM: process(currentState, stateMachineControl, winPatternEN)
    variable loopCounter : integer range 0 to 8;
    
    begin
        case CurrentState is
            when BLANK => 
                leds <= BLANK_LEDS;
                loopCounter := 0;
                winPatternIsBusy <= not ACTIVE;
                if (winPatternEN = ACTIVE) then
                    nextState <= PATTERN0;
                end if;

            when PATTERN0 =>
                leds <= PATTERN0_LEDS;
                winPatternIsBusy <= ACTIVE;
                if loopCounter = 8 then
                    nextState <= BLANK;
                elsif (stateMachineControl = not ACTIVE) then
                    nextState <= PATTERN1;
                    loopCounter := loopCounter + 1;
                else
                    nextState <= PATTERN0;
                end if;

            when PATTERN1 =>
                leds <= PATTERN1_LEDS;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN0;
                else
                    nextState <= PATTERN1;
                end if;
        end case;
    end process;

    DISPLAY_RATE: process(reset, clock)
        variable count: integer range 0 to BLINK_COUNT;
    begin
        if (reset = ACTIVE) then
            count := 0;
            stateMachineControl <=  not ACTIVE;
        elsif (rising_edge(clock)) then
            if (count >= BLINK_COUNT) then
                count := 0;
                stateMachineControl <= not stateMachineControl;
            else
                count := count + 1;
            end if;
        end if;
    end process DISPLAY_RATE;

end WinPattern_ARCH;
