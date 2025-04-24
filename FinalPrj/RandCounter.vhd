library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------------------------------------------------------------------------------------
--Title: RandCounter.vhd
--Name: Nathaniel Roberts, Mitch Walker
--Date: 4/24/25
--Prof: Scott Tippens
--Desc: Each clock cycle, cubCount increments by 1
--      Once subCount surpasses maxSubCount, subCount is reset to 0, 
--      and randNum is incremented by 1.
--
--      Once randNum surpasses 15, randNum is reset to 0 
------------------------------------------------------------------------------------

entity RandCounter is
    Port (
        ------------ Inputs
        maxSubCount : in std_logic_vector(2 downto 0);
        clock       : in std_logic;
        reset       : in std_logic;
        
        ------------ Outputs
        randNum     : out std_logic_vector(3 downto 0)
    );
end RandCounter;

architecture RandCounter_ARCH of RandCounter is
    constant ACTIVE     : std_logic     := '1';
    constant MAX_COUNT  : integer       := 15;
begin
    
    Counter : process(clock, reset)
        -- Counters used to generate pseudo-random number
        variable subCount   : integer := 0;
        variable count      : integer := 0;
    begin
        if reset = ACTIVE then
            subCount    := 0;
            count       := 0;
            randNum     <= "0000";
        elsif rising_edge(clock) then
            -- Checks if subcount has surpassed maxSubCount
            if subCount < to_integer(unsigned(maxSubCount)) then
                subCount    := subCount + 1;
            else
                subCount    := 0;
                count       := count + 1;
            end if;
            
            -- Checks if count has surpassed MAX_COUNT
            if count > MAX_COUNT then
                count := 0;
            end if;
            
            -- Assigns the count to randNum as a std_logic_vector
            randNum <= std_logic_vector(to_unsigned(count, randNum'length));
        end if;
    end process;
end RandCounter_ARCH;
