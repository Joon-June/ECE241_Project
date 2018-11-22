vlib work
vlog draw_tower.v
vlog ram400x9_tower.v
vlog memory_address_translator_20x20.v
vsim -L altera_mf_ver draw_tower

log {/*}
add wave {/*}

force {clk} 0 0ns, 1 {5ns} -r 10ns
force {COUNTER_X} 0;
force {COUNTER_Y} 0;
run 8000ns

force {clk} 0
run 100ns

force {clk} 0 0ns, 1 {5ns} -r 10ns
run 1000ns




