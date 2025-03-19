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

    
    ------------------------------------------------------------------------------------
    --component definitions
    ------------------------------------------------------------------------------------
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

            leds : out std_logic_vector(15 downto 0)
        );
    end component BarLedDriver;

    ------------------------------------------------------------------------------------
    --internal signals and constants
    ------------------------------------------------------------------------------------
    --each number is displayed once per second
    constant TPS_MAX_COUNT : integer := 20; --change to 100M before synthesis
    signal tpsToggle : std_logic;
    signal tpsToggleShift : std_logic;
    signal tpsModeControl : std_logic;

    --signals that connect the ports to each DFF
    signal number0Signal : std_logic_vector(3 downto 0);
    signal number1Signal : std_logic_vector(3 downto 0);
    signal number2Signal : std_logic_vector(3 downto 0);
    signal number3Signal : std_logic_vector(3 downto 0);
    signal number4Signal : std_logic_vector(3 downto 0);

    --registers of the 5 numbers
    signal number0Register : std_logic_vector(3 downto 0);
    signal number1Register : std_logic_vector(3 downto 0);
    signal number2Register : std_logic_vector(3 downto 0);
    signal number3Register : std_logic_vector(3 downto 0);
    signal number4Register : std_logic_vector(3 downto 0);

    --state machine types
    type States_t is (BLANK, NUM0, NUM1, NUM2, NUM3, NUM4);
    signal currentState : States_t; 
    signal nextState : States_t; 

    --one pulse wide ready signal
    signal readyEN : std_logic;

    --signal after the INPUT_SYNC process
    signal generateEN : std_logic;
    signal generateEN_sync : std_logic;

    --internal flip-flop registers for the INPUT_SYNC process
    signal inputReg0 : std_logic;
    signal inputReg1 : std_logic;

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
    

