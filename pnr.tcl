
set PDK_DIR /l/sky130_release_0.0.1
set STDCELL_DIR /l/skywater-pdk/libraries/sky130_fd_sc_ms/latest/cells/
set IO_DIR /l/open_pdks/sky130/custom/sky130_fd_io/
set OTHER_IO_DIR /l/skywater-pdk/libraries/sky130_fd_io/latest/cells/

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


set STDCELL_GDS [glob -nocomplain -type f $STDCELL_DIR/**/*.gds]
set IO_GDS [glob -nocomplain -type f $IO_DIR/gds/*.gds]
set OTHER_IO_GDS [glob -nocomplain -type f $OTHER_IO_DIR/**/*.gds]

set ALL_GDS [list {*}$STDCELL_GDS {*}$IO_GDS {*}$OTHER_IO_GDS]

# Remove any .magic.lef files and the diode lefs.
# .magic.lefs aren't supported by Cadence and the diode lefs are incorrect.
set FILTERED_GDS {} 
foreach file $ALL_GDS {
	if {![string match "*.magic.*" $file] && \
        ![string match "*diode*" $file] && \
        ![string match "*tapmet1*" $file] && \
        ![string match "*sky130_fd_io__signal_5_sym_hv_local_5term*" $file] && \
        ![string match "*tapvgnd*" $file] \
        } {
		lappend FILTERED_GDS $file
	}
}
set FILTERED_GDS [split $FILTERED_GDS]
lappend FILTERED_GDS ./sram-pnr/sram.gds


write_stream out.gds \
    -map_file $PDK_DIR/libs/sky130_fd_pr_main/sky130_fd_pr_main.layermap \
    -lib_name DesignLib \
    -merge $FILTERED_GDS \
    -unit 1000 -mode all
