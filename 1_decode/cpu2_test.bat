@echo off
@REM ANALYZE
call cpu2_analyze.bat

@REM TESTBENCH
ghdl -a cpu_stage2_tb.vhd
ghdl -e stage2_tb
ghdl -r stage2_tb --wave=stage2_output.ghw

gtkwave stage2_output.ghw
rm *.cf
rm *.ghw

