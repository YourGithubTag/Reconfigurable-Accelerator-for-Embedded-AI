library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package CustomTypes is

	type MMU_OUTPUT_PORTS_TYPE is array (integer range <>) of std_logic_vector(7 downto 0);
	
end package;