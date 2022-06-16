library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_inc is
	port (
		clk				: in std_logic;
		reset			: in std_logic;
		
		avs_read_en		: in std_logic := '0';
		avs_data_out	: out std_logic_vector(31 downto 0) := x"00000abc"
	);	
end entity simple_inc;

architecture behaviour of simple_inc is
	signal int_cntr		: unsigned(31 downto 0) := x"00000abc";
begin

	process (clk)
	begin
		if rising_edge(clk) then
			
			if reset = '1' then
				avs_data_out <= x"00000abc";
				int_cntr <= x"00000abc";
			else
				
				if avs_read_en = '1' then
					int_cntr <= int_cntr + x"00000001";
					avs_data_out <= std_logic_vector(int_cntr);
				end if;
				
			end if;			
			
		end if;
	end process;

end architecture behaviour;