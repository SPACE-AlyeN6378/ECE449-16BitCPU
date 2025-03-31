-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CPU_tb is 
end CPU_tb;

architecture behavioural of CPU_tb is

	  signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal en : std_logic := '1';

    signal in_port: std_logic_vector(15 downto 0);

    signal branch_active : std_logic := '0';
    signal br_address_in: std_logic_vector(8 downto 0);
    
    -- Write signals
    signal wr_en: std_logic;
    signal wr_reg_index: std_logic_vector(2 downto 0);
    signal wr_data: std_logic_vector(15 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;
    
begin

	-- Instantiate the pipeline register directly using instantiation
    UUT: entity work.CPU
    port map (
    	clk, rst, en, in_port, wr_en, wr_reg_index, wr_data
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
      br_address_in <= std_logic_vector(to_signed(12, 9));

      wr_en <= '1';
      
      wr_data <= std_logic_vector(to_unsigned(4, 16));
      wr_reg_index <= std_logic_vector(to_unsigned(1, 3));
      wait for clk_period;
      
      wr_data <= std_logic_vector(to_unsigned(6, 16));
      wr_reg_index <= std_logic_vector(to_unsigned(2, 3));
      wait for clk_period;
      
      wr_data <= std_logic_vector(to_unsigned(15, 16));
      wr_reg_index <= std_logic_vector(to_unsigned(0, 3));
      wait for clk_period;
      
      
      wr_data <= std_logic_vector(to_unsigned(0, 16));
      wr_reg_index <= std_logic_vector(to_unsigned(3, 3));
      wait for clk_period;
      
      -- wr_reg_index <= std_logic_vector(to_unsigned(2, 3));
      -- wr_data <= std_logic_vector(to_unsigned(6, 16));
      -- wait until falling_edge(clk);
      wr_reg_index <= std_logic_vector(to_unsigned(0, 3));
      wr_en <= '0';
      wait for 22*clk_period;

      wait;
      
	end process;
end behavioural;
    