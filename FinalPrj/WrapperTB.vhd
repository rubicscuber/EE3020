library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity WrapperTB is
end entity ;

architecture behavioral of WrapperTB is

    --note generaic map of this component MUST match the entity in MemoryGame_Basys3.vhd
    component MemoryGame_Basys3 is
    generic(
        NUM_OF_SWITCHES : positive := 16;
        CHAIN_SIZE : positive := 2;
        DELAY_COUNT : positive := 10_000 --10ms on a 100MHz clock = 1M
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

    signal sw   : std_logic_vector(15 downto 0) := (others => '0');
    signal btnC : std_logic := '0';
    signal btnD : std_logic;
    signal clk  : std_logic;

    signal led : std_logic_vector(15 downto 0);
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(6 downto 0);

begin

    UUT : MemoryGame_Basys3 
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
        wait for 1.9 ms;
        btnC <= '1';
        wait for 500 us;
        btnC <= '0';
        
        wait for 10 ms;
        sw(15) <= '1';
        wait for 200 us;
        sw(15) <= '0';
        wait for 200 us;
        sw(14) <= '1';
        wait for 200 us;
        sw(14) <= '0';
        wait for 200 us;
        sw(9) <= '1';
        wait for 200 us;
        sw(9) <= '0';
        wait for 200 us;
        sw(4) <= '1';
        wait for 200 us;
        sw(4) <= '0';
        wait for 200 us;
        sw(15) <= '1';
        wait for 200 us;
        sw(15) <= '0';
 
        wait;
    end process;

end architecture behavioral;

