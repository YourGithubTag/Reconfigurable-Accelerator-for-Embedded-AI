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
		out_res_in		: in std_logic;
		weight_in		: in std_logic_vector(7 downto 0);
		input_map		: in std_logic_vector(7 downto 0);
		
		output_map		: out std_logic_vector(7 downto 0) := x"00";
		weight_out		: out std_logic_vector(7 downto 0) := x"00";
		out_res_out		: out std_logic := '0'
	);
end entity processing_element;

architecture behaviour of processing_element is
	signal internal_sum		: integer := 0;
begin

process (clk)
begin
if rising_edge(clk) then
	if en = '1' then
		-- Pass weight along to next PE
		weight_out <= weight_in;
		
		-- Pass the output/reset signal to next PE
		out_res_out <= out_res_in;
		
		-- Multiply & Accumulate
		internal_sum <= internal_sum + (to_integer(unsigned(weight_in)) * to_integer(unsigned(input_map)));
		
		-- Output and reset internal sum if output/reset signal present
		if out_res_in = '1' then
			output_map <= std_logic_vector(to_unsigned(internal_sum, 8));
			internal_sum <= 0;
		end if;
		
	end if;
end if;

end process;

end architecture behaviour;