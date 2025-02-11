----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2025 06:12:54 PM
-- Design Name: 
-- Module Name: alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
port(
    rst : in std_logic; 
    clk: in std_logic;
    
    alu_mode: in std_logic_vector(2 downto 0);
--read signals
    rd_data1: in std_logic_vector(15 downto 0); 
    rd_data2: in std_logic_vector(15 downto 0);
    
--output signals
    result: out std_logic_vector(15 downto 0);
    z_flag: out std_logic;
    n_flag: out std_logic;
    
--write signals
end alu;

architecture Behavioral of alu is
    result <= std_logic_vector(unsigned(pr_in1) + unsigned(pr_in2));
begin


end Behavioral;
