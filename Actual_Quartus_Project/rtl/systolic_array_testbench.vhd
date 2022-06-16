-- Cecil Symes

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
--use work.ezconstants.all;

entity systolic_array_testbench is
end entity systolic_array_testbench;

architecture behaviour of systolic_array_testbench is

	component systolic_array is
		generic (
			img_rows		: positive := 4;
			img_cols		: positive := 4;
			
			kern_rows		: positive := 2;
			kern_cols		: positive := 2
		);
		port (
			clk				: in std_logic := '0';
			en				: in std_logic := '0';
			reset			: in std_logic := '0';
			
			out_res_in		: in std_logic := '0';
			img_data_in		: in std_logic_vector(7 downto 0) := x"00";
			weight_in		: in std_logic_vector(7 downto 0) := x"00";
			
			output_flag		: out std_logic := '0';
			output_fin		: out std_logic := '0';
			output_data		: out std_logic_vector(7 downto 0) := x"00"
		);
	end component;
	
	signal clk				: std_logic := '0';
	signal en				: std_logic := '1';
	--signal reset			: std_logic := '0';
	
	signal out_res_in		: std_logic := '0';
	signal img_data_in		: std_logic_vector(7 downto 0) := x"00";
	signal weight_in		: std_logic_vector(7 downto 0) := x"00";
	
	signal output_flag		: std_logic := '0';
	signal output_fin		: std_logic := '0';
	signal output_data		: std_logic_vector(7 downto 0) := x"00";
	
	-- Input Feature Map Data
	type feat_map_data_type is array (0 to 15) of integer;
	signal feat_map_data	: feat_map_data_type := (
	7, 12, 4, 6, 6, 6, 7, 8, 13, 11, 10, 12, 4, 3, 7, 12
	);
	
	-- Input weights
	signal weights_data		: feat_map_data_type := (
	2, 3, 0, 0, 1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	);	
	
begin

SYS_ARRAY : systolic_array port map (
	clk => clk,
	en => en,
	reset => '0',
	
	out_res_in => out_res_in,
	img_data_in => img_data_in,
	weight_in => weight_in,
	
	output_flag => output_flag,
	output_fin => output_fin,
	output_data => output_data
);

-- Sends input feature map data, out/reset, and enable signal
data_in : process (clk)
	variable data_ind : integer := 0;
begin

	if rising_edge(clk) then
		-- Loop to send all data
		if data_ind < 16 then
			-- Send input feature map data
			img_data_in <= std_logic_vector(to_unsigned(feat_map_data(data_ind), 8));
			
			-- Send weights
			weight_in <= std_logic_vector(to_unsigned(weights_data(data_ind), 8));
			
			data_ind := data_ind + 1;
		else
			if data_ind = 16 then
				out_res_in <= '1';
				data_ind := data_ind + 1;
			end if;
		end if;
		
		if out_res_in = '1' then
			out_res_in <= '0';
		end if;
	end if;
	
end process data_in;

clk_gen : process
begin
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	clk <= '0';
end process;

end architecture behaviour;