library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Types_package is
    type GameStates_t is (WAIT_FOR_START, ROUND1, ROUND2, ROUND3, ROUND4, ROUND5, GAME_WIN, GAME_LOSE);
    type DisplayStates_t is (IDLE, NUM1, NUM2, NUM3, NUM4, NUM5);
end package Types_package;

package body Types_package is
    
end package body Types_package;

