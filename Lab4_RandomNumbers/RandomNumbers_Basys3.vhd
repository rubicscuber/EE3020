library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RandomNumbers_Basys3 is
    port(
        btnC : in std_logic;
        btnD : in std_logic;
        clk : in std_logic;

        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end entity;


architecture RandomNumbers_Basys3_ARCH of RandomNumbers_Basys3 is

    component RandomNumbers is
        port (
        generateButton : in std_logic;
        reset : in std_logic;
        clock : in std_logic;

        number0 : out std_logic_vector(3 downto 0);
        number1 : out std_logic_vector(3 downto 0);
        number2 : out std_logic_vector(3 downto 0);
        number3 : out std_logic_vector(3 downto 0);
        number4 : out std_logic_vector(3 downto 0);

        readyEN : out std_logic
        );
    end component;

    --each number is displayed once per second
    constant TPS_MAX_COUNT : integer := 100000000;
    signal tps_toggle : std_logic;
    signal tps_mode : std_logic;

    --signals that connect the ports to each DFF
    signal number0_signal : std_logic_vector(3 downto 0);
    signal number1_signal : std_logic_vector(3 downto 0);
    signal number2_signal : std_logic_vector(3 downto 0);
    signal number3_signal : std_logic_vector(3 downto 0);
    signal number4_signal : std_logic_vector(3 downto 0);
    --registers of the 5 numbers
    signal number0_reg : std_logic_vector(3 downto 0);
    signal number1_reg : std_logic_vector(3 downto 0);
    signal number2_reg : std_logic_vector(3 downto 0);
    signal number3_reg : std_logic_vector(3 downto 0);
    signal number4_reg : std_logic_vector(3 downto 0);
    --state machine types
    type States_t is (BLANK, NUM0, NUM1, NUM2, NUM3, NUM4);
    signal currentNumber : States_t; 
    signal nextNumber : States_t; 

    --one pulse wide ready signal
    signal readyEN : std_logic;

    --select line for MUX
    signal selectLine : std_logic_vector(2 downto 0);


    constant BLANK_LEDS : std_logic_vector(15 downto 0) := "0000000000000000";

begin

    RNG_GENERATOR : RandomNumbers port map(
        generateButton => btnD,
        reset => btnC,
        clock => clk,

        number0 => number0_signal, 
        number1 => number1_signal, 
        number2 => number2_signal,
        number3 => number3_signal,
        number4 => number4_signal,

        readyEN => readyEN
    );    

    LOAD_IN_NUMBERS : process(clk, btnC)
    begin
        if btnD = '1' then
            number0_reg <= (others => '0');
            number1_reg <= (others => '0');
            number2_reg <= (others => '0');
            number3_reg <= (others => '0');
            number4_reg <= (others => '0');
       elsif rising_edge(clk) then
            if readyEN = '1' then
                number0_reg <= number0_signal;
                number1_reg <= number1_signal;
                number2_reg <= number2_signal;
                number3_reg <= number3_signal;
                number4_reg <= number4_signal;
            end if;
       end if;
    end process;
    
    TPS_TOGGLER : process(clk, btnC)
        variable counter : integer range 0 to TPS_MAX_COUNT;
    begin
       if btnD = '1' then
            counter := 0;
            tps_toggle <= '0';
       elsif rising_edge(clk) then
            if tps_mode = '1' then
                counter := counter + 1;
                if counter = TPS_MAX_COUNT + 1 then
                    tps_toggle <= not tps_toggle;
                    counter := 0;
                end if;
            else
                counter := 0;
                tps_toggle <= '1';
            end if;
        end if;
    end process;


    STATE_REG : process(clk, btnD)
    begin
        if btnD = '1' then
            currentNumber <= BLANK;
        elsif rising_edge(clk) then
            currentNumber <= NextNumber;
        end iF;
    end process;

    STATE_TRANSITION : PROCESS (currentNumber, readyEN)--todo finish function of this
    begin
        case (currentNumber) Is
        ------------------------------------------BLANK
            when BLANK =>
                blank0 <= '1';
                blank1 <= '1';
                blank2 <= '1';
                blank3 <= '1';
                led <= BLANK_LEDS;
                if readyEN = '1' then
                    nextNumber <= NUM0;
                else 
                    nextNumber <= BLANK;
                end if;
        -------------------------------------------NUM0
        when NUM0 =>
            if 

        -------------------------------------------NUM1
        when NUM1 =>

        -------------------------------------------NUM2
        when NUM2 =>

        -------------------------------------------NUM3
        when NUM3 =>

        -------------------------------------------NUM4
        when NUM4 =>
        end case;
    end process;

end RandomNumbers_Basys3_ARCH;