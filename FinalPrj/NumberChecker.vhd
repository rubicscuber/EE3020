library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------------
--Title: NumberChecker.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/25/25
--Prof: Scott Tippens
--Desc: Number Checker component
--      The component will output a pulse on one of three pins to indicate if 
--      the user made all the correct entries or made an error.

--      When there are 5 numbers to check, the gameWinEN gets a pulse 
--      if all are entered correctly.

--      At any point a wrong number is made, gameOverEN gets a pulse.
------------------------------------------------------------------------------------


entity NumberChecker is
    port(
        switches : in std_logic_vector(15 downto 0); --the pulsed switch inputs go here

        number0 : in std_logic_vector(3 downto 0);
        number1 : in std_logic_vector(3 downto 0);
        number2 : in std_logic_vector(3 downto 0);
        number3 : in std_logic_vector(3 downto 0);
        number4 : in std_logic_vector(3 downto 0);

        readMode : in std_logic;     -- pull this port low when the display is used

        clock : in std_logic;
        reset : in std_logic;

        gameOverEN : out std_logic;
        gameWinEN : out std_logic
    );
end entity NumberChecker;

architecture NumberChecker_ARCH of NumberChecker is
    signal compare : integer range 0 to 16;

    signal num0 : integer range 0 to 16; 
    signal num1 : integer range 0 to 16; 
    signal num2 : integer range 0 to 16; 
    signal num3 : integer range 0 to 16; 
    signal num4 : integer range 0 to 16; 

    signal progressCounter : natural range 1 to 5;

begin

    with switches select
        compare <= 1 when "0000000000000001",
                   2 when "0000000000000010",
                   3 when "0000000000000100",
                   4 when "0000000000001000",
                   5 when "0000000000010000",
                   6 when "0000000000100000",
                   7 when "0000000001000000",
                   8 when "0000000010000000",
                   9 when "0000000100000000",
                  10 when "0000001000000000",
                  11 when "0000010000000000",
                  12 when "0000100000000000",
                  13 when "0001000000000000",
                  14 when "0010000000000000",
                  15 when "0100000000000000",
                  16 when "1000000000000000",
                   0 when others;

    num0 <= to_integer(unsigned(number0)) + 1;
    num1 <= to_integer(unsigned(number1)) + 1;
    num2 <= to_integer(unsigned(number2)) + 1;
    num3 <= to_integer(unsigned(number3)) + 1;
    num4 <= to_integer(unsigned(number4)) + 1;


    ------------------------------------------------------------------------------------
    -- Main number checker process:
    -- procressCounter keeps track of which number needs to be checked
    -- Each if statement will exit by pulling gameOverEN low if the numx mismatches compare
    -- Inputs are ignored if no switches are active during any rising_edge()
    ------------------------------------------------------------------------------------
    CHECK_NUMBERS : process(clock, reset)
    begin
        if reset = '1' then
            gameOverEN <= '0';
            gameWinEN <= '0';
            progressCounter <= 1;
        elsif rising_edge(clock) then
            gameOverEN <= '0';
            gameWinEN <= '0';

            if (readMode = '1') and (to_integer(unsigned(switches)) > 0) then

                if progressCounter = 1 then
                    if compare = num0 then
                        progressCounter <= progressCounter + 1;
                    else
                        gameOverEN <= '1';
                        progressCounter <= 1;
                    end if;
                elsif progressCounter = 2 then
                    if compare = num1 then
                        progressCounter <= progressCounter + 1;
                    else 
                        gameOverEN <= '1';
                        progressCounter <= 1;
                    end if;
                elsif progressCounter = 3 then
                    if compare = num2 then
                        progressCounter <=  progressCounter + 1;
                    else 
                        gameOverEN <= '1';
                        progressCounter <= 1;
                    end if;
                elsif progressCounter = 4 then
                    if compare = num3 then
                        progressCounter <=  progressCounter + 1;
                    else 
                        gameOverEN <= '1';
                        progressCounter <= 1;
                    end if;
                elsif progressCounter = 5 then
                    if compare = num4 then
                        gameWinEN <= '1';
                        progressCounter <= 1;
                    else 
                        gameOverEN <= '1';
                        progressCounter <= 1;
                    end if;
                end if;
            end if;
        end if;
   end process;

end architecture NumberChecker_ARCH;
