-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;


entity exmem_pipeline is
	port (
    	-- CORE INPUTS
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        
        -- Inputs from the Register file and the controller
        alu_result_in_upper: in std_logic_vector(15 downto 0);		-- ALU Result
        alu_result_in_lower: in std_logic_vector(15 downto 0);
        mem_addr_in: in std_logic_vector(8 downto 0);
        mem_opr_in: in std_logic_vector(0 downto 0);			-- Memory operand
        wb_opr_in: in std_logic;								-- WB Operand
        
        
    	alu_result_out_upper: out std_logic_vector(15 downto 0);		-- ALU Result (Upper half)
        alu_result_out_lower: out std_logic_vector(15 downto 0);		-- ALU Result (Lower half)
        mem_addr_out: out std_logic_vector(8 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);			-- Memory operand
        wb_opr_out: out std_logic								-- WB Operand
    );
    
end exmem_pipeline;

architecture behavioural of exmem_pipeline is
begin
	process(clk, rst)
    begin
    	if rising_edge(clk) then
        	if rst = '1' then
            	alu_result_out_upper <= (others => '0');
                alu_result_out_lower <= (others => '0');
                mem_addr_out <= (others => '0');
        		mem_opr_out <= (others => '0');
        		wb_opr_out <= '0';	
                
            elsif enable = '1' then
        		alu_result_out_upper <= alu_result_in_upper;	
                alu_result_out_lower <= alu_result_in_lower;
                mem_addr_out <= mem_addr_in;
        		mem_opr_out <= mem_opr_in;			
        		wb_opr_out <= wb_opr_in;		
                
            end if;
        end if;
	end process;
    
end behavioural;
