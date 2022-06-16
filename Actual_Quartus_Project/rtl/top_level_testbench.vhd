-- Cecil Symes

-- Top level entity testbench

package ezconstants is
	constant input_img_rows	: integer := 4;
	constant input_img_cols	: integer := 4;
	constant kernel_rows	: integer := 2;
	constant kernel_cols	: integer := 2;
end package ezconstants;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;
use work.ezconstants.all;

entity top_level_testbench is
end entity top_level_testbench;

architecture behaviour of top_level_testbench is
	component top_level is
		generic (
			feat_map_rows		: integer := 4;
			feat_map_cols		: integer := 4;
			
			weight_rows			: integer := 2;
			weight_cols			: integer := 2
		);
		port (
			clk					: in std_logic;
			reset				: in std_logic := '0';
			
			write_weights		: in std_logic := '0';
			weight_in			: in std_logic_vector(7 downto 0) := x"00";
			
			write_feat_map		: in std_logic := '0';
			feat_map_in			: in std_logic_vector(7 downto 0) := x"00";
			
			write_control		: in std_logic := '0';
			control				: in std_logic_vector(7 downto 0) := x"00";
			
			read_output_flag	: in std_logic := '0';
			output_flag			: out std_logic_vector(7 downto 0) := x"00";
			
			read_output_map		: in std_logic := '0';
			output_map			: out std_logic_vector(7 downto 0) := x"00";
			
			test_bit			: out std_logic_vector(7 downto 0) := x"00"
		);
	end component top_level;
	
	-- Internal Signal Declarations
	signal clk				: std_logic;
	signal reset			: std_logic := '0';
	
	signal write_weights	: std_logic := '0';
	signal weight_in		: std_logic_vector(7 downto 0) := x"00";
	
	signal write_feat_map	: std_logic := '0';
	signal feat_map_in		: std_logic_vector(7 downto 0) := x"00";
	
	signal write_control	: std_logic := '1';
	signal control			: std_logic_vector(7 downto 0) := x"00";
	
	signal read_output_flag	: std_logic := '0';
	signal output_flag		: std_logic_vector(7 downto 0) := x"00";
	
	signal read_output_map	: std_logic := '0';
	signal output_map		: std_logic_vector(7 downto 0) := x"00";
	
	signal test_bit			: std_logic_vector(7 downto 0) := x"00";
	
	-- Input Data
	type feat_map_type is array (0 to input_img_rows*input_img_cols-1) of integer;
	signal feat_map_input		: feat_map_type := (
		7, 12, 14, 6,
		6, 6, 7, 8,
		13, 11, 10, 12,
		4, 3, 7, 12, others => 0);
	type weight_type is array (kernel_rows*kernel_cols-1 downto 0) of integer;
	signal weight_input			: weight_type := (2, 3, 1, 4);
	
	signal output_flag_prev		: std_logic := '0';
	
begin
	
	-- Component Generation
	toplevelgen : top_level
	generic map (
		feat_map_rows => input_img_rows,
		feat_map_cols => input_img_cols,
		weight_rows => kernel_rows,
		weight_cols => kernel_cols
	)
	port map (
		clk => clk,
		reset => reset,
		
		write_weights => write_weights,
		weight_in => weight_in,
		
		write_feat_map => write_feat_map,
		feat_map_in => feat_map_in,
		
		write_control => write_control,
		control => control,
		
		read_output_flag => read_output_flag,
		output_flag => output_flag,
		
		read_output_map => read_output_map,
		output_map => output_map,
		
		test_bit => test_bit
	);
	
	-- Data feeder
	data_feed : process (clk)
		variable feat_map_idx	: integer := 0;
		variable weight_idx		: integer := 0;
	begin
		if rising_edge(clk) then
			
			-- Lower begin_conv
			if (control = x"03") then
				control <= x"01";
			end if;
			
			-- Restart simulation
			if (reset = '1' and control = x"00") then
				feat_map_idx := 0;
				weight_idx := 0;
				reset <= '0';
				control <= x"01";
			end if;
			
			-- Tell MMU to output both when both are finished
			if weight_idx = kernel_rows*kernel_cols and feat_map_idx = input_img_rows*input_img_cols then
				control <= x"03";
				
				-- Increment feat_map_idx to ensure the conditional does not reoccur
				feat_map_idx := feat_map_idx + 1;
			end if;			
			
			-- Feed image data to MMU
			if feat_map_idx < input_img_rows*input_img_cols then
				write_feat_map <= '1';
				feat_map_in <= std_logic_vector(to_unsigned(feat_map_input(feat_map_idx), 8));
				feat_map_idx := feat_map_idx + 1;
			else
				write_feat_map <= '0';
				feat_map_in <= x"00";
			end if;
			
			-- Feed weights to MMU
			if weight_idx < kernel_rows*kernel_cols then
				write_weights <= '1';
				weight_in <= std_logic_vector(to_unsigned(weight_input(weight_idx), 8));
				weight_idx := weight_idx + 1;
			else
				write_weights <= '0';
				weight_in <= x"00";
			end if;	
			
		end if;
	end process data_feed;
	
	-- Manual read of output_map
	read_out : process
	begin
		wait for 480 ns;
		
		read_output_flag <= '1';
		
		read_output_map <= '1';
		
	end process read_out;
	
	-- Clk gen
	clk_gen : process
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process clk_gen;
	
end architecture behaviour;