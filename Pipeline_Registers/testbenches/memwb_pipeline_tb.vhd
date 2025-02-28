library IEEE;
use IEEE.std_logic_1164.all;

entity memwb_pipeline_tb is
end memwb_pipeline_tb;

architecture testbench of memwb_pipeline_tb is

    -- Component Declaration

    -- Signals
    signal clk: std_logic := '0';
    signal rst: std_logic := '0';
    signal enable: std_logic := '0';
    
    signal mem_data_in: std_logic_vector(15 downto 0) := (others => '0');
    signal alu_result_in_lower: std_logic_vector(15 downto 0) := (others => '0');
    signal wb_opr_in: std_logic := '0';
    signal ra: std_logic_vector(2 downto 0) := (others => '0');

    signal mem_data_out: std_logic_vector(15 downto 0);
    signal alu_result_out_lower: std_logic_vector(15 downto 0);
    signal wb_opr_out: std_logic;
    signal ra_out: std_logic_vector(2 downto 0);

    -- Clock Process
    constant CLK_PERIOD : time := 10 ns;
    begin
        -- Instantiate the Unit Under Test (UUT)
        uut: entity work.memwb_pipeline port map (
            clk => clk,
            rst => rst,
            enable => enable,
            mem_data_in => mem_data_in,
            alu_result_in_lower => alu_result_in_lower,
            wb_opr_in => wb_opr_in,
            ra => ra,
            mem_data_out => mem_data_out,
            alu_result_out_lower => alu_result_out_lower,
            wb_opr_out => wb_opr_out,
            ra_out => ra_out
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
        mem_data_in <= "0000000000001010";  -- 10 in decimal
        alu_result_in_lower <= "0000000000010100"; -- 20 in decimal
        wb_opr_in <= '1';
        ra <= "011"; -- Register 3
        wait for CLK_PERIOD;

        -- Check output
        enable <= '0'; -- Hold values
        wait for CLK_PERIOD;

        -- Test 2: Load another set of values
        enable <= '1';
        mem_data_in <= "0001010000001111";  -- 15 in decimal
        alu_result_in_lower <= "0000000000011111"; -- 31 in decimal
        wb_opr_in <= '0';
        ra <= "101"; -- Register 5
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
