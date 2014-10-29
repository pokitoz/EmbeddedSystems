restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns
force Address "00" 0ns, "00" 50ns, "00" 70ns
force ChipSelect 0 0ns, 1 50ns, 0 70ns
force Read 0 0ns, 1 50ns, 0 70ns
force WriteData "00000000" 0ns, "10101010" 50ns, "00000000" 70ns
run 20ms