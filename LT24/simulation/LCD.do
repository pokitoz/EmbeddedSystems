restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns
force Address "00" 0ns
force ChipSelect 1 0ns
force Read 0 0ns
force Write 0 0ns, 1 40ns, 1 60ns, 0 80ns
force WriteData 16#0 0ns, 16#FF 40ns, 16#FF00 60ns
run 100ns