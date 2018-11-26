vlib work

vlog data_laser.v
vsim CheckCar

log {/*}

add wave {/*}


force {resetn} 0
force {car_x} 8'b00000000
force {car_y} 7'b0000000
force {tower_x} 8'b00000000
force {tower_y} 7'b0000000
run 10ns

force {resetn} 1
force {car_x} 8'b00010100
force {car_y} 7'b0101000
force {tower_x} 8'b00010100
force {tower_y} 7'b0010100
run 10ns

force {resetn} 1
force {car_x} 8'b00000000
force {car_y} 7'b0101000
force {tower_x} 8'b00010100
force {tower_y} 7'b0010100
run 10ns