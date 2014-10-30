restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns
force Address "00" 0ns, "01" 50ns, "00" 70ns, "01" 1200000ns, "00" 1200020ns
force ChipSelect 0 0ns, 1 50ns, 0 70ns, 1 1200000ns, 0 1200020ns
force Read 0 0ns
force Write 0 0ns, 1 50ns, 0 70ns, 1 1200000ns, 0 1200020
force WriteData "00000000" 0ns, "10101010" 50ns, "00000000" 70ns, "10101010" 1200000ns, "00000000" 1200020ns
run 20ms