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
entity MovingLed_Basys3 is
    port(
        btnL : in std_logic;
        btnR : in std_logic;
        btnC : in std_logic;
        clk  : in std_logic;

        an : out std_logic_vector(3 downto 0);
        seg: out std_logic_vector(6 downto 0);
        led: out std_logic_vector(15 downto 0)
    );
end entity MovingLed_Basys3;


architecture MovingLed_Basys3_ARCH of MovingLed_Basys3 is

    component MovingLed is
        port (
            leftButton  : in std_logic;
            rightButton : in std_logic;
            resetButton : in std_logic;
            clock : in std_logic;

            position : out std_logic_vector(3 downto 0)
        );
    end component;

    component SevenSegmentDriver is
        port(
            reset: in std_logic;
            clock: in std_logic;

            digit3: in std_logic_vector(3 downto 0);    --leftmost digit
            digit2: in std_logic_vector(3 downto 0);    --2nd from left digit
            digit1: in std_logic_vector(3 downto 0);    --3rd from left digit
            digit0: in std_logic_vector(3 downto 0);    --rightmost digit

            blank3: in std_logic;    --leftmost digit
            blank2: in std_logic;    --2nd from left digit
            blank1: in std_logic;    --3rd from left digit
            blank0: in std_logic;    --rightmost digit

            sevenSegs: out std_logic_vector(6 downto 0);    --MSB=g, LSB=a
            anodes:    out std_logic_vector(3 downto 0)    --MSB=leftmost digit
        );
    end component;

    signal digits : std_logic_vector(7 downto 0);
    signal position : std_logic_vector(3 downto 0);
    constant ACTIVE : std_logic := '1';

begin

    ------------------------------------------------------------
    --split and decode section for position into tens and ones
    ------------------------------------------------------------
    DIGIT_SPLITTER : process(position)
        variable bcd : integer range 0 to 15;
        variable tens : integer range 0 to 15;
        variable ones : integer range 0 to 15;
    begin
        bcd := to_integer(unsigned(position));
        ones := bcd mod 10;
        tens := bcd / 10;
        digits <= std_logic_vector(to_unsigned(tens, 4)) & std_logic_vector(to_unsigned(ones, 4));
    end process;

    ------------------------------------------------------------
    --decodes 4bit position to 16bit map of the led[] bus
    ------------------------------------------------------------
    BAR_LED : process(position)
        variable position_var : integer range 0 to 15;
    begin
        position_var := to_integer(unsigned(position));
        WRITE_LEDS : for i in 0 to 15 loop
            if i = position_var then
                led(i) <= '1';
            else
                led(i) <= '0';
            end if;
        end loop;
    end process;

    MOVE_LED : MovingLed port map(
        leftButton => btnL,
        rightButton=> btnR,
        resetButton => btnC,
        clock => clk,

        position => position
    );

    SEVEN_SEGMENT : SevenSegmentDriver port map(
        reset => btnC,
        clock => clk,

        digit3 => position, --hex representation
        digit2 => "0000",
        digit1 => digits(7 downto 4), --binary of the tens place
        digit0 => digits(3 downto 0), --binary of the ones place


        blank3 => (not ACTIVE),
        blank2 => (ACTIVE), --blank out seg[2]
        blank1 => (not ACTIVE),
        blank0 => (not ACTIVE),

        sevenSegs => seg,
        anodes => an
    );

end architecture MovingLed_Basys3_ARCH;
