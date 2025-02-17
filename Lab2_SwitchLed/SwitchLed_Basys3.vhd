library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------------------
--Title: Lab_2_SwitchLed
--Name: Nathaniel Roberts, Mitch Walker
--Date: 2/12/25
--Prof: Scott Tippens
--Desc: Wrapper file for hardware. The two components BarLed
--      and SevenSegment are imported and connected together
--      to each other and hardware.
------------------------------------------------------------

entity SwitchLed_Basys3 is
    port(
        sw   : in std_logic_vector(2 downto 0);
        btnL : in std_logic;
        btnR : in std_logic;

        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
    end SwitchLed_Basys3;

architecture SwitchLed_Basys3_ARCH of SwitchLed_Basys3 is

    ----------------------------------------------------
    --Component definitions
    ----------------------------------------------------
    component BarLed is
        port (
            numLeds     : in std_logic_vector(2 downto 0);
            leftLedEN   : in std_logic;
            rightLedEN  : in std_logic;

            leftLeds    : out std_logic_vector(6 downto 0);
            rightLeds   : out std_logic_vector(6 downto 0)
        );
    end component;

    component SevenSegment is
        port (
            numLeds : in std_logic_vector(2 downto 0);
            cathodes : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    an <= "1110"; --annodes 3, 2 and 1 are unused;
    led(8 downto 7) <= "00"; -- the two center leds are unused

    ----------------------------------------------------
    --Component instantiations
    ----------------------------------------------------
    LED_DRIVER: BarLed port map(
        numLeds    => sw,
        leftLedEN  => btnL,
        rightLedEN => btnR,

        leftLeds   => led(15 downto 9),
        rightLeds  => led(6 downto 0)
    );

    SEGMENT_DRIVER: SevenSegment port map(
        numLeds => sw,
        cathodes => seg
    );

end architecture SwitchLed_Basys3_ARCH ;
