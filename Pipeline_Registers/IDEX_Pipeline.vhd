-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity idex_pipeline is
	port (
    	-- CORE INPUTS
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        
        -- Inputs from the Register file and the controller
        rd_data1: in std_logic_vector(15 downto 0);		-- Register data 1
        rd_data2: in std_logic_vector(15 downto 0);  	-- Register data 2
        alu_mode_in: in std_logic_vector(2 downto 0);	-- ALU Mode
        mem_opr_in: in std_logic_vector(0 downto 0);	-- Memory operand
        wb_opr_in: in std_logic;						-- WB Operand
        
    	dr1_out: out std_logic_vector(15 downto 0);		-- Register data 1
        dr2_out: out std_logic_vector(15 downto 0);  	-- Register data 2
        alu_mode_out: out std_logic_vector(2 downto 0);	-- ALU Mode
        mem_opr_out: out std_logic_vector(0 downto 0);	-- Memory operand
        wb_opr_out: out std_logic						-- Write-back Operand
    );
    
end idex_pipeline;

architecture behavioural of idex_pipeline is
begin
	process(clk, rst)
    begin
    	if rising_edge(clk) then
        	if rst = '1' then
            	dr1_out <= (others => '0');			-- Register data 1
        		dr2_out <= (others => '0');  		-- Register data 2
        		alu_mode_out <= (others => '0');	-- ALU Mode
        		mem_opr_out <= (others => '0');		-- Memory operand
        		wb_opr_out <= '0';		-- WB Operand
                
            elsif enable = '1' then
            	dr1_out <= rd_data1;			-- Register data 1
        		dr2_out <= rd_data2;  			-- Register data 2
        		alu_mode_out <= alu_mode_in;		-- ALU Mode
        		mem_opr_out <= mem_opr_in;			-- Memory operand
        		wb_opr_out <= wb_opr_in;			-- WB Operand
                
            end if;
        end if;
	end process;
    
end behavioural;
             
