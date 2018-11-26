vlib work
vlog counter_test.v
vsim test

log {/*}
add wave {/*}

force {CLOCK_50} 0 0ns, 1 {5ns} -r 10ns
run 1000ns