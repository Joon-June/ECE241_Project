vlib work

vlog ECE241Project.v

vsim FrameCounter_30


log {/*}

add wave {/*}

force {resetn} 0
force {Clock} 1
run 10ns
force {resetn} 1
force {Clock} 0
run 10ns
force {Clock} 0 0ns, 1 {2ns} -r 4ns
run 7000000ns
