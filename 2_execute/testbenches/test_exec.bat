@echo off
@REM ANALYZE
call execute_analyze.bat

@REM TESTBENCH
ghdl -a execute_tb.vhd
ghdl -e ExecutionStage_tb
ghdl -r ExecutionStage_tb --wave=execstage_output.ghw

gtkwave execstage_output.ghw
rm *.cf
rm *.ghw

