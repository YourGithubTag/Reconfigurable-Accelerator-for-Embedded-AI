-- Cecil Symes

-- Takes in a 2D matrix for feature map and weight kernel and outputs the loose Toeplitz equivalent

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;

entity memory_management_unit is
	generic (
		feat_map_rows		: integer := 4;
		feat_map_cols		: integer := 4;
		
		kernel_rows			: integer := 2;
		kernel_cols			: integer := 2;
	);
	port (
		clk				: in std_logic;
		feat_map_in		: in std_logic_vector(7 downto 0);
		weight_in		: in std_logic_vector(7 downto 0);
		
		feat_map_out	: out MMU_OUTPUT_PORTS_TYPE;
		weight_out		: out std_logic_vector(7 downto 0)
	);
end entity memory_management_unit;

architecture behaviour of memory_management_unit is
	
begin


end architecture behaviour;