restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force address           "00" 0ns,        "11" 20ns,        "00" 40ns,        "00" 60ns,        "10" 120ns
force chip_select       1 0ns,           1 20ns,           1 40ns,           0 60ns,           1 120ns
force read              0 0ns,                                                                 1 120ns
force write             0 0ns,           1 20ns,           1 40ns,           0 60ns
force write_data        16#0 0ns,        16#1 20ns,        16#ABCD 40ns,     16#0 60ns

run 250ns