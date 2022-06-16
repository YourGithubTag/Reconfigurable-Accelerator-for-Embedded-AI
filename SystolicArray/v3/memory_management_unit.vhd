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
		write_feat_map	: in std_logic;
		write_weight	: in std_logic;
		feat_map_in		: in std_logic_vector(7 downto 0);
		weight_in		: in std_logic_vector(7 downto 0);
		--TODO: Add an input signal that indicates when the MMU should output its modified matrices
		
		
		feat_map_out	: out MMU_OUTPUT_PORTS_TYPE;
		weight_out		: out std_logic_vector(7 downto 0)
	);
end entity memory_management_unit;

architecture behaviour of memory_management_unit is
	
	-- Local memory to store the weight and input feature map
	--TODO: Implement two arrays, size from the input generics, to store weight and input map locally
	
begin

	process (clk)
		-- Used to store 
		variable feat_map_idx		: integer := 0;
		variable weight_idx			: integer := 0;
	begin
	if rising_edge(clk)
		if write_feat_map = '1' then
			--TODO: write to the local feature map array, starting from zero, and stop once the end is reached
		else
			--TODO: Clear the write feat map idx
		end if;
		
		--TODO: Copy structure of the above if and repeat but for writing to the weights array
		
		--TODO: When input signal is received that initiates the MMu output, send out the
		-- modified matrices, only if neither write feat map or write weight is 1
		-- The feap map can be output asa column vector, e.g. 1 by 1
		-- The weights need to be output as a sparse vector, e.g. a lot of zeros
		--TODO: Figure out hte algorithm taht determines which positions in the sparse matrix are zero
		
	end if;
	end process;

end architecture behaviour;