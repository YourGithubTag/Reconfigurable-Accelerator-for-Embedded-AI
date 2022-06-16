-- Cecil Symes

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity fifo_testbench is
end entity fifo_testbench;

architecture behaviour of fifo_testbench is

	component fifo is
		generic (
			size			: positive := 4
		);
		port (
			clk				: in std_logic := '0';
			en				: in std_logic := '0';
			reset			: in std_logic := '0';
			
			data_in			: in std_logic_vector(7 downto 0) := x"00";
			write_data_in	: in std_logic := '0';
			
			read_data_out	: in std_logic := '0';
			data_out		: out std_logic_vector(7 downto 0) := x"00"
		);
	end component fifo;
	
	signal clk				: std_logic := '0';
	signal en				: std_logic := '0';
	signal reset			: std_logic := '0';
	
	signal write_data_in	: std_logic := '0';
	signal data_in			: std_logic_vector(7 downto 0) := x"00";
	
	signal read_data_out	: std_logic := '0';
	signal data_out			: std_logic_vector(7 downto 0) := x"00";

begin
	
	fifo_0 : fifo
	generic map (
		size => 10
	)
	port map(
		clk => clk,
		en => en,
		reset => reset,
		
		data_in => data_in,
		write_data_in => write_data_in,
		
		data_out => data_out,
		read_data_out => read_data_out
	);
	
	data_input : process
	begin
		en <= '1';
		reset <= '0';--, '1' after 140 ns, '0' after 150 ns;
		
		write_data_in <= '0', '1' after 10 ns, '0' after 60 ns, '1' after 140 ns, '0' after 200 ns;
		data_in <= x"01",
		x"02" after 10 ns,
		x"03" after 20 ns,
		x"04" after 30 ns,
		x"05" after 40 ns,
		x"06" after 50 ns,
		x"00" after 60 ns,
		
		x"07" after 140 ns,
		x"08" after 150 ns,
		x"09" after 160 ns,
		x"0A" after 170 ns,
		x"0B" after 180 ns,
		x"0C" after 190 ns,
		x"00" after 200 ns;
		
		read_data_out <= '0', '1' after 70 ns, '0' after 130 ns, '1' after 200 ns, '0' after 270 ns;
		
		wait;
	end process data_input;
	
	clk_gen : process
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process clk_gen;
	
end architecture behaviour;