library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity CPU is
    port (
        -- Input ports
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;

        memory_injection: in std_logic_vector(15 downto 0);

        in_port: in std_logic_vector(15 downto 0);
        out_port: out std_logic_vector(15 downto 0);
    );
end CPU;

architecture behavioral of CPU is
    signal alu_result: std_logic_vector(15 downto 0); 
    signal mem_addr: std_logic_vector(8 downto 0); 
    signal mem_opr: std_logic_vector(0 downto 0); 
    signal wb_opr: std_logic;
    signal wr_data: std_logic_vector(15 downto 0);
    signal ra: std_logic_vector(2 downto 0);

begin
    out_port <= (others => '0');    -- STUBBED for now

    CPU_EXEC: entity work.CPUExecute
    port map(
        clk => clk, rst => rst, en => en,
        wr_en => wb_opr,       -- Writes back to register A
        wr_reg_index => ra,    -- Register index ra
        wr_data => wr_data,
        
    );
end behavioral;