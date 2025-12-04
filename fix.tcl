set IO_INSTS [get_db insts -if { .base_cell.name == sky130_ef_io* }]
foreach INST $IO_INSTS {
    puts $INST
    if { [get_db $INST .base_cell.name]  !=  "sky130_ef_io__corner_pad" } {
        if { [get_db $INST .base_cell.name]  !=  "sky130_ef_io__vccd_hvc_pad" } {
            connect_pin -inst [get_db $INST .name] -pin AMUXBUS_B -net AMUXBUS_B
        } else {
            puts "also skipping $INST"
        }
    } else {
        puts "skipping $INST"
    }
}
