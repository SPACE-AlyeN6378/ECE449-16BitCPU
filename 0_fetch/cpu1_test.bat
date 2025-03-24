@echo off
@REM ANALYZE
call cpu1_analyze.bat

@REM TESTBENCH
:: Stage 1 - Fetch
ghdl -a cpu_stage1_tb.vhd
ghdl -e stage1_tb
ghdl -r stage1_tb --wave=stage1_output.ghw

gtkwave stage1_output.ghw
rm *.cf
rm *.ghw

