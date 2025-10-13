set_multi_cpu_usage -remote_host 4 -local_cpu 4
read_db dbs/syn_opt.db/

#set_design_mode -process 130

create_net -physical -name VPWR -power
create_net -physical -name VGND -ground
create_net -physical -name vddio -power
create_net -physical -name vssio -ground
create_net -physical -name vccd -power
create_net -physical -name vssd -ground
create_net -physical -name vdda -power
create_net -physical -name vddswitch -power

# Enable OCV (On Chip Variation)
# This takes into account process variation
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both

# Don't allow the tool to route on the two topmost metal layers
set_db design_top_routing_layer met4
set_db design_bottom_routing_layer met1

# shoot for 50% utilization
#create_floorplan -stdcell_density_size {1.0 0.5 2 2 2 2}
#read_floorplan top_with_power.fp

# Ensure power pins are connected to power nets
connect_global_net VPWR -type pg_pin -pin_base_name VPWR -all
connect_global_net VPWR -type net -net_base_name VPWR -all

#connect_global_net vccd -type pg_pin -pin_base_name VPWR -all
#connect_global_net vccd -type net -net_base_name VPWR -all

#connect_global_net vssd -type pg_pin -pin_base_name VGND -all
#connect_global_net vssd -type net -net_base_name VGND -all

connect_global_net vddio -type pg_pin -pin_base_name vddio -all
connect_global_net vddio -type net -net_base_name vddio -all
connect_global_net vddio -type pg_pin -pin_base_name VDDIO -all
connect_global_net vddio -type net -net_base_name VDDIO -all

connect_global_net vssio -type pg_pin -pin_base_name vssio -all
connect_global_net vssio -type net -net_base_name vssio -all
connect_global_net vssio -type pg_pin -pin_base_name VSSIO -all
connect_global_net vssio -type net -net_base_name VSSIO -all

connect_global_net VPWR -type pg_pin -pin_base_name VPB -all
#connect_global_net VPWR -type pg_pin -pin_base_name vccd -all

connect_global_net VGND -type pg_pin -pin_base_name VGND -all
connect_global_net VGND -type net -net_base_name VGND -all

connect_global_net VGND -type pg_pin -pin_base_name VNB -all
#connect_global_net VGND -type pg_pin -pin_base_name vssd -all

## Add vertical and horizontal power straps
#add_stripes -nets {VPWR VGND} -layer met5 -direction horizontal -width 12 -spacing 12 -number_of_sets 3 -extend_to design_boundary -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none
#
#add_stripes -nets {VPWR VGND} -layer met4 -direction vertical -width 12 -spacing 12 -number_of_sets 3 -extend_to design_boundary -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none
#
## Route the power and ground nets, the tool treats power and ground routes 
## as special and seperate from signal routes
route_special -connect core_pin \
   -block_pin_target nearest_target \
   -core_pin_target first_after_row_end \
   -allow_jogging 1 \
   -nets {VPWR VGND vddio vssio vccd vssd} \
   -allow_layer_change 1

add_well_taps -cell sky130_fd_sc_ms__tapvpwrvgnd_1 -cell_interval 60 -in_row_offset 30

# Save a database
write_db -common dbs/pnr_init.db

set_db place_global_place_io_pins true

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

