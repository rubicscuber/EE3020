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

    component DigitSplitter is
        port (
            position: in std_logic_vector(3 downto 0);
            --note seg[3] is not decoded here, 
            --instead the position is fed directly to the SevenSegmentDriver
            --seg[2] is blank
            --digits (7 downto 4) will be the tens place (seg[1])
            --digits (3 donwto 0) will be the ones place (seg[0])
            digits  : out std_logic_vector(7 downto 0)
        );
    end component;

    component BarLedDriver is
        port (
            position : in std_logic_vector(3 downto 0);
            bar : out std_logic_vector(15 downto 0)
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

    signal digit0Signal : std_logic_vector(3 downto 0);
    signal digit1Signal : std_logic_vector(3 downto 0);
    signal digit2Signal : std_logic_vector(3 downto 0);
    signal positionSignal : std_logic_vector(3 downto 0);
    constant ACTIVE : std_logic := '1';

begin
    
    digit2Signal <= "0000"; --the unused digit on the seven seg display

    MOVE_LED : MovingLed port map(
        leftButton => btnL,
        rightButton=> btnR,
        resetButton => btnC,
        clock => clk,

        position => positionSignal
    );

    DIGIT_SPLITTER : DigitSplitter port map(
        position => positionSignal,
        digits(7 downto 4) => digit1Signal,
        digits(3 downto 0) => digit0Signal
    );

    BAR_LED : BarLedDriver port map(
        position => positionSignal,
        bar => led
    );

    SEVEN_SEGMENT : SevenSegmentDriver port map(
        reset => btnC,
        clock => clk,

        digit3 => positionSignal, --positionSignal is a straight binary number
        digit2 => digit2Signal,
        digit1 => digit1Signal,
        digit0 => digit0Signal,

        blank3 => (not ACTIVE),
        blank2 => (ACTIVE), --blank out seg[2]
        blank1 => (not ACTIVE),
        blank0 => (not ACTIVE),

        sevenSegs => seg,
        anodes => an
    );

end architecture MovingLed_Basys3_ARCH;
