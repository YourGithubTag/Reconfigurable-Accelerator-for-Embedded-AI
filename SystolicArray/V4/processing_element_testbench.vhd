-- Cecil Symes :0

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity processing_element_testbench is
end entity processing_element_testbench;

architecture behaviour of processing_element_testbench is

	component processing_element is
	port (
		clk				: in std_logic;
		en				: in std_logic;
		out_res_in		: in std_logic;
		weight_in		: in std_logic_vector(7 downto 0);
		input_img_in		: in std_logic_vector(7 downto 0);
		
		output_map		: out std_logic_vector(7 downto 0);
		weight_out		: out std_logic_vector(7 downto 0);
		input_img_out	: out std_logic_vector(7 downto 0);
		out_res_out		: out std_logic
	);
	end component;
	
	signal clk				: std_logic := '0';
	signal en				: std_logic := '1';
	signal out_res_in		: std_logic := '0';
	signal weight_in		: std_logic_vector(7 downto 0) := x"00";
	signal input_img_in		: std_logic_vector(7 downto 0) := x"00";
	signal output_map		: std_logic_vector(7 downto 0) := x"00";
	signal output_map2		: std_logic_vector(7 downto 0) := x"00";
	signal weight_out		: std_logic_vector(7 downto 0) := x"00";
	signal weight_out2		: std_logic_vector(7 downto 0) := x"00";
	signal out_res_out		: std_logic := '0';
	signal out_res_out2		: std_logic := '0';
	signal input_img_out	: std_logic_vector(7 downto 0) := x"00";
	signal input_img_out2	: std_logic_vector(7 downto 0) := x"00";
	
	type data_type is array (0 to 3) of integer range 0 to 255;
	signal weight_storage	: data_type := (2, 3, 1, 4);
	signal input_storage	: data_type := (7, 12, 6, 6);
begin

pe1 : processing_element port map(
		clk => clk,
		en => en,
		out_res_in => out_res_in,
		weight_in => weight_in,
		input_img_in => input_img_in,
		output_map => output_map,
		weight_out => weight_out,
		out_res_out => out_res_out,
		input_img_out => input_img_out
	);

pe2 : processing_element port map(
		clk => clk,
		en => en,
		out_res_in => out_res_out,
		weight_in => weight_out,
		input_img_in => input_img_out,
		output_map => output_map2,
		weight_out => weight_out2,
		out_res_out => out_res_out2,
		input_img_out => input_img_out2 
	);

clk_gen : process
begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
end process clk_gen;

data_in : process (clk)
	variable data_ind : integer := 0;
	variable weight_ind : integer := 0;
	
	variable weight_delay : integer := 0;
begin
	if rising_edge(clk) then
		-- Feed input img data
		if data_ind < 4 then
			input_img_in <= std_logic_vector(to_unsigned(input_storage(data_ind), 8));
			data_ind := data_ind + 1;
		end if;
		
		-- Feed weight data
		if weight_ind < 4 then
			weight_in <= std_logic_vector(to_unsigned(weight_storage(weight_ind), 8));
			weight_ind := weight_ind + 1;
			
			if weight_delay = 1 then
			--	weight_ind := weight_ind + 1;
			--	weight_delay := 0;
			else
			--	weight_delay := 1;
			end if;
		end if;
	end if;
end process data_in;

out_res_gen : process
begin
	out_res_in <= '0', '1' after 55 ns, '0' after 75 ns;
	en <= '1', '0' after 85 ns;
	wait;
end process;

end architecture behaviour;