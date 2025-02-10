library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
------------------------------------------------------------
--Title: Lab_1_Referee_testbench
--Name:  Nathaniel Roberts
--Date:  1/29/25
--Prof:  Scott Tippens
--Desc:  Referee testbench that stimulates all possible combinations of inputs
--       any vote resulting in a tie is broken in favor of the head ref decisoin.          
------------------------------------------------------------
entity Lab1_Referee_TB is
end entity Lab1_Referee_TB;

architecture Behavioral of Lab1_Referee_TB is

    --instantiating component
    component Lab1_Referee is
        port (
        ref0 : in std_logic;
        ref1 : in std_logic;
        ref2 : in std_logic;
        headref : in std_logic;
        decision : out std_logic);
    end component;

    --define signals before begin
    signal decision : std_logic;
    signal inputs : std_logic_vector(3 downto 0);

    --define width and index for every input bus which will go into nested loops
    --for more complex designs, name width and index descriptively 
    constant WIDTH : integer := 4; --how many input ports are on the design
    constant INDEX  : integer := 15; --index= 2^WIDTH-1

begin

    --place component within the testbench
    --componentPort => testbenchSignal,
    UUT : Lab1_Referee port map(
        ref0  => inputs(0),
        ref1  => inputs(1),
        ref2  => inputs(2),
        headref  => inputs(3),
        decision => decision
        );

    --stimulate all possible input combinations with a for loop
    stimulus : process
    begin
        test_loop : for i in 0 to INDEX loop
            inputs <= std_logic_vector(to_unsigned(i, WIDTH)); --to_unsigned(integer, length)
            wait for 1 ns;
        end loop test_loop;
    wait;
    end process;

end Behavioral;
