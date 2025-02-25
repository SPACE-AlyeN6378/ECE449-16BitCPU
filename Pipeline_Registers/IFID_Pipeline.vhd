-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeline_register is

    port (
    	-- CORE INPUTS
    	clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable flow <ROUGH> (if the pipeline supports stalls)
        
        -- INSTRUCTION INPUT
        instr_in: in std_logic_vector(15 downto 0); -- Instruction from the memory/cache
        
        -- OUTPUTS
        opcode: out std_logic_vector(6 downto 0) := (others => '0'); -- Opcode
    
        -- Format A1/A3
       	ra: out std_logic_vector(2 downto 0);	-- Address of register A
        rb: out std_logic_vector(2 downto 0); 	-- Address of register B
        rc: out std_logic_vector(2 downto 0); 	-- Address of register C
        
        -- Format A2
        c1: out std_logic_vector(3 downto 0); 	-- Direct shift value
        
        -- Format B1-B2
        disp1: out std_logic_vector(8 downto 0); -- Direct disp values
        disp_s: out std_logic_vector(5 downto 0);
        
        -- Format L1 and L2 (LOAD/STORE/MOV)
        imm: out std_logic_vector(7 downto 0);  -- Immediate values
        m1: out std_logic;						-- Grab upper/lower byte
        r_dest: out std_logic_vector(2 downto 0);	-- Destination register address
        r_src: out std_logic_vector(2 downto 0)		-- Source Register address
    );
    
end pipeline_register;


architecture behavioural of pipeline_register is
	
-- 	signal instr_reg : std_logic_vector(15 downto 0) := (others => '0');  -- Temporary register signal
--     signal opcode_signal : std_logic_vector(6 downto 0);  -- Temporary opcode signal
--     signal opcode_int: integer;	-- For checking the type of opcode
begin
	process(clk, rst)
    	variable opcode_int: integer;	-- Define as a variable inside process
    begin
    	
    	if rising_edge(clk) then
        	if rst = '1' then
            	opcode <= (others => '0');
                ra <= (others => '0');
                rb <= (others => '0');
                rc <= (others => '0');
                c1 <= (others => '0');
                disp1 <= (others => '0');
                disp_s <= (others => '0');
                imm <= (others => '0');
                m1 <= '0';
                r_dest <= (others => '0');
                r_src <= (others => '0');
                
            elsif enable = '1' then
                opcode <= instr_in(15 downto 9); -- Assign opcode
                
                -- Convert opcode to integer for checking
                opcode_int := to_integer(unsigned(instr_in(15 downto 9)));
                
                -- Decode instruction based on opcode here:
                
                -- A-FORMAT: Arithmetic Instructions
                -- Format A1
                if (opcode_int >= 1 and opcode_int <= 4) then
                    ra <= instr_in(8 downto 6);
                    rb <= instr_in(5 downto 3);
                    rc <= instr_in(2 downto 0);
                
                -- Format A2
                elsif (opcode_int >= 5 and opcode_int <= 6) then
                	ra <= instr_in(8 downto 6);
                    c1 <= instr_in(3 downto 0);
                
                -- Format A3
                elsif (opcode_int = 7) or (opcode_int = 32) or 
                (opcode_int = 33) or (opcode_int >= 96 and opcode_int <= 98) then
                	ra <= instr_in(8 downto 6);
                    
                -- B-FORMAT: Branch Instructions
                -- Format B1
                elsif (opcode_int >= 64 and opcode_int <= 66) then
                	disp1 <= instr_in(8 downto 0);
               	
                elsif (opcode_int >= 67 and opcode_int <= 70) then 
                	ra <= instr_in(8 downto 6);
            		disp_s <= instr_in(5 downto 0);
                    
                -- L-FORMAT: Load/Store/Move
                -- Format L1
                elsif (opcode_int = 18) then
                	m1 <= instr_in(8);
                    imm <= instr_in(7 downto 0);
                
                -- Format L2
                elsif (opcode_int >= 16 and opcode_int <= 17) or (opcode_int = 19) then
                	r_dest <= instr_in(8 downto 6);
                	r_src <= instr_in(5 downto 3);
                
                -- The rest are of format A0
					
                end if;
                
            end if;
        end if;
    end process;
    
    
end behavioural;      	
                
    
                
                
            
    
    