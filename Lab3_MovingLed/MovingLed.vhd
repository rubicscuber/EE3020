library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_3_MovingLed
--Name: Nathaniel Roberts
--Date: 
--Prof: Scott Tippens
--Desc: 
--      
--      
--      
------------------------------------------------------------

entity MovingLed is
    port (
        leftButton  : in std_logic;
        rightButton : in std_logic;
        resetButton : in std_logic;
        clock : in std_logic;

        position    : out std_logic_vector(3 downto 0)
    );
end MovingLed;

architecture MovingLed_ARCH of MovingLed is

    signal inputState : std_logic;

    --shift register made from two seperate registers
    --reg0InputState is updated in SCAN_INPUT_STATE
    --reg1InputState gets shifted with reg0InputState in UPDATE_POSITION
    signal reg0InputState : std_logic := '0';
    signal reg1InputState : std_logic := '1';

    signal regLeft : std_logic;
    signal regRight : std_logic;
    signal regPosition : unsigned (3 downto 0) := "0000";
    signal countDirection : std_logic;

    constant DELAY_COUNT : integer := 1000000; --10ms on a 100MHz clock (0.01s) = 1M
    signal counter : integer range 0 to DELAY_COUNT;


begin

    --async signal thats used in SCAN_INPUT_STATE to update reg0InputState
    inputState <= regLeft or regRight; 

    ------------------------------------------------------------
    --Updates a register of the inputstate once per button press
    --buttons pressed suimultaniously wont do anything
    ------------------------------------------------------------
    DEBOUNCE : process(clock)
    begin
        if rising_edge(clock) then
            if inputState /= reg0InputState and counter < DELAY_COUNT then
                counter <= counter + 1;
            elsif counter = DELAY_COUNT then
                reg0InputState <= inputState;
                counter <= 0;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    UP_DOWN_COUNTER : process(clock, resetButton)
    begin
        if resetButton = '1' then
            regPosition <= (others => '0');
        elsif rising_edge(clock) then
            if (reg0InputState = '1') and (reg1InputState = '0') then --count enable
                if (countDirection = '1') and (regPosition < 15) then
                    regPosition <= regPosition + 1;
                elsif(countDirection = '0') and (regPosition > 0) then 
                    regPosition <= regPosition - 1;
                end if;
            end if;
        end if;
    end process;

    SHIFT_REGISTERS : process(clock)
    begin
        if rising_edge(clock) then
            --shift registers each clock cycle
            reg1InputState <= reg0InputState;
        end if;
    end process;

    UP_DOWN_COUNTER_CONTROL : process (clock)
    begin
        if rising_edge(clock) then
            --store the direction in a countDirection register
            if (regLeft = '1') and (regRight = '0') then
                countDirection <= '1';
            end if;
            if (regLeft = '0') and (regRight = '1') then
                countDirection <= '0';
            end if;
        end if;
    end process;


    UPDATE_LEFT_REG : process(clock)
    begin
        if rising_edge(clock) then
            if leftButton = '1' then
                regLeft <= '1';
            else
                regLeft <= '0';
            end if;
        end if;
    end process;

    UPDATE_RIGHT_REG : process(clock)
    begin
        if rising_edge(clock) then
            if rightButton = '1' then
                regRight <= '1';
            else
                regRight <= '0';
            end if;
        end if;
    end process;

    position <= std_logic_vector(regPosition);

end architecture MovingLed_ARCH;

