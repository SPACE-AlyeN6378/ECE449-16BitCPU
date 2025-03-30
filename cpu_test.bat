@echo off
@REM ANALYZE
call 1_decode\decode_analyze.bat
call 2_execute\execute_analyze.bat
ghdl -a CPU.vhd

@REM TESTBENCH
ghdl -a cpu_tb.vhd
ghdl -e CPU_tb
ghdl -r CPU_tb --wave=output.ghw

gtkwave output.ghw
rm *.cf
rm *.ghw

