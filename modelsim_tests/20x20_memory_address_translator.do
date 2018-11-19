vlib work
vlog 20x20_memory_address_translator.v
vsim 20x20_memory_address_translator

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
force {y} 2
run 10ns
#Expected Output
#40

force {x} 3
force {y} 1
run 10ns
#Expected Output
#63


force {x} 1
force {y} 19
run 10ns
#Expected Output
#381

force {x} 19
force {y} 19
run 10ns
#Expected Output
#399