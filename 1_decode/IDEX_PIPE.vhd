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
        shift_count_in: in std_logic_vector(3 downto 0);
        mem_opr_in: in std_logic_vector(0 downto 0);	-- Memory write operand
        mem_read_in: in std_logic;                      -- Read memory data, otherwise ALU data
        wb_opr_in: in std_logic;						-- WB Operand
        
        br_mode_in: in std_logic_vector(2 downto 0);	-- Branching type
        br_mode_out: out std_logic_vector(2 downto 0);	-- Branching type
       
    	dr1_out: out std_logic_vector(15 downto 0);		-- Register data 1
        dr2_out: out std_logic_vector(15 downto 0);  	-- Register data 2
        alu_mode_out: out std_logic_vector(2 downto 0);	-- ALU Mode
        shift_count_out: out std_logic_vector(3 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);	-- Memory operand
        mem_read_out: out std_logic;
        wb_opr_out: out std_logic;					-- Write-back Operand

        ra_in: in std_logic_vector(2 downto 0);
        ra_out: out std_logic_vector(2 downto 0);

        pc_address_in: in std_logic_vector(8 downto 0);
        pc_address_out: out std_logic_vector(8 downto 0);

        br_active_in: in std_logic;
        br_active_out: out std_logic;

        disp_in: in std_logic_vector(8 downto 0);
        disp_out: out std_logic_vector(8 downto 0)
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
                br_mode_out <= (others => '0');	    -- Branch enable mode
        		mem_opr_out <= (others => '0');		-- Memory operand
                mem_read_out <= '0';                -- Memory read mode
        		wb_opr_out <= '0';		            -- WB Operand
                ra_out <= (others => '0');
                pc_address_out <= (others => '0');
                br_active_out <= '0';
                disp_out <= (others => '0');

            elsif enable = '1' then
            	dr1_out <= rd_data1;			-- Register data 1
        		dr2_out <= rd_data2;  			-- Register data 2
        		alu_mode_out <= alu_mode_in;		-- ALU Mode
                br_mode_out <= br_mode_in;	        -- Branch enable mode
        		mem_opr_out <= mem_opr_in;			-- Memory operand
                mem_read_out <= mem_read_in;        -- Memory read mode
        		wb_opr_out <= wb_opr_in;			-- WB Operand
                shift_count_out <= shift_count_in;
                ra_out <= ra_in;
                pc_address_out <= pc_address_in;
                br_active_out <= br_active_in;
                disp_out <= disp_in;
                
            end if;
        end if;
	end process;
    
end behavioural;
             