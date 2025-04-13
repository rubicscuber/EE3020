library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity WrapperTB is
end entity ;

architecture behavioral of WrapperTB is

    component MemoryGame_Basys3 is
    generic(
        NUM_OF_SWITCHES : positive := 16;
        CHAIN_SIZE : positive := 2;
        DELAY_COUNT : positive := 100000 --10ms on a 100MHz clock = 1M
        );
    port(
        sw : in std_logic_vector(NUM_OF_SWITCHES-1 downto 0);
        btnC : in std_logic; --start/restart button
        btnD : in std_logic; --reset/blanks the screens
        clk : in std_logic;

        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
    end component;

    signal sw   : std_logic_vector(15 downto 0);
    signal btnC : std_logic;
    signal btnD : std_logic;
    signal clk  : std_logic;

    signal led : std_logic_vector(15 downto 0);
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);

begin

    UUT : MemoryGame_Basys3 
        generic map(
            NUM_OF_SWITCHES => 16,
            CHAIN_SIZE => 2,
            DELAY_COUNT => 100000
        )
        port map(

            sw   =>  sw,
            btnC =>  btnC,
            btnD =>  btnD,
            clk  =>  clk ,

            led  => led,
            an   => an,
            seg  => seg
        );

    CLOCK_GEN : process is
    begin
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
    end process;

    RESET_GEN : process is
    begin
        btnD <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        btnD <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        btnD <= '0';
        wait;
    end process;

    stumulus : process is
    begin
        wait for 1 ms;
        btnC <= '1';
        wait for 4 ms;
        btnC <= '0';
        wait;
    end process;

end architecture behavioral;

