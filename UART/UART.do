restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns
force Address "10" 0ns
force ChipSelect 1 0ns
force Read 0 0ns, 1 900000ns, 0 900020ns -repeat 1800000ns
force Write 0 0ns
force Rx 0 0ns, 1 104000ns -repeat 208000ns
run 20ms