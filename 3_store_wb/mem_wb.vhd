library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity MEM_WBUnit is
    port (
        -- Input ports
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;

        alu_result_in: in std_logic_vector(15 downto 0);    -- Don't forget to route this to the memory as well
        mem_addr_in: in std_logic_vector(8 downto 0);   -- TODO: Port map this to the main memory/RAM
        mem_opr_in: in std_logic_vector(0 downto 0);    -- This too!
        wb_opr_in: in std_logic;
        ra_in: in std_logic_vector(2 downto 0);

        memory_injection: in std_logic_vector(15 downto 0); -- Replace this with mem_data_in, if you're connecting the memory

        data_out: out std_logic_vector(15 downto 0);
        wb_opr_out: out std_logic;
        ra_out: out std_logic_vector(2 downto 0)

    );
end MEM_WBUnit;

architecture behavioural of MEM_WBUnit is
    
    signal alu_result: std_logic_vector(15 downto 0);
    signal mem_data: std_logic_vector(15 downto 0);

begin

    -- Port mappings
    -- Memory: entity work.RAM      -- Add the memory component here
    -- port map (
    --     mem_opr_in, mem_addr_in, alu_result_in
    -- )
    
    WB_MUX: entity work.mux 
    port map(
        A => alu_result, B => mem_data, sel => mem_opr_in(0), C => data_out
    );

    -- Implement as many MUXes as you can

    Pipeline: entity work.memwb_pipeline
    port map (
        clk => clk, rst => rst, enable => en,
        mem_data_in => memory_injection,    -- Replace this with memory data from the RAM
        alu_result_in_lower => alu_result_in,
        wb_opr_in => wb_opr_in,
        ra => ra_in,
        
        alu_result_out_lower => alu_result,
        mem_data_out => mem_data,
        wb_opr_out => wb_opr_out,
        ra_out => ra_out
    );

end behavioural;