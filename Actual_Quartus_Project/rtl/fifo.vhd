-- Cecil Symes

-- Acts as a First In First Out (FIFO) buffer

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity fifo is
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
end entity fifo;

architecture behaviour of fifo is
	
	-- Internal Memory of the FIFO
	type int_mem_type is array (0 to (size - 1)) of std_logic_vector(7 downto 0);
	signal int_mem		: int_mem_type := (1 => x"01", 2 => x"02", 3 => x"03", others => x"00");
	
begin

	main_process : process(clk)
		-- Counters for input and output
		variable input_idx		: integer range 0 to size := 0;
		variable output_idx		: integer range 0 to size := 0;
	begin
		if rising_edge(clk) then
			
			-- Handle reset signal
			if reset = '1' then
				input_idx := 0;
				output_idx := 0;
				int_mem <= (others => x"00");
				
			elsif en = '1' then
				
				-- Handle input data
				if write_data_in = '1' then
					int_mem(input_idx) <= data_in;
					input_idx := input_idx + 1;
					
					if input_idx = size then
						input_idx := 0;
					end if;
				end if;
		
				-- Handle output data
				if read_data_out = '1' then
					data_out <= int_mem(output_idx);
					
					if output_idx /= (input_idx - 1) then
						output_idx := output_idx + 1;
					end if;
					
					if output_idx = size then
						output_idx := 0;
					end if;
				end if;
				
			end if;
		
		end if;
	end process main_process;
end architecture behaviour;