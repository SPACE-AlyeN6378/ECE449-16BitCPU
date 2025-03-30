-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity pc_tb is 
end pc_tb;

architecture behavioural of pc_tb is

	signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal en : std_logic := '1';
    signal br_active : std_logic := '0';
    
    signal br_address_in: std_logic_vector(8 downto 0);
    
    -- Output signal
    signal address_out: std_logic_vector(8 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
begin

	-- Instantiate the pipeline register directly using instantiation
    UUT: entity work.ProgramCounter
    port map (
    	clk => clk, rst => rst, en => en, branch_active => br_active,
        br_address_in => br_address_in, address_out => address_out
    );
    
    -- Clock process
    clk_process: process
    begin
    	while now < 500 ns loop
          
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
      
  	  -- After iterating through 5 lines, set branch active
      wait for 22*clk_period;
      
      br_address_in <= std_logic_vector(to_signed(16, 9));
      br_active <= '1';
      wait for clk_period;
      br_active <= '0';
      
    
        wait for 10*clk_period;

    --   wait for 10*clk_period;
    --   br_address_in <= std_logic_vector(to_signed(12, 9));
    --   br_active <= '1';
    --   wait for clk_period;
    --   br_active <= '0';
      
    --   en <= '0';
    --   wait for 30 ns;
    --   en <= '1';
      
      wait;
      
	end process;
end behavioural;
    