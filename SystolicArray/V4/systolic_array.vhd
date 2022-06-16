-- Cecil Symes

-- Instantiates PEs depending on the input generic size
-- Currently internally declares the Input Feature Map and Weights, need to modify to take in from external

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity systolic_array is
	generic (
		size			: positive := 9
	);
end entity systolic_array;

architecture behaviour of systolic_array is

	component processing_element is
	port (
		clk				: in std_logic;
		en				: in std_logic;
		out_res_in		: in std_logic;
		weight_in		: in std_logic_vector(7 downto 0);
		input_img_in	: in std_logic_vector(7 downto 0);
		
		output_map		: out std_logic_vector(7 downto 0) := x"00";
		weight_out		: out std_logic_vector(7 downto 0) := x"00";
		input_img_out	: out std_logic_vector(7 downto 0) := x"00";
		out_res_out		: out std_logic := '0'
	);
	end component;
	
	signal clk				: std_logic := '0';
	signal en				: std_logic := '1';
	signal out_res_in		: std_logic := '0';
	signal weight_in		: std_logic_vector(7 downto 0) := x"00";
	
	-- Type to store data for weights, input maps, and output maps
	type data_type is array (0 to 11) of integer range 0 to 255;
	type std_logic_array is array(0 to 8) of std_logic_vector(7 downto 0);
	
	-- Weights for the first PE
	signal init_weights	: data_type := (4, 1, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0);
	
	-- Output/Reset signal between PEs
	type out_res_type is array (0 to size) of std_logic;
	signal out_res_connect	: out_res_type;
	
	-- Connections between PEs for weights and input img data
	type connect_type is array (0 to size) of std_logic_vector(7 downto 0);
	signal weight_connect	: connect_type;
	signal input_connect	: connect_type;
	
	-- Output of each PE
	signal outputs_array	: std_logic_array := (others => x"00");
	
	-- Connections for feature map data and feature map data input for each PE
	signal feature_maps_in	: std_logic_vector(7 downto 0);
	signal feature_maps_out	: std_logic_array := (others => x"00");
	
	-- Input Feature Map Data for each of the PEs
	type feat_map_data_type is array (0 to 15) of integer range 0 to 15;
	signal feat_map_data	: feat_map_data_type := (
	7, 12, 4, 6, 6, 6, 7, 8, 13, 11, 10, 12, 4, 3, 7, 12
	);
	
	--type feat_map_data_type is array(0 to 8) of data_type;
	--signal feat_map_data	: feat_map_data_type := (
	--		0 => (7, 12, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0),
	--		1 => (0, 12, 14, 6, 7, 0, 0, 0, 0, 0, 0, 0),
	--		2 => (0, 0, 14, 6, 7, 8, 0, 0, 0, 0, 0, 0),
	--		3 => (0, 0, 0, 6, 6, 13, 11, 0, 0, 0, 0, 0),
	--		4 => (0, 0, 0, 0, 6, 7, 11, 10, 0, 0, 0, 0),
	--		5 => (0, 0, 0, 0, 0, 7, 8, 10, 12,0, 0, 0),
	--		6 => (0, 0, 0, 0, 0, 0, 13, 11, 4, 3, 0, 0),
	--		7 => (0, 0, 0, 0, 0, 0, 0, 11, 10, 3, 7, 0),
	--		8 => (0, 0, 0, 0, 0, 0, 0, 0, 10, 12, 7, 12)
	--	);
	
begin

PE_GEN : for i in 0 to size-1 generate

	FIRST_PE : if i = 0 generate
		PE0 : processing_element port map(
			clk => clk,
			en => en,
			out_res_in => out_res_in,
			weight_in => weight_in,
			input_img_in => feature_maps_in,
			input_img_out => feature_maps_out(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate FIRST_PE;
	
	REST_PE : if i > 0 generate
		PEX : processing_element port map (
			clk => clk,
			en => en,
			out_res_in => out_res_connect(i - 1),
			weight_in => weight_connect(i - 1),
			input_img_in => feature_maps_out(i - 1),
			input_img_out => feature_maps_out(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate REST_PE;
	
end generate PE_GEN;

-- Clock generate process
clk_gen : process
begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process clk_gen;

-- Sends input feature map data, out/reset, and enable signal
data_in : process (clk)
	variable input_img_data_ind : integer := 0;
	
	variable weight_data_ind	: integer := 0;
begin

	if rising_edge(clk) then
		
		-- Loop to send the weight data
		-- TODO: Send first row of weights, then zeros, then the next row, etc.
		if then
			-- Send weights
			weight_in <= std_logic_vector(to_unsigned(init_weights(data_ind), 8));
			
			-- Send output/reset signal when at the end of kernel
		end if;
		
		-- Loop to send the input img data
		if input_img_data_ind < 12 then
			-- Send input feature map data
			feature_maps_in <= std_logic_vector(to_unsigned(feat_map_data(input_img_data_ind), 8));
			
			input_img_data_ind := input_img_data_ind + 1;
		end if;
		
	end if;
	
end process data_in;

out_res_gen : process
begin
	--out_res_in <= '0', '1' after 55 ns, '0' after 75 ns;
	--en <= '1', '0' after 75 ns;
	wait;
end process;

end architecture behaviour;