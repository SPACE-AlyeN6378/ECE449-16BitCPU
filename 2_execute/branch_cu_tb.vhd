
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity BranchControlUnit_tb is
end BranchControlUnit_tb;

architecture testbench of BranchControlUnit_tb is
    signal enable: std_logic;
    signal br_mode: std_logic_vector(2 downto 0);
    signal pc: std_logic_vector(8 downto 0);
    signal r_data: std_logic_vector(15 downto 0);
    signal disp: std_logic_vector(8 downto 0);
    signal z_flag: std_logic;
    signal n_flag: std_logic;
    signal br_active_final: std_logic;
    signal new_pc: std_logic_vector(8 downto 0);

begin

    UUT: entity work.BranchControlUnit
    port map (
        enable => enable,
        br_mode => br_mode,
        pc => pc,
        r_data => r_data,
        disp => disp,
        z_flag => z_flag,
        n_flag => n_flag,
        br_active_final => br_active_final,
        new_pc => new_pc
    );

    -- Test process
    stim_proc: process
    begin
        -- ADD YOUR SIGNALS HERE
        enable <= '1';

        br_mode <= "101";
        pc <= std_logic_vector(to_unsigned(16, 9));
        r_data <= std_logic_vector(to_unsigned(76, 16));
        disp <= std_logic_vector(to_signed(6, 9));

        z_flag <= '0'; n_flag <= '1';

        wait for 20 ns;

        br_mode <= "000";
        wait for 20 ns;

        br_mode <= "010";
        wait for 20 ns;

        wait;
    
    end process;
end testbench;
