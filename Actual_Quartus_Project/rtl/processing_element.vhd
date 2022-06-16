-- Cecil Symes

-- Processing Element (PE) takes in a weight and input map data, multiplies, and accumulates on every
-- rising edge of the clock

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity processing_element is
	port (
		clk				: in std_logic;
		en				: in std_logic;
		reset			: in std_logic;
		
		out_res_in		: in std_logic;
		weight_in		: in std_logic_vector(7 downto 0);
		input_img_in	: in std_logic_vector(7 downto 0);
		
		output_map		: out std_logic_vector(7 downto 0) := x"00";
		weight_out		: out std_logic_vector(7 downto 0) := x"00";
		input_img_out	: out std_logic_vector(7 downto 0) := x"00";
		out_res_out		: out std_logic := '0'
	);
end entity processing_element;

architecture behaviour of processing_element is
	signal internal_sum		: integer := 0;
	signal clear_int_sum	: std_logic := '0';
	signal weight_delay		: std_logic_vector(7 downto 0) := x"00";
	signal out_res_delay	: std_logic := '0';
begin

process (clk)
begin
if rising_edge(clk) then
	if reset = '1' then
		-- Reset internal signals
		internal_sum <= 0;
		clear_int_sum <= '1';
		weight_delay <= x"00";
		out_res_delay <= '0';
		
		--Reset outputs
		output_map <= x"00";
		weight_out <= x"00";
		input_img_out <= x"00";
		out_res_out <= '0';
	else
		if en = '1' then
			-- Pass weight along to next PE, every second clock cycle
			weight_out <= weight_delay;
			weight_delay <= weight_in;
			
			-- Pass the output/reset signal to next PE
			out_res_out <= out_res_in;
			out_res_delay <= out_res_in;
			
			-- Pass the input img data along to next PE
			input_img_out <= input_img_in;
			
			-- Output and reset internal sum if output/reset signal present
			if out_res_in = '1' then
				output_map <= std_logic_vector(to_unsigned(internal_sum, 8));
				clear_int_sum <= '1';
				internal_sum <= 0;
			end if;
			
			-- Clear internal values after delay when reset signal is detected
			if clear_int_sum = '1' then
				output_map <= x"00";
				weight_delay <= x"00";
				input_img_out <= x"00";
				clear_int_sum <= '0';
			else
				-- Multiply & Accumulate
				internal_sum <= internal_sum + (to_integer(unsigned(weight_in)) * to_integer(unsigned(input_img_in)));
			end if;
			
		end if;
	end if;
end if;

end process;

end architecture behaviour;