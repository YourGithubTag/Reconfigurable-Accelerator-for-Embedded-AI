-- Cecil Symes

-- Feeds in a 2D input feature map and weights weight

package ezconstants is
	constant input_img_rows	: integer := 4;
	constant input_img_cols	: integer := 7;
	constant kernel_rows	: integer := 2;
	constant kernel_cols	: integer := 2;
end package ezconstants;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;
use work.ezconstants.all;

entity memory_management_unit_testbench is
end entity memory_management_unit_testbench;

architecture behaviour of memory_management_unit_testbench is
	
	
	-- Memory Management Unit Component
	component memory_management_unit is
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
	end component;
	
	
	-- Internal Signal Declarations
	signal clk				: std_logic;
	
	signal write_feat_map	: std_logic := '0';
	signal output_feat_map	: std_logic := '0';
	signal feat_map_in		: std_logic_vector(7 downto 0) := x"00";
	
	signal write_weight		: std_logic := '0';
	signal output_weights	: std_logic := '0';
	signal weight_in		: std_logic_vector(7 downto 0) := x"00";
	
	signal feat_map_out		: std_logic_vector(7 downto 0) := x"00";
	signal weight_out		: std_logic_vector(7 downto 0) := x"00";
	
	
	-- Data signal declarations
	type feat_map_type is array (0 to input_img_rows*input_img_cols-1) of integer;
	signal feat_map_input		: feat_map_type := (
		7, 12, 14, 6,
		6, 6, 7, 8,
		13, 11, 10, 12,
		4, 3, 7, 12, others => 0);
	type weight_type is array (kernel_rows*kernel_cols-1 downto 0) of integer;
	signal weight_input			: weight_type := (2, 3, 1, 4);
	
begin

	mmu1 : memory_management_unit
	generic map (
		feat_map_rows => input_img_rows,
		feat_map_cols => input_img_cols,
		weight_rows => kernel_rows,
		weight_cols => kernel_cols
	)
	port map (
		clk => clk,
		
		write_feat_map => write_feat_map,
		output_feat_map => output_feat_map,
		feat_map_in => feat_map_in,
		
		write_weight => write_weight,
		output_weights => output_weights,
		weight_in => weight_in,
		
		feat_map_out => feat_map_out,
		weight_out => weight_out
	);

	-- Clk gen
	clk_gen : process
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process clk_gen;
	
	-- Data feeder
	data_feed : process (clk)
		variable feat_map_idx	: integer := 0;
		variable weight_idx		: integer := 0;
	begin
		if rising_edge(clk) then
			
			-- Feed image data to MMU
			if feat_map_idx < input_img_rows*input_img_cols then
				write_feat_map <= '1';
				feat_map_in <= std_logic_vector(to_unsigned(feat_map_input(feat_map_idx), 8));
				feat_map_idx := feat_map_idx + 1;
			else
				write_feat_map <= '0';
				feat_map_in <= x"00";
				
				-- If finished feeding input data, output them after one cycle delay
				if feat_map_idx = input_img_rows*input_img_cols + 1 then
					output_feat_map <= '1';
				end if;
				
				feat_map_idx := feat_map_idx + 1;
			end if;
			
			-- Feed weights to MMU
			if weight_idx < kernel_rows*kernel_cols then
				write_weight <= '1';
				weight_in <= std_logic_vector(to_unsigned(weight_input(weight_idx), 8));
				weight_idx := weight_idx + 1;
			else
				write_weight <= '0';
				weight_in <= x"00";	
				
				-- If finished feeding weights, output them after one cycle delay
				if weight_idx = kernel_rows*kernel_cols + 1 then
					output_weights <= '1';
				end if;
				
				weight_idx := weight_idx + 1;
			end if;
			
		end if;
	end process data_feed;
	
end architecture behaviour;