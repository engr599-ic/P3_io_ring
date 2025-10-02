
set_units -time ns
#create_clock -name clk -period 30 -waveform {0 15} [get_ports {hport:top/gpio_clk0/FROM_PAD}]
create_clock -name clk -period 30 -waveform {0 15} {top/gpio_clk0/FROM_PAD}
