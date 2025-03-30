library IEEE;
use IEEE.std_logic_1164.all;


entity exmem_pipeline is
	port (
    	-- CORE INPUTS
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        
        -- Inputs from the Register file and the controller
        --alu_result_in_upper: in std_logic_vector(15 downto 0);		-- ALU Result
        alu_result_in: in std_logic_vector(15 downto 0);
        mem_addr_in: in std_logic_vector(8 downto 0);           -- Memory address from register data
        mem_opr_in: in std_logic_vector(0 downto 0);			-- Memory operand
        mem_read_in: in std_logic;                              -- Memory read mode, otherwise read from ALU
        wb_opr_in: in std_logic;								-- WB Operand
        ra_in: in std_logic_vector(2 downto 0);
        
    	--alu_result_out_upper: out std_logic_vector(15 downto 0);		-- ALU Result (Upper half)
        --ra: out std_logic_vector(2 downto 0);	-- Address of register A
        alu_result_out: out std_logic_vector(15 downto 0);		-- ALU Result (Lower half)
        mem_addr_out: out std_logic_vector(8 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);			-- Memory operand
        mem_read_out: out std_logic;
        wb_opr_out: out std_logic;
        ra_out: out std_logic_vector(2 downto 0)									-- WB Operand
    );
    
end exmem_pipeline;

architecture behavioural of exmem_pipeline is
begin
	process(clk, rst)
    begin
    	if rising_edge(clk) then
        	if rst = '1' then
            	--alu_result_out_upper <= (others => '0');
                alu_result_out <= (others => '0');
                mem_addr_out <= (others => '0');
        		mem_opr_out <= (others => '0');
                mem_read_out <= '0';
        		wb_opr_out <= '0';	
                ra_out <= (others => '0');
                
            elsif enable = '1' then
        		--alu_result_out_upper <= alu_result_in_upper;	
                alu_result_out <= alu_result_in;
                mem_addr_out <= mem_addr_in;
        		mem_opr_out <= mem_opr_in;	
                mem_read_out <= mem_read_in;		
        		wb_opr_out <= wb_opr_in;
                ra_out <= ra_in;		
                
            end if;
        end if;
	end process;
    
end behavioural;