library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RandomNumbers_Basys3 is
    port(
        btnC : in std_logic; --generateEN
        btnD : in std_logic; --reset
        clk : in std_logic;

        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(3 downto 0);
        seg : out std_logic_vector(6 downto 0)
    );
end entity;


architecture RandomNumbers_Basys3_ARCH of RandomNumbers_Basys3 is

    component RandomNumbers is
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

    component BCD is 
        port(
            binary4Bit : in std_logic_vector(3 downto 0);

            decimalOnes : out std_logic_vector(3 downto 0);
            decimalTens : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component BarLedDriver
        port(
            binary4Bit : in  std_logic_vector(3 downto 0);
            outputEN : in std_logic;

            leds       : out std_logic_vector(15 downto 0)
        );
    end component BarLedDriver;

    --each number is displayed once per second
    constant TPS_MAX_COUNT : integer := 20; --change to 100M before synthesis
    signal tps_toggle : std_logic;
    signal tps_toggle_shift : std_logic;
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

    --signal after the INPUT_SYNC process
    signal generateEN : std_logic;
    signal generateEN_sync : std_logic;

    --internal flip-flop registers for the INPUT_SYNC process
    signal input_reg0 : std_logic;
    signal input_reg1 : std_logic;

    --constants used in the INPUT_PULSE process
    constant SHIFT_REG_MAX : integer := 2**20-1;
    constant SHIFT_REG_WIDTH : integer := 20;

    --Level control for bar led
    signal ledMode : std_logic;

    --blanks vector for SevenSegmentDriver.vhd blanking inputs 
    signal blanks : std_logic_vector(3 downto 0);

    --signals for BCD
    signal decimalOnes : std_logic_vector(3 downto 0);
    signal decimalTens : std_logic_vector(3 downto 0);

    --signal for the ouput number
    signal outputNumber : std_logic_vector(3 downto 0);
    

begin

    RNG_GENERATOR : RandomNumbers port map(
        generateEN => generateEN,
        reset => btnD,
        clock => clk,

        number0 => number0_signal, 
        number1 => number1_signal, 
        number2 => number2_signal,
        number3 => number3_signal,
        number4 => number4_signal,

        readyEN => readyEN
    );    

    SEGMENT_DRIVER : component SevenSegmentDriver port map(
        reset     => btnD,
        clock     => clk,

        digit3    => "0000",
        digit2    => "0000",
        digit1    => decimalTens,
        digit0    => decimalOnes,

        blank3    => blanks(3),
        blank2    => blanks(2),
        blank1    => blanks(1),
        blank0    => blanks(0),


        sevenSegs => seg,
        anodes    => an
    );

    BCD_SPLITTER : BCD port map(
        binary4Bit  => outputNumber,

        decimalOnes => decimalOnes,
        decimalTens => decimalTens
    );
    
    LED_DRIVER : BarLedDriver port map(
        binary4Bit => outputNumber,
        outputEN => ledMode,

        leds       => led
    );
    
    ------------------------------------------------------------------------------------
    -- chain of 2 flip-flops to handle metastability, the massaged output is
    -- generateEN_sync signal
    ------------------------------------------------------------------------------------
    SYNC_CHAIN : process(clk, btnD)
    begin
        if btnD = '1' then
            generateEN_sync <= '0';
            input_reg0 <= '0';
            input_reg1 <= '0';
        elsif rising_edge(clk) then
            input_reg1 <= btnC; --raw voltage signal
            input_reg0 <= input_reg1;
            generateEN_sync <= input_reg0;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Debouncing type shift register that only transmits a single pulse to the 
    -- RNG_GENERATOR if all 20 slots are full of the active level.
    -- The transmitPulse flag is reset after all ones in the register and is not 
    -- set until the shift register get all zeroes.
    ------------------------------------------------------------------------------------
    INPUT_PULSE : process(clk, btnD)
        --variable shiftRegisterValue : integer range 0 to SHIFT_REG_MAX;
        variable transmitPulse : integer range 0 to 1; --flag thats updated when valid input
        variable shiftRegister : unsigned (SHIFT_REG_WIDTH-1 downto 0);
    begin
        if btnD = '1' then
            generateEN <= '0';
            shiftRegister := (others => '0');
            transmitPulse := 1;
        elsif rising_edge(clk) then

            shiftRegister := shiftRegister(shiftRegister'high-1 downto 0) & generateEN_sync;

            --turn off the flag if the button was held long enough
            if (shiftRegister = SHIFT_REG_MAX) and (transmitPulse = 1) then
                generateEN <= '1';
                transmitPulse := 0;
            else
                generateEN <= '0';
            end if;

            --turn on the flag if the button was released long enough
            if (shiftRegister = 0) and (transmitPulse = 0) then
                transmitPulse := 1;
            end if;
        end if;
    end process;


    ------------------------------------------------------------------------------------
    -- shift each number from the RNG_GENERATOR to a storage register 
    -- and only if the state machine is in the BLANK (default) state
    ------------------------------------------------------------------------------------
    LOAD_IN_NUMBERS : process(clk, btnD)
    begin
        if btnD = '1' then
            number0_reg <= (others => '0');
            number1_reg <= (others => '0');
            number2_reg <= (others => '0');
            number3_reg <= (others => '0');
            number4_reg <= (others => '0');
       elsif falling_edge(clk) then
            if readyEN = '1' and currentNumber = BLANK then
                number0_reg <= number0_signal;
                number1_reg <= number1_signal;
                number2_reg <= number2_signal;
                number3_reg <= number3_signal;
                number4_reg <= number4_signal;
            end if;
       end if;
    end process;

    ------------------------------------------------------------------------------------
    -- this process toggles a level control signal (tps_toggle) each second
    -- the process only counts up if the tps_mode level control is high
    -- the state machine only allows tps_mode high when it is out of the default state
    ------------------------------------------------------------------------------------
    TPS_TOGGLER : process(clk, btnD)
        variable counter : integer range 0 to TPS_MAX_COUNT;
    begin
       if btnD = '1' then
            counter := 0;
            tps_toggle <= '0';
       elsif rising_edge(clk) then
            if tps_mode = '1' then
                counter := counter + 1;
                if counter = TPS_MAX_COUNT then
                    tps_toggle <= not tps_toggle;
                    counter := 0;
                end if;
            else
                counter := 0;
                tps_toggle <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- tps_toggle is shifted with this flip flop
    -- the state machine will read the value of tps_toggle and tps_toggle_shift
    -- and will make the transition if there was a change from low to high
    ------------------------------------------------------------------------------------
    TPS_TOGGLE_SHIFTER : process(clk, btnD)
    begin
        if btnD = '1' then
            tps_toggle_shift <= '0';
        elsif rising_edge(clk) then
            tps_toggle_shift <= tps_toggle;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- the state register keeps the state machine synchronized with the clock
    ------------------------------------------------------------------------------------
    STATE_REG : process(clk, btnD)
    begin
        if btnD = '1' then
            currentNumber <= BLANK;
        elsif rising_edge(clk) then
            currentNumber <= nextNumber;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The main state machine.
    -- This process has a steady state at BLANK and is kicked out of that state when
    -- it gets the readyEN pulse, after that it marches onto each state. 
    -- The state machine only reads the vaue of the readyEN pulse at the default state
    -- and ignores that signal at all other times.
    ------------------------------------------------------------------------------------
    CONRTOL_STATE_MACHINE : process (currentNumber, readyEN, tps_toggle, tps_toggle_shift)
    begin
        case (currentNumber) Is
            ------------------------------------------BLANK
            when BLANK =>
                tps_mode <= '0';
                blanks <= (others => '1'); --deactivate segments
                ledMode <= '0';            --deactivate leds

                if readyEN = '1' then      --readyEN kicks off the FSM
                    nextNumber <= NUM0;
                else 
                    nextNumber <= BLANK;
                end if;
            -------------------------------------------NUM0
            when NUM0 =>
                tps_mode <= '1';
                if tps_toggle = '0' then
                    ledMode <= '1';   --activate leds
                    blanks <= "1100"; --activate segments
                    outputNumber <= number0_reg;
                    nextNumber <= NUM0;
                elsif tps_toggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tps_toggle = '1' and tps_toggle_shift = '0') then
                    nextNumber <= NUM1;
                end if;
            -------------------------------------------NUM1
            when NUM1 =>
                tps_mode <= '1';
                if tps_toggle = '0' then
                    ledMode <= '1';   --activate leds
                    blanks <= "1100"; --activate segments
                    outputNumber <= number1_reg;
                    nextNumber <= NUM1;
                elsif tps_toggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tps_toggle = '1' and tps_toggle_shift = '0') then
                    nextNumber <= NUM2;
                end if;
            -------------------------------------------NUM2
            when NUM2 =>
                tps_mode <= '1';
                if tps_toggle = '0' then
                    ledMode <= '1';   --activate leds
                    blanks <= "1100"; --activate segments
                    outputNumber <= number2_reg;
                    nextNumber <= NUM2;
                elsif tps_toggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tps_toggle = '1' and tps_toggle_shift = '0') then
                    nextNumber <= NUM3;
                end if;
            -------------------------------------------NUM3
            when NUM3 =>
                tps_mode <= '1';
                if tps_toggle = '0' then
                    ledMode <= '1';   --activate leds
                    blanks <= "1100"; --activate segments
                    outputNumber <= number3_reg;
                    nextNumber <= NUM3;
                elsif tps_toggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tps_toggle = '1' and tps_toggle_shift = '0') then
                    nextNumber <= NUM4;
                end if;
            -------------------------------------------NUM4
            when NUM4 =>
                tps_mode <= '1';
                if tps_toggle = '0' then
                    ledMode <= '1';   --activate leds
                    blanks <= "1100"; --activate segments
                    outputNumber <= number4_reg;
                    nextNumber <= NUM4;
                elsif tps_toggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tps_toggle = '1' and tps_toggle_shift = '0') then
                    nextNumber <= BLANK;
                end if;
        end case;
    end process;

end RandomNumbers_Basys3_ARCH;
