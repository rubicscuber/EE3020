library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


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

--    constant reg0 : std_logic_vector(3 downto 0) := "1000";
--    constant reg1 : std_logic_vector(3 downto 0) := "0100";
--    constant reg2 : std_logic_vector(3 downto 0) := "0010";
--    constant reg3 : std_logic_vector(3 downto 0) := "0001";
--    constant reg4 : std_logic_vector(3 downto 0) := "0110";

    constant startSeed0 : integer := 6;
    constant startSeed1 : integer := 3;
    constant startSeed2 : integer := 8;
    constant startSeed3 : integer := 13;
    constant startSeed4 : integer := 5;

    signal num0Ready : std_logic;
    signal num1Ready : std_logic;
    signal num2Ready : std_logic;
    signal num3Ready : std_logic;
    signal num4Ready : std_logic;

begin

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
