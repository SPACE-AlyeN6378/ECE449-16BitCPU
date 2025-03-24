@echo off
@REM ANALYZE
call cpu3_analyze.bat

@REM TESTBENCH
ghdl -a cpu_stage3_tb.vhd
ghdl -e stage3_tb
ghdl -r stage3_tb --wave=stage3_output.ghw

gtkwave stage3_output.ghw
rm *.cf
rm *.ghw

