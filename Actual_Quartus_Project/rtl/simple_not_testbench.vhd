library ieee;
use ieee.std_logic_1164.all;

entity simple_not_testbench is
end entity simple_not_testbench;

architecture behaviour of simple_not_testbench is

	component simple_not is
		port(
			clk				: in std_logic;
			reset			: in std_logic;
			
			avs_wr_in_data		: in std_logic := '0';
			avs_in_data			: in std_logic_vector(31 downto 0);
			
			avs_rd_out_data		: in std_logic := '0';
			
			avs_out_data		: out std_logic_vector(31 downto 0)
		);
	end component simple_not;
	
	signal clk				: std_logic := '0';
	signal reset			: std_logic := '0';
	
	signal avs_wr_in_data	: std_logic := '0';
	signal avs_in_data		: std_logic_vector(31 downto 0);
	
	signal avs_rd_out_data	: std_logic := '0';
	
	signal avs_out_data		: std_logic_vector(31 downto 0);
	
begin
	
	simple_not_0 : simple_not port map (
		clk => clk,
		reset => reset,
		
		avs_wr_in_data => avs_wr_in_data,
		avs_in_data => avs_in_data,
		
		avs_rd_out_data => avs_rd_out_data,
		
		avs_out_data => avs_out_data
	);
	
	clk_gen : process
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process clk_gen;
	
	sig_gen : process
	begin
		reset <= '0', '1' after 120 ns;
		
		avs_wr_in_data <= '1', '0' after 20 ns;
		
		avs_in_data <= x"abcdefab", x"00000000" after 20 ns;
		
		avs_rd_out_data <= '0', '1' after 50 ns, '0' after 80 ns;
		
		wait;
	end process sig_gen;
	
end architecture behaviour;