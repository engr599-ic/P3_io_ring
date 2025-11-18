module top(
    inout           CLK_PAD,
    inout           RSTN_PAD,
    inout [15:0]    IRQ_PAD,
    inout [15:0]    EOI_PAD
     
);

logic clk;
logic rstn;

logic [15:0] irq;
logic [15:0] eoi;

// Power/Ground nets treated as signal lines
// some of these are fixed in Physical Design
//logic vcchib;  // hibernate vcc (?)
////vccd
logic vddio; // digital io supply
logic vssio;  // digital io ground

SOC soc0 (
   .clk,
   .rstn,

    .irq(irq),
    .eoi(eoi)
);

gpio_input gpio_clk0 (
    .PAD(CLK_PAD),
    .FROM_PAD(clk),
    .vddio,
    .vssio
  );

gpio_input gpio_rstn0 (
    .PAD(RSTN_PAD),
    .FROM_PAD(rstn),
    .vddio,
    .vssio
    );
  
genvar i;
generate
    for (i = 0; i < 16; i++) begin
        gpio_input gpio_irq0 (
            .PAD(IRQ_PAD[i]),
            .FROM_PAD(irq[i]),
            .vddio,
            .vssio
        );

        gpio_output gpio_eoi0 (
            .PAD(EOI_PAD[i]),
            .TO_PAD(eoi[i]),
            .vddio,
            .vssio
        );
    end

gpio_power gpio_pwr0(
    vddio,
    vssio
    );


endgenerate

endmodule


module gpio_input (
    inout PAD,
    output FROM_PAD,
    inout vddio,
    inout vssio
);


    //per this figure: 
    //https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_io__top_gpiov2.png
    sky130_ef_io__gpiov2_pad_wrapped input_pad0(

        .PAD(PAD),

        .ENABLE_H(vddio),      // Enable input
        .HLD_H_N(vddio), // hold not
        
        .SLOW(1'h0), // =1 for slow output slew
        .VTRIP_SEL(1'b0), //=0 for CMOS logic trip-point
        .INP_DIS(1'b0),       // input buffer disable 
        .DM({3'b001}),        // Input-only mode
        .HLD_OVR(1'b0), //hold override

        .OE_N(1'b1),          // Disable output
        .OUT(1'h0), // no output
        .IN(FROM_PAD), // input 

        .IN_H(), // dont care
        .ENABLE_INP_H(vddio),
        
        .IB_MODE_SEL(1'b0),
        .ENABLE_VDDIO(1'b1),

        .ENABLE_VDDA_H(1'h0), // enable vdd hold 

        .ANALOG_EN(1'b0),
        .ANALOG_SEL(1'b0),
        .ANALOG_POL(1'b0),

        .ENABLE_VSWITCH_H(1'h0), //???
        
        .AMUXBUS_A(),
        .AMUXBUS_B(),

        .TIE_HI_ESD(vddio),
        .TIE_LO_ESD(vssio),
        
        .PAD_A_NOESD_H(),
        .PAD_A_ESD_0_H(),
        .PAD_A_ESD_1_H()
        
        );

endmodule

module gpio_output (
    inout PAD,
    input TO_PAD,
    inout vddio,
    inout vssio
);

    //per this figure: 
    //https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_io__top_gpiov2.png
    sky130_ef_io__gpiov2_pad_wrapped input_pad0(
        .PAD(PAD),

        .ENABLE_H(vddio),      // Enable input
        .HLD_H_N(vddio), // hold not
        
        .SLOW(1'h0), // =1 for slow output slew
        .VTRIP_SEL(1'b0), //=0 for CMOS logic trip-point
        .INP_DIS(1'b1),       // input buffer disable 
        .DM({3'b011}),        // Input-only mode
        .HLD_OVR(1'b0), //hold override

        .OE_N(1'b0),          // enable output
        .OUT(TO_PAD), // no output
        .IN(), // input 

        .IN_H(), // dont care
        .ENABLE_INP_H(vddio),
        
        .IB_MODE_SEL(1'b0),
        .ENABLE_VDDIO(1'b1),

        .ENABLE_VDDA_H(1'h0), // enable vdd hold 

        .ANALOG_EN(1'b0),
        .ANALOG_SEL(1'b0),
        .ANALOG_POL(1'b0),

        .ENABLE_VSWITCH_H(1'h0), //???
        
        .AMUXBUS_A(),
        .AMUXBUS_B(),

        .TIE_HI_ESD(vddio),
        .TIE_LO_ESD(vssio),
        
        .PAD_A_NOESD_H(),
        .PAD_A_ESD_0_H(),
        .PAD_A_ESD_1_H()
        
        );

endmodule

module gpio_power (
    inout vddio,
    inout vssio
);

//VDDIO
genvar i;
generate
    for (i = 0; i < 4; i++) begin : vddio_pad
        sky130_ef_io__vddio_hvc_pad vddio_pad(
                .VSSIO(vssio),
                .VDDIO(vddio)
            );
    end
endgenerate

generate
    for (i = 0; i < 4; i++) begin : vssio_pad 
        sky130_ef_io__vssio_hvc_pad vssio_pad(
                .VSSIO(vssio),
                .VDDIO(vddio)
        );
    end
endgenerate

generate
    for (i = 0; i < 4; i++) begin : vccd_pad 
        sky130_ef_io__vccd_hvc_pad vccd_pad(
            );
    end
endgenerate

generate
    for (i = 0; i < 4; i++) begin : vssd_pad 
        sky130_ef_io__vssd_hvc_pad vssd_pad(
            );
    end
endgenerate

sky130_ef_io__corner_pad tl();
sky130_ef_io__corner_pad tr();
sky130_ef_io__corner_pad bl();
sky130_ef_io__corner_pad br();

endmodule

