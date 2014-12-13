restart -f

force CPUCLKxCI 0, 1 10 ns -repeat 20 ns
force RSTxRBI 0, 1 25 ns
force ASlaveChipSelectxSI 1

force ASlaveWriteDataxDI 16#0#, 16#7d# 25 ns, 16#0# 45 ns, 16#ff# 805 ns, 10#20# 825 ns, 16#0# 845 ns
force ASlaveWritexSI 0, 1 25 ns, 0 45 ns, 1 805 ns, 0 845 ns
force ASlaveAddressxDI 16#0#, 16#5# 25 ns, 16#0# 45 ns, 16#0# 805 ns, 16#1# 825 ns, 16#0# 845 ns

run 1500 ns