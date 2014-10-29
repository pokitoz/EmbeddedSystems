restart -f
force clk_50MHz 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns
run 400us