restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force start    0 0ns,        1 40ns,        0 60ns,        1 180ns,        0 200ns
force cmd      0 0ns,        1 40ns,        0 60ns,        0 180ns,        0 200ns
force data_in  16#0 0ns,     16#ABCD 40ns,  16#0 60ns,     16#FFFF 180ns,  16#0 200ns

run 400ns