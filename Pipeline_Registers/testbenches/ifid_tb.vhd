-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeline1_tb is 
end pipeline1_tb;

architecture behavioural of pipeline1_tb is
-- Testbench signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal enable : std_logic := '1';
    
    -- Instruction Input
    signal instr_in : std_logic_vector(15 downto 0) := X"0000";
    
    -- Outputs
    signal opcode: std_logic_vector(6 downto 0) := (others => '0'); -- Opcode
    signal ra: std_logic_vector(2 downto 0);
    signal rb: std_logic_vector(2 downto 0);
    signal rc: std_logic_vector(2 downto 0);
    signal c1: std_logic_vector(3 downto 0);
    
    signal disp1: std_logic_vector(8 downto 0); -- Direct disp values
    signal disp_s: std_logic_vector(5 downto 0);
    
    signal imm: std_logic_vector(7 downto 0);  -- Immediate values
    signal m1: std_logic;						-- Grab upper/lower byte
    signal r_dest: std_logic_vector(2 downto 0);	-- Destination register address
    signal r_src: std_logic_vector(2 downto 0);	-- Source Register address
    
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
begin
	-- Instantiate the pipeline register directly using instantiation
    UUT: entity work.ifid_pipeline_register
    port map (
    	clk => clk, rst => rst, enable => enable,
        instr_in => instr_in, opcode => opcode,
        ra => ra, rb => rb, rc => rc, c1 => c1,
        disp1 => disp1, disp_s => disp_s,
        imm => imm, m1 => m1, r_dest => r_dest, r_src => r_src
    );
    
    -- Clock process
    clk_process: process
    begin
    	while now < 200 ns loop
          
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
      -- Reset the pipeline
      rst <= '1';
      wait for 20 ns;
      rst <= '0';

      -- Test: Load an instruction
      instr_in <= "0000111010111101"; -- Sample instruction
      wait until rising_edge(clk);
	
      instr_in(15 downto 9) <= std_logic_vector(to_unsigned(96, 7));
      wait until rising_edge(clk);
      instr_in(15 downto 9) <= std_logic_vector(to_unsigned(97, 7));
      wait until rising_edge(clk);
      instr_in(15 downto 9) <= std_logic_vector(to_unsigned(98, 7));
      instr_in(8 downto 6) <= std_logic_vector(to_unsigned(7, 3));
      wait until rising_edge(clk);
      instr_in(15 downto 9) <= std_logic_vector(to_unsigned(99, 7));
--       instr_in(5 downto 3) <= std_logic_vector(to_unsigned(5, 3));
      wait until rising_edge(clk);
      
     
      -- Finish test
      wait;
      
	end process;
end behavioural;
