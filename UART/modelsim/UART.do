restart -f
force clk 0 0ns, 1 10ns -repeat 20ns
force UART_clk 0 0us, 1 104us -repeat 208us
force reset_n 0 0ns, 1 5ns
force Address "000" 0ns, "001" 25ns, "000" 45ns
force ChipSelect 0 0ns, 1 25ns, 0 45ns
force Read 0 0ns
force Write 0 0ns, 1 25ns, 0 45ns
force WriteData "00000000" 0ns, "01010101" 25ns, "00000000" 45ns
run 4000ms