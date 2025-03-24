@echo off
call ..\1_decode\cpu2_analyze.bat
ghdl -a ../2_execute/alu.vhd
ghdl -a ../2_execute/branch_cu.vhd
ghdl -a ../2_execute/EXMEM_PIPE.vhd
ghdl -a ../2_execute/cpu_stage3.vhd

