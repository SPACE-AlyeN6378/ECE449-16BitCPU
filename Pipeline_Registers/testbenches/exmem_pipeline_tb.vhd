library IEEE;
use IEEE.std_logic_1164.all;

entity exmem_pipeline_tb is
end exmem_pipeline_tb;

architecture testbench of exmem_pipeline_tb is

    -- Component Declaration
    component exmem_pipeline
        port (
            clk: in std_logic;
            rst: in std_logic;
            enable: in std_logic;
            
            alu_result_in_upper: in std_logic_vector(15 downto 0);
            alu_result_in_lower: in std_logic_vector(15 downto 0);
            mem_addr_in: in std_logic_vector(8 downto 0);
            mem_opr_in: in std_logic_vector(0 downto 0);
            wb_opr_in: in std_logic;
            
            alu_result_out_upper: out std_logic_vector(15 downto 0);
            alu_result_out_lower: out std_logic_vector(15 downto 0);
            mem_addr_out: out std_logic_vector(8 downto 0);
            mem_opr_out: out std_logic_vector(0 downto 0);
            wb_opr_out: out std_logic
        );
    end component;

    -- Signals
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal enable: std_logic := '0';
    
    signal alu_result_in_upper: std_logic_vector(15 downto 0) := (others => '0');
    signal alu_result_in_lower: std_logic_vector(15 downto 0) := (others => '0');
    signal mem_addr_in: std_logic_vector(8 downto 0) := (others => '0');
    signal mem_opr_in: std_logic_vector(0 downto 0) := (others => '0');
    signal wb_opr_in: std_logic := '0';

    signal alu_result_out_upper: std_logic_vector(15 downto 0);
    signal alu_result_out_lower: std_logic_vector(15 downto 0);
    signal mem_addr_out: std_logic_vector(8 downto 0);
    signal mem_opr_out: std_logic_vector(0 downto 0);
    signal wb_opr_out: std_logic;

    -- Clock Process
    constant CLK_PERIOD : time := 10 ns;
    begin
        -- Instantiate the Unit Under Test (UUT)
        uut: exmem_pipeline port map (
            clk => clk,
            rst => rst,
            enable => enable,
            alu_result_in_upper => alu_result_in_upper,
            alu_result_in_lower => alu_result_in_lower,
            mem_addr_in => mem_addr_in,
            mem_opr_in => mem_opr_in,
            wb_opr_in => wb_opr_in,
            alu_result_out_upper => alu_result_out_upper,
            alu_result_out_lower => alu_result_out_lower,
            mem_addr_out => mem_addr_out,
            mem_opr_out => mem_opr_out,
            wb_opr_out => wb_opr_out
        );

    -- Generate clock
    clk_process: process
    begin
        while now < 200 ns loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus Process
    stimulus_process: process
    begin
        -- Reset the system
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        -- Test 1: Load new values when enable is '1'
        enable <= '1';
        alu_result_in_upper <= "0000000000001010";  -- 10 in decimal
        alu_result_in_lower <= "0000000000010100";  -- 20 in decimal
        mem_addr_in <= "000000101";  -- Address 5
        mem_opr_in <= "1";  -- Memory operation active
        wb_opr_in <= '1';
        wait for CLK_PERIOD;

        -- Check output
        enable <= '0'; -- Hold values
        wait for CLK_PERIOD;

        -- Test 2: Load another set of values
        enable <= '1';
        alu_result_in_upper <= "0000000000001111";  -- 15 in decimal
        alu_result_in_lower <= "0000000000011111";  -- 31 in decimal
        mem_addr_in <= "000001011";  -- Address 11
        mem_opr_in <= "0";  -- No memory operation
        wb_opr_in <= '0';
        wait for CLK_PERIOD;

        -- Check output
        enable <= '0'; -- Hold values
        wait for CLK_PERIOD;

        -- Test 3: Reset
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;

        wait;
    end process;
end testbench;
