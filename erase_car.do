vlib work
vlog erase_car.v
vlog ram19200x9_map_background.v
vlog memory_address_translator_160x120.v
vsim -L altera_mf_ver erase_car_background

log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns
force {COUNTER_X} 00000010;
force {COUNTER_Y} 0000010;
run 8000ns





