set_multi_cpu_usage -remote_host 4 -local_cpu 4
read_db dbs/syn_opt.db/

#set_design_mode -process 130

create_net -physical -name VPWR -power
create_net -physical -name VGND -ground
create_net -physical -name VDDIO -power
create_net -physical -name VSSIO -ground

# secondary IO ring pins
create_net -physical -name VCCHIB
#VCCD is VPWR
create_net -physical -name VDDA
#VDDIO
#VSSIO
create_net -physical -name VSWITCH
create_net -physical -name VSSA
#VSSD is VGND
create_net -physical -name AMUXBUS_B
create_net -physical -name AMUXBUS_A
create_net -physical -name VSSIO_Q
create_net -physical -name VDDIO_Q

# Enable OCV (On Chip Variation)
# This takes into account process variation
set_db timing_analysis_type ocv
set_db timing_analysis_cppr both

# Don't allow the tool to route on the two topmost metal layers
set_db design_top_routing_layer met4
set_db design_bottom_routing_layer met1

# shoot for 50% utilization
#create_floorplan -stdcell_density_size {1.0 0.5 2 2 2 2}
read_floorplan thurber.fp


# Ensure power pins are connected to power nets
connect_global_net VPWR -type pg_pin -pin_base_name VPWR -all
connect_global_net VPWR -type net -net_base_name VPWR -all

connect_global_net VPWR -type pg_pin -pin_base_name VPB -all
connect_global_net VPWR -type pg_pin -pin_base_name VCCD -all

connect_global_net VGND -type pg_pin -pin_base_name VGND -all
connect_global_net VGND -type net -net_base_name VGND -all

connect_global_net VGND -type pg_pin -pin_base_name VNB -all
connect_global_net VGND -type pg_pin -pin_base_name VSSD -all


# secondary IO ring pins
connect_global_net VCCHIB -pin_base_name VCCHIB -all
connect_global_net VDDA -pin_base_name VDDA -all
connect_global_net VSWITCH -pin_base_name VSWITCH -all
connect_global_net VSSA -pin_base_name VSSA -all
connect_global_net AMUXBUS_B -pin_base_name AMUXBUS_B -all
connect_global_net AMUXBUS_A -pin_base_name AMUXBUS_A -all
connect_global_net VSSIO_Q -pin_base_name VSSIO_Q -all
connect_global_net VDDIO_Q -pin_base_name VDDIO_Q -all

# better LEFs
update_lef_macro ./lef/sky130_ef_io__vddio_hvc_pad.lef
update_lef_macro ./lef/sky130_ef_io__vssio_hvc_pad.lef
update_lef_macro ./lef/sky130_ef_io__vccd_hvc_pad.lef
update_lef_macro ./lef/sky130_ef_io__vssd_hvc_pad.lef

## Add vertical and horizontal power straps
add_stripes -nets {VPWR VGND} -layer met5 -direction horizontal -width 12 -spacing 12 -number_of_sets 3 -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none
#
add_stripes -nets {VPWR VGND} -layer met4 -direction vertical -width 12 -spacing 12 -number_of_sets 3  -create_pins 1 -start_from left -start_offset 12 -stop_offset 12 -switch_layer_over_obs false -max_same_layer_jog_length 2 -pad_core_ring_top_layer_limit rdl -pad_core_ring_bottom_layer_limit li1 -block_ring_top_layer_limit rdl -block_ring_bottom_layer_limit li1 -use_wire_group 0 -snap_wire_center_to_grid none

add_rings -nets {vddio vssio} -type core_rings -follow core -layer {top met1 bottom met1 left met1 right met1} -width {top 1 bottom 1 left 1 right 1} -spacing {top 0.14 bottom 0.14 left 0.14 right 0.14} -offset {top 10 bottom 10 left 10 right 10} -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid none

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

# redo IO filler
delete_io_fillers -prefix FILLER
add_io_fillers -cells sky130_ef_io__com_bus_slice_20um sky130_ef_io__com_bus_slice_10um sky130_ef_io__com_bus_slice_5um sky130_ef_io__com_bus_slice_1um
add_io_fillers -cells sky130_ef_io__com_bus_slice_1um -fill_any_gap

set_db place_global_place_io_pins true

#write_floorplan floorplan.fp

# Save a database
write_db -common dbs/floorplan.db


