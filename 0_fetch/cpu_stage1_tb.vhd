-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity stage1_tb is 
end stage1_tb;

architecture behavioural of stage1_tb is

	signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal en : std_logic := '1';
    signal br_active : std_logic := '0';
    
    signal br_address_in: std_logic_vector(8 downto 0);
    
    -- Output signal
    signal opcode: std_logic_vector(6 downto 0);
    signal reg_wr_en: std_logic;
    
    -- Clock period
    constant clk_period : time := 10 ns;

    -- Format A1/A3
    signal ra: std_logic_vector(2 downto 0);	-- Address of register A
    signal rb: std_logic_vector(2 downto 0); 	-- Address of register B
    signal rc: std_logic_vector(2 downto 0); 	-- Address of register C
    
    -- Format A2
    signal c1: std_logic_vector(3 downto 0); 	-- Direct shift value
    
    -- Format B1-B2
    signal disp1: std_logic_vector(8 downto 0); -- Direct disp values
    signal disp_s: std_logic_vector(5 downto 0);
    
    -- Format L1 and L2 (LOAD/STORE/MOV)
    signal imm: std_logic_vector(7 downto 0);  -- Immediate values
    signal m1: std_logic;						-- Grab upper/lower byte
    signal r_dest: std_logic_vector(2 downto 0);	-- Destination register address
    signal r_src: std_logic_vector(2 downto 0);		-- Source Register address
    
begin

	-- Instantiate the pipeline register directly using instantiation
    UUT: entity work.CPUFetch
    port map (
    	clk => clk, rst => rst, en => en, branch_active => br_active,
        br_address_in => br_address_in, opcode => opcode,
        ra => ra, rb => rb, rc => rc, c1 => c1, 
        disp1 => disp1, disp_s => disp_s, 
        imm => imm, m1 => m1, r_dest => r_dest, r_src => r_src
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
      wait for clk_period;
      
  	  -- After iterating through 5 lines, set branch active
      wait for 28*clk_period;
      
      br_active <= '1';
      wait for clk_period;
      br_active <= '0';
      
      wait for 10*clk_period;

      br_address_in <= std_logic_vector(to_signed(12, 9));
      br_active <= '1';
      wait for clk_period;
      br_active <= '0';
      
      en <= '0';
      wait for 30 ns;
      en <= '1';
      
      wait;
      
	end process;
end behavioural;
    