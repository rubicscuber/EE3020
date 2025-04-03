library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WinPattern is
    generic(BLINK_COUNT : natural) --(100000000/4)-1;
    port(
        winPatternStart : in std_logic;

        reset: in std_logic;
        clock: in std_logic;

        leds: out std_logic_vector(15 downto 0)

        --winPatternIsBusy : out std_logic;
    );
end WinPattern;

architecture WinPattern_ARCH of WinPattern is

    type States_t is (BLANK, PATTERN1, PATTERN2);
    signal currentState: States_t;
    signal nextState: States_t;

    constant ACTIVE: std_logic := '1';

    constant PATTERN0_LEDS : std_logic_vector(15 downto 0) := "0000000000000000";
    constant PATTERN1_LEDS : std_logic_vector(15 downto 0) := "1010101010101010";
    constant PATTERN2_LEDS : std_logic_vector(15 downto 0) := "0101010101010101";

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

    WIN_PATTERN_SM: process(currentState, toggle)
    begin
        case CurrentState is
            when BLANK => 
                leds <= PATTERN0_LEDS;
                if (stateMachineControl = ACTIVE) then
                    nextState <= PATTERN1;
                end if;

            when PATTERN1 =>
                leds <= PATTERN1_LEDS;
                if (stateMachineControl=ACTIVE) then
                    nextState <= PATTERN2;
                else
                    nextState <= PATTERN1;
                end if;

            when PATTERN2
                leds <= PATTERN2_LEDS;
                if (stateMachineControl=ACTIVE) then
                    nextState <= PATTERN1
                else
                    nextState <= PATTERN2;
                end if;
        end case;
    end process;

    BLINK_RATE: process(reset, clock)
        variable count: integer range 0 to BLINK_COUNT;
    begin
        --manage-count-value--------------------------------------------
        if (reset = ACTIVE) then
            count := 0;
        elsif (rising_edge(clock)) then
            if (count = COUNT_4HZ) then
                count := 0;
            else
                count := count + 1;
            end if;
        end if;

        --update-enable-signal-------------------------------------------
        stateMachineControl <= not ACTIVE;
        if (count=COUNT_4HZ) then
            stateMachineControl <= ACTIVE;
        end if;
    end process BLINK_RATE;

end WinPattern_ARCH;
