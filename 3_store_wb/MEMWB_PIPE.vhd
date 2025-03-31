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
        alu_result_in: in std_logic_vector(15 downto 0);	    -- ALU Result
        input_data: in std_logic_vector(15 downto 0);              -- Input data
        wb_opr_in: in std_logic;								-- WB Operand
        data_type_in: in std_logic_vector(1 downto 0);          -- Decision between ALU data, memory data, for writeback
        -- mem_opr_in: in std_logic_vector(0 downto 0);			-- Memory operand
        ra_in: in std_logic_vector(2 downto 0);					-- Register A address
        
        data_out: out std_logic_vector(15 downto 0);
        wb_opr_out: out std_logic;		
        ra_out: out std_logic_vector(2 downto 0)
        --ra_sel: in std_logic
    );
    
end memwb_pipeline;

architecture behavioural of memwb_pipeline is
begin
	process(clk, rst, data_type_in)
    begin
    	if rising_edge(clk) then
        	if rst = '1' then
                data_out <= (others => '0');
        		wb_opr_out <= '0';		
        		ra_out <= (others => '0');
                
            elsif enable = '1' then
                case data_type_in is
                    when "01" => data_out <= alu_result_in;     -- Use ALU Result
                    when "10" => data_out <= mem_data_in;       -- Use Memory data
                    when "11" => data_out <= input_data;        -- 
                    when others => data_out <= (others => '0');
                end case;

        		wb_opr_out <= wb_opr_in;		
        		ra_out <= ra_in;
                
            end if;
        end if;
	end process;
    
end behavioural;