@echo off
ghdl -a ../2_execute/alu.vhd
ghdl -a ../2_execute/branch_cu.vhd
ghdl -a ../2_execute/EXMEM_PIPE.vhd
ghdl -a ../2_execute/execute.vhd

