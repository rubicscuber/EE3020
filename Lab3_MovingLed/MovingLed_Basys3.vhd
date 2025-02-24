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
    --(0xA = 0b0001 0000 = 10)
    ------------------------------------------------------------
    with to_integer(unsigned(position)) select
        digits <= "00000000" when 0,
                  "00000001" when 1,
                  "00000010" when 2,
                  "00000011" when 3,
                  "00000100" when 4,
                  "00000101" when 5,
                  "00000110" when 6,
                  "00000111" when 7,
                  "00001000" when 8,
                  "00001001" when 9,
                  "00010000" when 10,
                  "00010001" when 11,
                  "00010010" when 12,
                  "00010011" when 13,
                  "00010100" when 14,
                  "00010101" when 15,
                  (others => '0') when others; 

    ------------------------------------------------------------
    --decodes position to the bar led output
    ------------------------------------------------------------
    with to_integer(unsigned(position)) select
        led <= "0000000000000001" when 0,
               "0000000000000010" when 1,
               "0000000000000100" when 2,
               "0000000000001000" when 3,
               "0000000000010000" when 4,
               "0000000000100000" when 5,
               "0000000001000000" when 6,
               "0000000010000000" when 7,
               "0000000100000000" when 8,
               "0000001000000000" when 9,
               "0000010000000000" when 10,
               "0000100000000000" when 11,
               "0001000000000000" when 12,
               "0010000000000000" when 13,
               "0100000000000000" when 14,
               "1000000000000000" when 15,
               (others => '0') when others;


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
