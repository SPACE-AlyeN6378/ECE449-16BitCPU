@echo off
call .\0_fetch\cpu1_analyze.bat
ghdl -a ./1_decode/decoder.vhd
ghdl -a ./1_decode/decoder_ii.vhd
ghdl -a ./1_decode/register.vhd
ghdl -a ./1_decode/IDEX_PIPE.vhd
ghdl -a ./1_decode/delta_comp.vhd