begin------------------------------------------------------------------------------begin


    ------------------------------------------------------------------------------------
    --component insantiations
    ------------------------------------------------------------------------------------
    RNG_GENERATOR : RandomNumbers port map(
        generateEN => generateEN,
        reset => btnD,
        clock => clk,

        number0 => number0Signal, 
        number1 => number1Signal, 
        number2 => number2Signal,
        number3 => number3Signal,
        number4 => number4Signal,
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

        leds => led
    );
    
    ------------------------------------------------------------------------------------
    -- chain of 2 flip-flops to handle metastability, 
    -- the massaged output is the generateEN_sync signal
    ------------------------------------------------------------------------------------
    SYNC_CHAIN : process(clk, btnD)
    begin
        if btnD = '1' then
            generateEN_sync <= '0';
            inputReg1 <= '0';
            inputReg0 <= '0';
        elsif rising_edge(clk) then
            inputReg1 <= btnC; --raw voltage signal
            inputReg0 <= inputReg1;
            generateEN_sync <= inputReg0;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- Debouncing type shift register that only transmits a single pulse to the 
    -- RNG_GENERATOR if all 20 slots are full of the active level.
    --
    -- The shift register is filled using the generateEN_sync signal from the above process.
    --
    -- The transmitPulse flag goes low when shiftRegister is filled with ones and 
    -- remains low until the shift register fills with zeroes again.
    ------------------------------------------------------------------------------------
    INPUT_PULSE : process(clk, btnD)
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
    -- Shift each number from the RNG_GENERATOR to a storage register. 
    -- Ignore the readyEN pulse if we are currently traversing the states.
    --
    -- If the RNG_GENERATOR is trying to send new numbers and the state machine has
    -- not finnished its path, the output of RNG_GENERATOR is ignored.
    ------------------------------------------------------------------------------------
    LOAD_IN_NUMBERS : process(clk, btnD)
    begin
        if btnD = '1' then
            number0Register <= (others => '0');
            number1Register <= (others => '0');
            number2Register <= (others => '0');
            number3Register <= (others => '0');
            number4Register <= (others => '0');
       elsif falling_edge(clk) then
            if readyEN = '1' and currentState = BLANK then
                number0Register <= number0Signal;
                number1Register <= number1Signal;
                number2Register <= number2Signal;
                number3Register <= number3Signal;
                number4Register <= number4Signal;
            end if;
       end if;
    end process;

    ------------------------------------------------------------------------------------
    -- This process toggles a level control signal (tps_toggle) each second.
    -- The process is enabled by the tps_mode level control.
    -- 
    -- If the state machine is in the BLANK state, the counter is 0 and is deactivated
    -- If the state machine is outside of the BLANK state, then the counter is active
    --
    -- These next two processes are what make the state machine change every second and
    -- also enable the numbers to be displayed.
    ------------------------------------------------------------------------------------
    TPS_TOGGLER : process(clk, btnD)
        variable counter : integer range 0 to TPS_MAX_COUNT;
    begin
       if btnD = '1' then
            counter := 0;
            tpsToggle <= '0';
       elsif rising_edge(clk) then
            if tpsModeControl = '1' then
                counter := counter + 1;
                if counter = TPS_MAX_COUNT then
                    tpsToggle <= not tpsToggle;
                    counter := 0;
                end if;
            end if;
            if tpsModeControl = '0' then
                counter := 0;
                tpsToggle <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- tps_toggle is shifted with this flip flop.
    --
    -- The state machine will read the value of tps_toggle and tps_toggle_shift meaning
    -- it will transition only if tps_toggle went from low to high.
    ------------------------------------------------------------------------------------
    TPS_TOGGLE_SHIFTER : process(clk, btnD)
    begin
        if btnD = '1' then
            tpsToggleShift <= '0';
        elsif rising_edge(clk) then
            tpsToggleShift <= tpsToggle;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The state register keeps the state machine synchronized with the clock.
    ------------------------------------------------------------------------------------
    STATE_REG : process(clk, btnD)
    begin
        if btnD = '1' then
            currentState <= BLANK;
        elsif rising_edge(clk) then
            currentState <= nextState;
        end if;
    end process;

    ------------------------------------------------------------------------------------
    -- The main state machine.
    --
    -- This process has a steady state at BLANK and is kicked out of that state when
    -- it gets the readyEN pulse, after that it marches onto each state given by the 
    -- tps_toggle signal. 
    --
    -- The state machine only reads the vaue of the readyEN pulse at the default state
    -- and ignores that signal at all other times.
    --
    -- It also controls when the LOAD_IN_NUMBERS process runs.
    ------------------------------------------------------------------------------------
    CONRTOL_STATE_MACHINE : process (currentState, readyEN, tpsToggle, tpsToggleShift)
    begin
        case (currentState) Is
            ------------------------------------------BLANK
            when BLANK =>
                tpsModeControl <= '0';     --turn off counter and reset it
                blanks <= (others => '1'); --deactivate segments
                ledMode <= '0';            --deactivate leds

                if readyEN = '1' then      --readyEN kicks off the state machine
                    nextState <= NUM0;
                else 
                    nextState <= BLANK;
                end if;
            -------------------------------------------NUM0
            when NUM0 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number0Register;
                    nextState <= NUM0;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM1;
                end if;
            -------------------------------------------NUM1
            when NUM1 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number1Register;
                    nextState <= NUM1;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM2;
                end if;
            -------------------------------------------NUM2
            when NUM2 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number2Register;
                    nextState <= NUM2;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM3;
                end if;
            -------------------------------------------NUM3
            when NUM3 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number3Register;
                    nextState <= NUM3;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= NUM4;
                end if;
            -------------------------------------------NUM4
            when NUM4 =>
                tpsModeControl <= '1';
                if tpsToggle = '0' then
                    ledMode <= '1';            --activate leds
                    blanks <= "1100";          --activate segments
                    outputNumber <= number4Register;
                    nextState <= NUM4;
                elsif tpsToggle = '1' then
                    ledMode <= '0';            --deactivate leds
                    blanks <= (others => '1'); --deactivate segments
                end if;
                if (tpsToggle = '1' and tpsToggleShift = '0') then
                    nextState <= BLANK;
                end if;
        end case;
    end process;

end RandomNumbers_Basys3_ARCH;
