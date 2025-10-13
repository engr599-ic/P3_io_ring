set TOP_MODULE top

set HDL_FILES {
   ./vsrc/top.sv
   ./vsrc/soc.sv
   ./vsrc/sram_simple.sv
   ./picorv32/picorv32.v
}
   #./vsrc/sky130_fd_io__top_gpiov2.pp.blackbox.v
   #/pdks/google/open_pdks/sky130/custom/sky130_fd_io/verilog/sky130_ef_io__gpiov2_pad_wrapped.v
   #/pdks/google/open_pdks/sky130/custom/sky130_fd_io/verilog/sky130_ef_io.v

set MMMC_FILE ./mmmc.tcl

set PDK_DIR /l/skywater-pdk/libraries/sky130_fd_pr/latest/
set STDCELL_DIR /l/skywater-pdk/libraries/sky130_fd_sc_ms/latest/cells/
set IO_DIR /l/open_pdks/sky130/custom/sky130_fd_io/
set LIB_DIR /l/skywater-pdk/libraries/sky130_fd_sc_ms/latest/timing/
set TECH_LEF /l/skywater-pdk/libraries/sky130_fd_pr/latest/tech/sky130_fd_pr.tlef

set STDCELL_LEFS [glob -nocomplain -type f $STDCELL_DIR/**/*.lef]
set IO_LEFS [glob -nocomplain -type f $IO_DIR/lef/*.lef]
set OTHER_IO_LEFS [glob -nocomplain -type f /l/skywater-pdk/libraries/sky130_fd_io/latest/cells/**/*.lef]

set ALL_LEFS [list {*}$STDCELL_LEFS {*}$IO_LEFS {*}$OTHER_IO_LEFS]

# Remove any .magic.lef files and the diode lefs.
# .magic.lefs aren't supported by Cadence and the diode lefs are incorrect.
set FILTERED_LEFS {} 
foreach file $ALL_LEFS {
	if {![string match "*.magic.lef" $file] && \
        ![string match "*diode*" $file] && \
        ![string match "*tapmet1*" $file] && \
        ![string match "*sky130_fd_io__signal_5_sym_hv_local_5term*" $file] && \
        ![string match "*tapvgnd*" $file] \
        } {
		lappend FILTERED_LEFS $file
	}
}
set FILTERED_LEFS [split $FILTERED_LEFS]
lappend FILTERED_LEFS ./sram-pnr/sram.lef

set_db lib_search_path $LIB_DIR

# Set synthesis tool effort
set_db syn_generic_effort medium
set_db syn_map_effort medium

set_multi_cpu_usage -local_cpu 4

# Disallow tool from using scan flops for non scan chain uses
set_db use_scan_seqs_for_non_dft false

#set_db optimize_constant_feedback_seqs false
#set_db delete_unloaded_insts false
#set_db optimize_constant_1_flops false
#set_db optimize_constant_0_flops false

read_mmmc $MMMC_FILE
read_hdl -language sv $HDL_FILES
elaborate $TOP_MODULE
read_physical -lef [list $TECH_LEF $FILTERED_LEFS]
init_design -top $TOP_MODULE
set_top_module $TOP_MODULE

write_db dbs/init.db

syn_generic
write_db dbs/syn_generic.db

syn_map
write_db dbs/syn_map.db

syn_opt
write_db -common -all_root_attributes dbs/syn_opt.db

write_hdl > postsynth.vg
