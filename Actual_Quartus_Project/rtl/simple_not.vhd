library ieee;
use ieee.std_logic_1164.all;

entity simple_not is
	port(
		clk				: in std_logic;
		reset			: in std_logic;
		
		avs_wr_in_data		: in std_logic := '0';
		avs_in_data			: in std_logic_vector(31 downto 0);
		
		avs_rd_out_data		: in std_logic := '0';
		
		avs_out_data		: out std_logic_vector(31 downto 0)
	);
end entity simple_not;

architecture behaviour of simple_not is
	signal internal			: std_logic_vector(31 downto 0) := x"aaaaaaaa";
begin
	
	process (clk)
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				internal <= x"00000000";
				avs_out_data <= x"00000000";
			else
			
				if (avs_wr_in_data = '1') then
					internal <= avs_in_data;
				end if;
				
				if (avs_rd_out_data = '1') then
					avs_out_data <= internal;
				else
					avs_out_data <= x"00000000";
				end if;
				
			end if;
			
		end if;
	end process;
	
end architecture behaviour;