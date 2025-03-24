import re

def get_all_ports(vhdl_code):
    # std_logic_vector_pattern = r"\b(\w+)\s*:\s*(in|out)\s+std_logic_vector\s*\(\s*\w+\s+downto\s*\w+\s*\)"
    std_logic_pattern = r"\b(\w+)\s*:\s*(in|out)\s+(std_logic(?:_vector\s*\(\s*\w+\s+downto\s*\w+\s*\))?)"

    matches = re.findall(std_logic_pattern, vhdl_code)
    return matches

def get_entity_name(vhdl_code):
    pattern = r"\bentity\s+(\w+)\s*is"
    return re.findall(pattern, vhdl_code)[0]

vhdl_tb_template = """
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity {entity}_tb is
end {entity}_tb;

architecture testbench of {entity}_tb is
{vhdl_signals}

begin

    UUT: entity work.{entity}
    port map (
{port_mappings}
    );

    -- Test process
    stim_proc: process
    begin
        -- ADD YOUR SIGNALS HERE
        wait;
    
    end process;
end testbench;
"""

filename = "2_execute/branch_cu.vhd"
tb_filename = filename.replace('.', '_tb.')

with open(filename, "r") as vhdl_file:
    vhdl_code = vhdl_file.read()
    ports = get_all_ports(vhdl_code)
    entity = get_entity_name(vhdl_code)

vhdl_signals = "\n".join([f"    signal {port[0]}: {port[2]};" for port in ports])
port_mappings = "\n".join([f"        {port[0]} => {port[0]}," for port in ports])[:-1]

with open(tb_filename, "w") as file:
    file.write(vhdl_tb_template.format(entity=entity, vhdl_signals=vhdl_signals, port_mappings=port_mappings))

