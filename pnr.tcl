set_multi_cpu_usage -remote_host 4 -local_cpu 4
read_db dbs/floorplan.db/

# Place the standard cells
place_opt_design
add_tieoffs
write_db -common dbs/place.db

# Run Clock Tree Synthesis (CTS)
clock_opt_design
add_fillers -base_cells {sky130_fd_sc_ms__fill_8 sky130_fd_sc_ms__fill_4 sky130_fd_sc_ms__fill_2 sky130_fd_sc_ms__fill_1}
write_db -common dbs/ccopt.db

# Route the signal nets
route_opt_design
time_design -post_route
time_design -post_route -hold
opt_design -post_route
write_db -common dbs/route.db

# Extract a resistor capacitor model of the chip
extract_rc
opt_signoff -all -report_dir timing_report
write_db -common dbs/signoff.db

# Write out a post PnR netlist for simulation and LVS
write_netlist -include_pg -omit_floating_ports -update_tie_connections post_pnr_lvs.vg
write_netlist -remove_power_ground post_pnr_sim.vg

# Write a DRC report
check_drc -out_file drc.rpt
check_connectivity -out_file connect.rpt -ignore_dangling_wires

get_db current_design .bbox.area > area.rpt

