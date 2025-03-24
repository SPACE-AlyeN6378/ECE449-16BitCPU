-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity stage2_tb is 
end stage2_tb;

architecture behavioural of stage2_tb is

	signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal flush : std_logic := '0';
    signal en : std_logic := '1';

    signal branch_active : std_logic := '0';
    signal br_address_in: std_logic_vector(8 downto 0);
    
    -- Write signals
    signal wr_en: std_logic;
    signal wr_reg_index: std_logic_vector(2 downto 0);
    signal wr_data: std_logic_vector(15 downto 0);

    -- Outputs
    signal rd_data1_out: std_logic_vector(15 downto 0);
    signal rd_data2_out: std_logic_vector(15 downto 0);
    signal alu_mode_out: std_logic_vector(2 downto 0);
    signal br_mode_out: std_logic_vector(2 downto 0);
    signal mem_opr_out: std_logic_vector(0 downto 0);
    signal wb_opr_out: std_logic;
    signal br_active_out: std_logic;

    signal ra_out: std_logic_vector(2 downto 0);
    signal shift_count_out: std_logic_vector(3 downto 0);
    signal pc_address_out: std_logic_vector(8 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;
    
begin

	-- Instantiate the pipeline register directly using instantiation
    UUT: entity work.CPUDecode
    port map (
    	clk, rst, flush, en, br_address_in, branch_active, wr_en, wr_reg_index,
      wr_data, rd_data1_out, rd_data2_out, alu_mode_out, br_mode_out, mem_opr_out, 
      wb_opr_out, br_active_out, ra_out, shift_count_out, pc_address_out
    );
    
    -- Clock process
    clk_process: process
    begin
    	while now < 600 ns loop
          
          clk <= '0';
          wait for clk_period / 2;
          clk <= '1';
          wait for clk_period / 2;
          
       	end loop;
        wait;
    end process;
    
    
    -- Test process
    stim_proc: process
    begin
    
      -- INitialize the first branch
      br_address_in <= std_logic_vector(to_signed(0, 9));

      wr_en <= '1';
      wr_reg_index <= std_logic_vector(to_unsigned(1, 3));
      wr_data <= std_logic_vector(to_unsigned(4, 16));
      wait for clk_period;

      wr_reg_index <= std_logic_vector(to_unsigned(2, 3));
      wr_data <= std_logic_vector(to_unsigned(6, 16));
      wait for clk_period;

      wr_reg_index <= std_logic_vector(to_unsigned(0, 3));
      wr_data <= std_logic_vector(to_unsigned(15, 16));
      wait for clk_period;

      wr_reg_index <= std_logic_vector(to_unsigned(4, 3));
      wr_data <= std_logic_vector(to_unsigned(9, 16));
      wait for clk_period;

      -- wr_reg_index <= std_logic_vector(to_unsigned(2, 3));
      -- wr_data <= std_logic_vector(to_unsigned(6, 16));
      -- wait until falling_edge(clk);

      wr_en <= '0';
      wait for 22*clk_period;

      flush <= '1';
      wait for clk_period;
      flush <= '0';

      wait for 12*clk_period;

      wait;
      
	end process;
end behavioural;
    