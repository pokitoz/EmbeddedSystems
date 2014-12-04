restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force start_single    0 0ns,        1 40ns,        0 60ns
force data_cmd_n      0 0ns,        0 40ns,        0 60ns
force data_in         16#0 0ns,     16#ABCD 40ns,  16#0 60ns
force running 		  0 0ns,        0 40ns,        1 180ns,      0 220ns
force fifo_empty	  1 0ns,        1 40ns,        1 180ns,      0 220ns, 1 340ns
force read_data       16#FFFF 0ns

run 600ns
