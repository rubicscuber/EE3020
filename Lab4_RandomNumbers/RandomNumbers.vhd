library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------------------------------
--Title: Lab_4_RandomNumbers
--Name: Nathaniel Roberts, Mitch Walker
--Date: 3/26/25
--Prof: Scott Tippens
--Desc: Random Number generator file
--      This file has 5 randomly chosen seeds for each counter.
--      All 5 counters continually count no matter the state of 
--      the other components in the design.
--
--      On the generateEN signal pulse, each counter will shift
--      its current value to the output and raise a ready flag.
--
--      The readyEN signal is the and of all ready flags.
------------------------------------------------------------------------------------


entity RandomNumbers is
    port (
    generateEN : in std_logic;
    reset : in std_logic;
    clock : in std_logic;

    number0 : out std_logic_vector(3 downto 0);
    number1 : out std_logic_vector(3 downto 0);
    number2 : out std_logic_vector(3 downto 0);
    number3 : out std_logic_vector(3 downto 0);
    number4 : out std_logic_vector(3 downto 0);

    readyEN : out std_logic
    );
end entity RandomNumbers;


architecture RandomNumbers_ARCH of RandomNumbers is

    ------------------------------------------------------------------------------------
    --seeds and ready signals
    ------------------------------------------------------------------------------------
    constant startSeed0 : integer := 11;
    constant startSeed1 : integer := 14;
    constant startSeed2 : integer := 10;
    constant startSeed3 : integer := 7;
    constant startSeed4 : integer := 3;

    signal num0Ready : std_logic;
    signal num1Ready : std_logic;
    signal num2Ready : std_logic;
    signal num3Ready : std_logic;
    signal num4Ready : std_logic;

begin

    ------------------------------------------------------------------------------------
    --Counter for number 0
    ------------------------------------------------------------------------------------
    GENERATE_NUM0 : process(clock, reset)
        variable count : unsigned(3 downto 0);
    begin
        if reset = '1' then
            number0 <= "0000";
            count := to_unsigned(startSeed0, 4);
            num0Ready <= '0';
        elsif rising_edge(clock) then
            count := count + 1;
            num0Ready <= '0';
            if generateEN = '1' then
                number0 <= std_logic_vector(count);
                num0Ready <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    --Counter for number 1
    ------------------------------------------------------------------------------------
    GENERATE_NUM1 : process(clock, reset)
        variable count : unsigned(3 downto 0);
    begin
        if reset = '1' then
            number1 <= "0000";
            count := to_unsigned(startSeed1, 4);
            num1Ready <= '0';
        elsif rising_edge(clock) then
            count := count + 1;
            num1Ready <= '0';
            if generateEN = '1' then
                number1 <= std_logic_vector(count);
                num1Ready <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    --Counter for number 2
    ------------------------------------------------------------------------------------
    GENERATE_NUM2 : process(clock, reset)
        variable count : unsigned(3 downto 0);
    begin
        if reset = '1' then
            number2 <= "0000";
            count := to_unsigned(startSeed2, 4);
            num2Ready <= '0';
        elsif rising_edge(clock) then
            count := count + 1;
            num2Ready <= '0';
            if generateEN = '1' then
                number2 <= std_logic_vector(count);
                num2Ready <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    --Counter for number 3
    ------------------------------------------------------------------------------------
    GENERATE_NUM3 : process(clock, reset)
        variable count : unsigned(3 downto 0);
    begin
        if reset = '1' then
            number3 <= "0000";
            count := to_unsigned(startSeed3, 4);
            num3Ready <= '0';
        elsif rising_edge(clock) then
            count := count + 1;
            num3Ready <= '0';
            if generateEN = '1' then
                number3 <= std_logic_vector(count);
                num3Ready <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    --Counter for number 4
    ------------------------------------------------------------------------------------
    GENERATE_NUM4 : process(clock, reset)
        variable count : unsigned(3 downto 0);
    begin
        if reset = '1' then
            number4 <= "0000";
            count := to_unsigned(startSeed4, 4);
            num4Ready <= '0';
        elsif rising_edge(clock) then
            count := count + 1;
            num4Ready <= '0';
            if generateEN = '1' then
                number4 <= std_logic_vector(count);
                num4Ready <= '1';
            end if;
        end if;
    end process;

    readyEN <= num0Ready and num1Ready and num2Ready and num3Ready and num4Ready;

end architecture RandomNumbers_ARCH;
