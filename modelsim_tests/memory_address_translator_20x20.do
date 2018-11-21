vlib work
vlog memory_address_translator_20x20.v
vsim memory_address_translator_20x20

log {/*}
add wave {/*}


force {x} 0
force {y} 0
run 10ns
#Expected Output
#0

force {x} 0
force {y} 1
run 10ns
#Expected Output
#20


force {x} 0
force {y} 00010
run 10ns
#Expected Output
#40

force {x} 00011
force {y} 00001
run 10ns
#Expected Output
#23


force {x} 00001
force {y} 10011
run 10ns
#Expected Output
#381

force {x} 10011
force {y} 10011
run 10ns
#Expected Output
#399