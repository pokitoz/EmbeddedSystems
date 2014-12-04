restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force address           "000" 0ns,       "011" 20ns,       "000" 40ns,       "000" 60ns,           "100" 120ns, "101" 140ns
force chip_select       1 0ns,           1 20ns,           1 40ns,           0 60ns,               1 120ns, 0 160ns
force read              0 0ns,                                                                     0 120ns
force write             0 0ns,           1 20ns,           1 40ns,           0 60ns,               1 120ns
force write_data        16#0 0ns,        16#1 20ns,        16#ABCD 40ns,     16#0 60ns,            16#FFFF 120ns
force busy 				1 0ns

run 250ns