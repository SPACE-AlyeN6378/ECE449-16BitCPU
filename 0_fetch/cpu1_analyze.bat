@echo off
ghdl -a ../0_fetch/IFID_PIPE.vhd
ghdl -a ../0_fetch/instr_cache.vhd
ghdl -a ../0_fetch/program_counter.vhd

@REM THE TOP FILE
ghdl -a ../0_fetch/cpu_stage1.vhd
