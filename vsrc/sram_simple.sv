// Module to interface OpenRAM Sram with picorv32

module sram_simple(
   input clk,
   input rstn,
   input mem_valid,
   input mem_instr,
   input [31:0] mem_addr,
   input [31:0] mem_wdata,
   input [3:0] mem_wstrb,
   
   output [31:0] mem_rdata,
   output mem_ready
);

assign mem_ready = mem_valid;

sram_8_1024_sky130A SRAM_0 (
   .clk(clk),
   .csb0(rstn),
   .web0(mem_valid && mem_wstrb[0]),
   .addr0(mem_addr[9:0]),
   .din0(mem_wdata[7:0]),
   .dout0(mem_rdata[7:0])
); 

sram_8_1024_sky130A SRAM_1 (
   .clk(clk),
   .csb0(rstn),
   .web0(mem_valid && mem_wstrb[1]),
   .addr0(mem_addr[9:0]),
   .din0(mem_wdata[15:8]),
   .dout0(mem_rdata[15:8])
); 

sram_8_1024_sky130A SRAM_2 (
   .clk(clk),
   .csb0(rstn),
   .web0(mem_valid && mem_wstrb[2]),
   .addr0(mem_addr[9:0]),
   .din0(mem_wdata[23:16]),
   .dout0(mem_rdata[23:16])
); 


sram_8_1024_sky130A SRAM_3 (
   .clk(clk),
   .csb0(rstn),
   .web0(mem_valid && mem_wstrb[3]),
   .addr0(mem_addr[9:0]),
   .din0(mem_wdata[31:24]),
   .dout0(mem_rdata[31:24])
); 


endmodule
