restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force address_slave     16#0 0ns,   16#3 20ns,  16#0 40ns,  16#0 60ns,      16#0 60ns,  16#5 220ns, 16#0 240ns
force chip_select       1 0ns
force read_slave        0 0ns
force write             0 0ns,      1 20ns,     0 40ns,     1 60ns,         0 80ns,     1 220ns,    0 240ns
force write_data_slave  16#0 0ns,   16#1 20ns,  16#0 40ns,  16#2C 60ns,     16#0 80ns,  16#3 220ns, 16#0 240ns

force read_data_master  16#FFFF 0ns
force wait_request      0 0ns
force read_data_valid   0 0ns

run 2us