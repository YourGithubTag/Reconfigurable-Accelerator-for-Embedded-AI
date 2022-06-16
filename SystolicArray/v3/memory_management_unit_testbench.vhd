-- Cecil Symes

-- Feeds in a 2D input feature map and weights kernel

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;

entity memory_management_unit_testbench is
end entity memory_management_unit_testbench;

architecture behaviour of memory_management_unit is
	
	-- Memory Management Unit Component
	component memory_management_unit is
		generic (
			feat_map_rows		: integer;
			feat_map_cols		: integer;
			
			weight_rows			: integer;
			weight_cols			: integer;
		);
		port (
			clk				: in std_logic;
			feat_map_in		: in std_logic_vector(7 downto 0);
			weight_in		: in std_logic_vector(7 downto 0);
			
			feat_map_out	: out MMU_OUTPUT_PORTS_TYPE;
			weight_out		: out std_logic_vector(7 downto 0)
		);
	end component;
	
	-- Generic declarations
	signal feat_map_rows		: integer := 4;
	signal feat_map_cols		: integer := 4;
	signal kernel_rows			: integer := 2;
	signal kernel_cols			: integer := 2;
	
	-- Internal Signal Declarations
	signal clk				: std_logic;
	signal feat_map_in		: std_logic_vector(7 downto 0);
	signal weight_in		: std_logic_vector(7 downto 0);
	
	signal feat_map_out		: MMU_OUTPUT_PORTS_TYPE;
	signal weight_out		: std_logic_vector(7 downto 0)
	
	-- Data signal declarations
	type feat_map_type is array (feat_map_rows*feat_map_cols downto 0) of integer;
	signal feat_map_input		: feat_map_type := (
		7, 12, 14, 6,
		6, 6, 7, 8,
		13, 11, 10, 12,
		4, 3, 7, 12
	);
	type weight_type is array (kernel_rows*kernel_cols downto 0) of integer;
	signal weight_input			: weight_type := (2, 3, 1, 4);
	
begin

	mmu1 : memory_management_unit
	generic map (
		feat_map_rows => feat_map_rows,
		feat_map_cols => feat_map_cols,
		weight_rows => weight_rows,
		weight_cols => weight_cols
	);
	port map (
		clk => clk,
		feat_map_in => feat_map_in,
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
		variable idx : integer := 0;
	begin
		if rising_edge(clk)

			feat_map_in <= feat_map_input(idx);
		    --TODO: Complete the data feeder logic
			
		end if;
	end process data_feed;
	
end architecture behaviour;