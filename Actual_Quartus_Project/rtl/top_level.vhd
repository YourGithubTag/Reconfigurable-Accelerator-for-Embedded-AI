-- Cecil Symes

-- Top level entity with Systolic Array and MMU connected
-- control bits:
-- 		0 - en
--		1 - begin_conv
--		2 - reset
--		3 - test_bit


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;
use work.CustomTypes.all;

entity top_level is
	generic (
		feat_map_rows		: integer := 9;
		feat_map_cols		: integer := 9;
		
		weight_rows			: integer := 2;
		weight_cols			: integer := 2
	);
	port (
		clk					: in std_logic;
		reset				: in std_logic := '0';
		
		write_weights		: in std_logic := '0';
		weight_in			: in std_logic_vector(7 downto 0) := x"00";
		
		write_feat_map		: in std_logic := '0';
		feat_map_in			: in std_logic_vector(7 downto 0) := x"00";
		
		write_control		: in std_logic := '0';
		control				: in std_logic_vector(7 downto 0) := x"00";
		
		read_output_flag	: in std_logic := '0';
		output_flag			: out std_logic_vector(7 downto 0) := x"00";
		
		read_output_map		: in std_logic := '0';
		output_map			: out std_logic_vector(7 downto 0) := x"00";
		
		test_bit			: out std_logic_vector(7 downto 0) := x"00"
	);
end entity top_level;

architecture behaviour of top_level is

	-- Memory Management Unit Component Declaration
	component memory_management_unit is
		generic (
			feat_map_rows		: integer := 4;
			feat_map_cols		: integer := 4;
			
			weight_rows			: integer := 2;
			weight_cols			: integer := 2
		);
		port (
			clk					: in std_logic;
			reset				: in std_logic := '0';
			
			write_feat_map		: in std_logic := '0';
			output_feat_map		: in std_logic := '0';
			feat_map_in			: in std_logic_vector(7 downto 0) := x"00";
			
			write_weight		: in std_logic := '0';
			output_weights		: in std_logic := '0';
			weight_in			: in std_logic_vector(7 downto 0) := x"00";
			
			end_of_img			: out std_logic := '0';
			feat_map_out		: out std_logic_vector(7 downto 0) := x"00";
			weight_out			: out std_logic_vector(7 downto 0) := x"00"
		);
	end component;
	
	-- Systolic Array Component Declaration
	component systolic_array is
		generic (
			img_rows			: positive := 4;
			img_cols			: positive := 4;
			
			kern_rows			: positive := 2;
			kern_cols			: positive := 2
		);
		port (
			clk					: in std_logic := '0';
			en					: in std_logic := '0';
			reset				: in std_logic := '0';
			
			out_res_in			: in std_logic := '0';
			img_data_in			: in std_logic_vector(7 downto 0) := x"00";
			weight_in			: in std_logic_vector(7 downto 0) := x"00";
			
			output_flag			: out std_logic := '0';
			output_fin			: out std_logic := '0';
			output_data			: out std_logic_vector(7 downto 0) := x"00"
		);
	end component;
	
	-- FIFO Buffer Component Declaration
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
		
	-- Internal Signals
	signal control_int		: std_logic_vector(7 downto 0) := x"04";
	signal en				: std_logic := '0';
	signal begin_conv		: std_logic := '0';
	signal reset_int		: std_logic := '0';
	
	signal output_flag_int	: std_logic := '0';
	signal output_map_int	: std_logic_vector(7 downto 0) := x"00";
	
	-- MMU Input Signals
	signal mmu_output_data	: std_logic := '0';
	
	-- Connection Signal Declarations
	signal end_of_img_cnct	: std_logic := '0';
	signal feat_map_cnct	: std_logic_vector(7 downto 0) := x"00";
	signal weight_cnct		: std_logic_vector(7 downto 0) := x"00";
	
	-- Sys Array Input Declarations
	signal sa_en			: std_logic := '0';
	
	-- Sys Array Output Signal Declarations
	signal sa_output_fin	: std_logic := '0';
	
begin
	
	-- MMU Component Generation
	MMU : memory_management_unit
	generic map (
		feat_map_rows => feat_map_rows,
		feat_map_cols => feat_map_cols,
		weight_rows => weight_rows,
		weight_cols => weight_cols
	)
	port map (
		clk => clk,
		reset => reset_int,
		
		write_feat_map => write_feat_map,
		output_feat_map => mmu_output_data,
		feat_map_in => feat_map_in,
		
		write_weight => write_weights,
		output_weights => mmu_output_data,
		weight_in => weight_in,
		
		end_of_img => end_of_img_cnct,
		feat_map_out => feat_map_cnct,
		weight_out => weight_cnct
	);
	
	-- Systolic Array Component Generation
	SYS_ARRAY : systolic_array
	generic map (
		img_rows => feat_map_rows,
		img_cols => feat_map_cols,
		kern_rows => weight_rows,
		kern_cols => weight_cols
	)
	port map (
		clk => clk,
		en => sa_en,
		reset => reset_int,
		
		out_res_in => end_of_img_cnct,
		img_data_in => feat_map_cnct,
		weight_in => weight_cnct,
		
		output_flag => output_flag_int,
		output_fin => sa_output_fin,
		output_data => output_map_int
	);
	
	-- FIFO Buffer Component Generation
	FIFO_BUF : fifo
	generic map (
		size => 12
	)
	port map (
		clk => clk,
		en => en,
		reset => reset_int,
		
		data_in => output_map_int,
		write_data_in => output_flag_int,
		
		read_data_out => read_output_map,
		data_out => output_map
	);
	
	test_bit <= control;
	--output_map <= output_map_int when read_output_map = '1' else x"00";
	
	-- Map control to en and begin_conv
	en <= control(0);
	begin_conv <= control(1);
	reset_int <= control(2);
	
	-- Write control_int
	control_write : process (clk)
	begin
		if rising_edge(clk) and write_control = '1' then
			control_int <= control;
		end if;
	end process control_write;
	
	-- Output flag logic
	output_flag_process : process(clk)
	begin
		if rising_edge(clk) then
			
			if output_flag_int = '1' and read_output_flag = '1' then
				output_flag <= "0000000" & output_flag_int;
			else
				output_flag <= x"00";
			end if;
			
		end if;
	end process output_flag_process;
	
	-- Data feeder
	data_feed : process (clk, en)
		variable feat_map_idx	: integer := 0;
		variable weight_idx		: integer := 0;
	begin
		if rising_edge(clk) and en = '1' then
			
			-- Start convolution when begin_conv is raised
			if begin_conv = '1' then
				-- Enable MMU output
				mmu_output_data <= '1';
				
				-- Enable Sys Array
				sa_en <= '1';
			end if;
			
			-- Lower MMU output flag when end_of_img raised
			if end_of_img_cnct = '1' then
				mmu_output_data <= '0';
			end if;
			
			-- Disable SA when reached end of output
			if sa_output_fin = '1' then
				sa_en <= '0';
			end if;
			
		end if;
	end process data_feed;
	
end architecture behaviour;