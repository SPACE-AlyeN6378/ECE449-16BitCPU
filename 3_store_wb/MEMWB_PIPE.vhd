-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity memwb_pipeline is
	port (
    	-- CORE INPUTS
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        
        -- Inputs from the Memory and the EX/MEM
        mem_data_in: in std_logic_vector(15 downto 0);			-- Memory data
        alu_result_in_lower: in std_logic_vector(15 downto 0);	-- ALU Result
        wb_opr_in: in std_logic;								-- WB Operand
        -- mem_opr_in: in std_logic_vector(0 downto 0);			-- Memory operand
        ra: in std_logic_vector(2 downto 0);					-- Register A address
        
        mem_data_out: out std_logic_vector(15 downto 0);
        alu_result_out_lower: out std_logic_vector(15 downto 0);	
        wb_opr_out: out std_logic;		
        ra_out: out std_logic_vector(2 downto 0)
        --ra_sel: in std_logic
    );
    
end memwb_pipeline;

architecture behavioural of memwb_pipeline is
begin
	process(clk, rst)
    begin
    	if rising_edge(clk) then
        	if rst = '1' then
                mem_data_out <= (others => '0');
        		alu_result_out_lower <= (others => '0');	
        		wb_opr_out <= '0';		
        		ra_out <= (others => '0');
                
            elsif enable = '1' then
                -- if mem_opr_in = "1" then 
                --     alu_result_out_lower <= mem_data_in;	
                -- else
                --     alu_result_out_lower <= alu_result_in_lower;
                -- end if;
                alu_result_out_lower <= alu_result_in_lower;
        		mem_data_out <= mem_data_in;
        		wb_opr_out <= wb_opr_in;		
        		ra_out <= ra;
                
            end if;
        end if;
	end process;
    
end behavioural;