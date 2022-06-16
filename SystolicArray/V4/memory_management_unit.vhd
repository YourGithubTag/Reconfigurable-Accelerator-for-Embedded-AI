-- Cecil Symes

-- Takes in a 2D matrix for feature map and weight weight and outputs the loose Toeplitz equivalent

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;

entity memory_management_unit is
	generic (
		feat_map_rows		: integer := 4;
		feat_map_cols		: integer := 4;
		
		weight_rows			: integer := 2;
		weight_cols			: integer := 2
	);
	port (
		clk				: in std_logic;
		
		write_feat_map	: in std_logic := '0';
		output_feat_map	: in std_logic := '0';
		feat_map_in		: in std_logic_vector(7 downto 0) := x"00";
		
		write_weight	: in std_logic := '0';
		output_weights	: in std_logic := '0';
		weight_in		: in std_logic_vector(7 downto 0) := x"00";
		
		feat_map_out	: out std_logic_vector(7 downto 0) := x"00";
		weight_out		: out std_logic_vector(7 downto 0) := x"00"
	);
end entity memory_management_unit;

architecture behaviour of memory_management_unit is
	
	-- Local memory to store the weight and input feature map
	type input_data_type is array (0 to feat_map_rows*feat_map_cols-1) of std_logic_vector(7 downto 0);
	signal input_data		: input_data_type;
	type weight_data_type is array (0 to weight_rows*weight_cols-1) of std_logic_vector(7 downto 0);
	signal weight_data		: weight_data_type;
	
begin

	process (clk)
		-- Used to navigate data arrays
		variable feat_map_write_idx		: integer := 0;
		variable feat_map_read_idx		: integer := 0;
		variable weight_write_idx		: integer := 0;
		variable weight_read_idx		: integer := 0;
	begin
	if rising_edge(clk) then
	
		-- Write to local feature map array
		if write_feat_map = '1' then
			if feat_map_write_idx < (feat_map_rows*feat_map_cols) then
				input_data(feat_map_write_idx) <= feat_map_in;
				feat_map_write_idx := feat_map_write_idx + 1;
			end if;
		else
			feat_map_write_idx := 0;
		end if;
		
		-- If not writing, check for read
		if output_feat_map = '1' and write_feat_map = '0' then
			if feat_map_read_idx < (feat_map_rows*feat_map_cols) then
				feat_map_out <= input_data(feat_map_read_idx);
				feat_map_read_idx := feat_map_read_idx + 1;
			end if;
		else
			feat_map_read_idx := 0;
		end if;
		
		-- Write to local weight data array
		if write_weight = '1' then
			if weight_write_idx < (weight_rows*weight_cols) then
				weight_data(weight_write_idx) <= weight_in;
				weight_write_idx := weight_write_idx + 1;
			end if;
		else
			weight_write_idx := 0;		
		end if;
		
		-- If not writing, check for read
		if output_weights = '1' and write_weight = '0' then
			if weight_read_idx < (weight_rows*weight_cols) then
				weight_out <= weight_data(weight_read_idx);
				weight_read_idx := weight_read_idx + 1;
			end if;
		else
			weight_read_idx := 0;
		end if;
		
		--TODO: When input signal is received that initiates the MMu output, send out the
		-- modified matrices, only if neither write feat map or write weight is 1
		-- The feap map can be output asa column vector, e.g. 1 by 1
		-- The weights need to be output as a sparse vector, e.g. a lot of zeros
		--TODO: Figure out hte algorithm taht determines which positions in the sparse matrix are zero
		
	end if;
	end process;

end architecture behaviour;