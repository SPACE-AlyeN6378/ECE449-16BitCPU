
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity ExecutionStage_tb is
end ExecutionStage_tb;

architecture testbench of ExecutionStage_tb is
    signal clk: std_logic;
    signal rst: std_logic := '0';
    signal en: std_logic := '1';

    signal rd_data1: std_logic_vector(15 downto 0);
    signal rd_data2: std_logic_vector(15 downto 0);
    signal alu_mode: std_logic_vector(2 downto 0);
    signal shift_count: std_logic_vector(3 downto 0);
    signal mem_opr: std_logic_vector(0 downto 0) := "1";
    signal wb_opr: std_logic := '1';
    signal ra: std_logic_vector(2 downto 0);
    signal br_mode: std_logic_vector(2 downto 0) := "000";
    signal disp: std_logic_vector(8 downto 0);
    signal br_enable: std_logic;
    signal pc_address: std_logic_vector(8 downto 0);
    signal br_address_to_pc: std_logic_vector(8 downto 0);
    signal br_enable_to_pc: std_logic;
    signal alu_result_out: std_logic_vector(15 downto 0);
    signal mem_addr_out: std_logic_vector(8 downto 0);
    signal mem_opr_out: std_logic_vector(0 downto 0);
    signal wb_opr_out: std_logic;
    signal ra_out: std_logic_vector(2 downto 0);

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    UUT: entity work.ExecutionStage
    port map (
        clk => clk,
        rst => rst,
        en => en,
        rd_data1 => rd_data1,
        rd_data2 => rd_data2,
        alu_mode => alu_mode,
        shift_count => shift_count,
        mem_opr => mem_opr,
        wb_opr => wb_opr,
        ra => ra,
        br_mode => br_mode,
        disp => disp,
        br_enable => br_enable,
        pc_address => pc_address,
        br_address_to_pc => br_address_to_pc,
        br_enable_to_pc => br_enable_to_pc,
        alu_result_out => alu_result_out,
        mem_addr_out => mem_addr_out,
        mem_opr_out => mem_opr_out,
        wb_opr_out => wb_opr_out,
        ra_out => ra_out
    );

    -- Clock process
    clk_process: process
    begin
    	while now < 600 ns loop
          
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
          
       	end loop;
        wait;
    end process;

    -- Test process
    stim_proc: process
    begin
        -- ADD YOUR SIGNALS HERE
        ra <= "010";
        pc_address <= std_logic_vector(to_signed(65, 9));
        disp <= std_logic_vector(to_signed(-4, 9));
        br_enable <= '1';

        rd_data1 <= std_logic_vector(to_signed(12, 16));
        rd_data2 <= std_logic_vector(to_signed(-34, 16));
        shift_count <= std_logic_vector(to_unsigned(4, 4));

        alu_mode <= "001";
        wait for 10 ns;

        br_mode <= "001";
        wait for 10 ns;

        br_mode <= "010";
        wait for 10 ns;

        br_mode <= "100";
        wait for 10 ns;

        br_mode <= "101";
        wait for 10 ns;

        br_mode <= "110";
        wait for 10 ns;

        br_mode <= "111";
        wait for 10 ns;

        wait;
    
    end process;
end testbench;
