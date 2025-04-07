library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LosePattern is
    generic(BLINK_COUNT : natural); --(100000000/4)-1;
    port(
        
        --this port may need to be a level control depending on if there 
        --needs to be a set number of loops through this pattern
        --in the case that this is a pulse, this component should ouput a busy 
        --signal and have a set number of looping iterations of the pattern.
        losePatternStart : in std_logic; 

        reset: in std_logic;
        clock: in std_logic;

        --the outputs of all these seperate pattern drivers MUST be multiplexed on the design diagram
        --due to the fact that Z is not synthesizable on the fabric
        leds: out std_logic_vector(15 downto 0)

        --losePatternIsBusy : out std_logic;
    );
end LosePattern;

architecture LosePattern_ARCH of LosePattern is

    type States_t is (BLANK, PATTERN1, PATTERN2);
    signal currentState: States_t;
    signal nextState: States_t;

    constant ACTIVE: std_logic := '1';

    constant PATTERN0_LEDS : std_logic_vector(15 downto 0) := "0000000000000000";
    constant PATTERN1_LEDS : std_logic_vector(15 downto 0) := "1111111111111111";
    constant PATTERN2_LEDS : std_logic_vector(15 downto 0) := "0000000000000000";

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

    WIN_PATTERN_SM: process(currentState, stateMachineControl, losePatternStart)
    begin
        if losePatternStart = ACTIVE then
            case CurrentState is
                when BLANK => 
                    leds <= PATTERN0_LEDS;
                    if (stateMachineControl = ACTIVE) then
                        nextState <= PATTERN1;
                    end if;

                when PATTERN1 =>
                    leds <= PATTERN1_LEDS;
                    if (stateMachineControl = not ACTIVE) then
                        nextState <= PATTERN2;
                    else
                        nextState <= PATTERN1;
                    end if;

                when PATTERN2 =>
                    leds <= PATTERN2_LEDS;
                    if (stateMachineControl = ACTIVE) then
                        nextState <= PATTERN1;
                    else
                        nextState <= PATTERN2;
                    end if;
            end case;

        end if;
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

end LosePattern_ARCH;

