library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_inc_testbench is
end entity simple_inc_testbench;

architecture behaviour of simple_inc_testbench is

	component simple_inc is
		port (
			clk				: in std_logic;
			reset			: in std_logic;
			en				: in std_logic;
			
			avs_data_out	: out std_logic_vector(31 downto 0) := x"00000000"
		);	
	end component simple_inc;

	signal clk				: std_logic := '0';
	signal reset			: std_logic := '0';
	signal en				: std_logic := '0';
	
	signal avs_data_out		: std_logic_vector(31 downto 0) := x"00000000";
	
begin

	simple_inc_0 : simple_inc port map(
		clk => clk,
		reset => reset,
		en => en,
		
		avs_data_out => avs_data_out
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
		reset <= '0', '1' after 110 ns, '0' after 130 ns;
		
		en <= '0', '1' after 20 ns, '0' after 100 ns;
		
		wait;
	end process sig_gen;
	
end architecture behaviour;