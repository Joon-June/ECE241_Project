vlib work

vlog data_car.v
vsim DelayCounter

log {/*}

add wave {/*}

force {resetn} 0
force {Clock} 1
force {delay_length} 8'b00000010
force {Enable} 1
run 10ns
force {resetn} 1
force {Clock} 0
run 10ns
force {Clock} 0 0ns, 1 {2ns} -r 4ns
run 21000000ns
