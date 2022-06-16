-- Cecil Symes

-- Instantiates PEs depending on the input generic size

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity systolic_array is
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
end entity systolic_array;

architecture behaviour of systolic_array is
	
	-- Constant num_PEs indicates how many PEs are required to generate the required output
	constant num_PEs	: positive := (img_rows - kern_rows) * img_cols + (img_cols - kern_cols) + 1;
	
	component processing_element is
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
	end component;
	
	-- Connections for signals between PEs
	type logic_connect_type is array (0 to num_PEs-1) of std_logic;
	signal out_res_connect	: logic_connect_type := (others => '0');
	
	type data_connect_type is array (0 to num_PEs-1) of std_logic_vector(7 downto 0);
	signal weight_connect	: data_connect_type := (others => x"00");
	signal input_connect	: data_connect_type := (others => x"00");
	signal outputs_array	: data_connect_type := (others => x"00");
	
	signal out_res_in_prev	: std_logic := '0';
	
	-- DEBUG
	signal sig_output_flag_int : std_logic := '0';
	signal sig_output_data_ctr : integer := 0;
	signal output_flag_int	: std_logic := '0';
	
begin

-- Generate specified number of PEs
PE_GEN : for i in 0 to num_PEs-1 generate

	FIRST_PE : if i = 0 generate
		PE0 : processing_element port map(
			clk => clk,
			en => en,
			reset => reset,
			
			out_res_in => out_res_in,
			weight_in => weight_in,
			input_img_in => img_data_in,
			
			input_img_out => input_connect(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate FIRST_PE;
	
	REST_PE : if i > 0 generate
		PEX : processing_element port map (
			clk => clk,
			en => en,
			reset => reset,
			
			out_res_in => out_res_connect(i - 1),
			weight_in => weight_connect(i - 1),
			input_img_in => input_connect(i - 1),
			
			input_img_out => input_connect(i),
			output_map => outputs_array(i),
			weight_out => weight_connect(i),
			out_res_out => out_res_connect(i)
		);
	end generate REST_PE;
	
end generate PE_GEN;

-- Process determines when to output the systolic array data
OUTPUT_LOGIC : process (clk)
	--variable output_flag_int	: std_logic := '0';
	variable output_data_ctr	: integer := 0;
	variable output_data_buf	: std_logic_vector(7 downto 0) := x"00";
begin
	if rising_edge(clk) then
		-- Raise the output_flag if out_res_in goes high
		if out_res_in = '1' and out_res_in_prev = '0' then
			output_flag_int <= '1';
			output_fin <= '0';
		end if;
		
		-- Lower the output_flag when out_res_in leaves last PE
		if out_res_connect(num_PEs - 1) = '1' then
			output_flag_int <= '0';
			output_fin <= '1';
		end if;
		
		-- Output systolic array data
		if output_flag_int = '1' then
			if sig_output_data_ctr < num_PEs then
				output_data <= outputs_array(sig_output_data_ctr);
				sig_output_data_ctr <= sig_output_data_ctr + 1;
			end if;
		else
			sig_output_data_ctr <= 0;
		end if;
		
		output_flag <= output_flag_int;
		out_res_in_prev <= out_res_in;
		
		-- DEBUG
		sig_output_flag_int <= output_flag_int;
		--sig_output_data_ctr <= sig_output_data_ctr;
		
	end if;
end process OUTPUT_LOGIC;

end architecture behaviour;