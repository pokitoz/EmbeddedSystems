restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force reset_n 0 0ns, 1 5ns

force read_data         16#FFFF 0ns
force wait_request      0 0ns
force start_dma         0 0ns, 1 20ns, 0 40ns
force address_dma       16#1234 0ns
force len_dma           16#3 0ns

force fifo_full         0 0ns
force fifo_free_cnt     16#0 0ns
force read_data_valid   0 0ns

run 250ns
