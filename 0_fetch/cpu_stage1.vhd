library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity CPUFetch is 
    port(
        clk : in std_logic;
        rst : in std_logic;
        
        -- Input signals
        br_address_in: in std_logic_vector(8 downto 0);
        en: in std_logic;
        branch_active: in std_logic;

        -- OUTPUTS
        opcode: out std_logic_vector(6 downto 0) := (others => '0'); -- Opcode
        -- reg_wr_en: out std_logic; (TESTED LATER)

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
        r_src: out std_logic_vector(2 downto 0);		-- Source Register address

        -- PC Address
        pc_address_out: out std_logic_vector(8 downto 0)
        
    ); -- these get assigned in port maps as portmap(clk => CLOCK) to help wire between files
        -- inter file uses comments on bottom to declare.

end CPUFetch;


architecture Behavioral of CPUFetch is
    signal addr  : std_logic_vector(8 downto 0);
    signal instr_data  : std_logic_vector(15 downto 0);

begin
    -- PORT MAPPINGS
    pc: entity work.ProgramCounter
    port map (
    	clk => clk, rst => rst, en => en, branch_active => branch_active,
        br_address_in => br_address_in, address_out => addr
    );

    icache: entity work.instruction_cache port map (
    	clk => clk, en => en, addr => addr, data => instr_data
    );

    pipeline: entity work.ifid_pipeline_register port map (
            clk => clk, rst => rst, enable => en, 
            instr_in => instr_data, opcode => opcode, 
            -- reg_wr_en => reg_wr_en, 
            ra => ra, rb => rb, rc => rc, c1 => c1, 
            disp1 => disp1, disp_s => disp_s, 
            imm => imm, m1 => m1, r_dest => r_dest, r_src => r_src,
            pc_address_in => addr, 
            pc_address_out => pc_address_out
    );

end Behavioral;


