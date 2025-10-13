module SOC (
   input clk,
   input rstn,
  
   input [15:0] irq,
   output [15:0] eoi 

   );

   logic rst;
   assign rst = ~rstn;

   logic mem_valid;
   logic mem_instr;
   logic mem_ready;
   logic [31:0] mem_addr;
   logic [31:0] mem_wdata;
   logic [3:0] mem_wstrb;
   logic [31:0] mem_rdata;

   logic [31:0] eoi32;
   // this is made up to get connectivity
   assign eoi = irq[15:0] & {16{mem_valid}} ;

   picorv32 #(
	.ENABLE_IRQ (1),
	.MASKED_IRQ (32'hffff0000)
   ) CORE (
   	.clk(clk), 
   	.resetn(rstn),
   	.trap(),
   
   	.mem_valid(mem_valid),
   	.mem_instr(mem_instr),
   	.mem_ready(mem_ready),
   
   	.mem_addr(mem_addr),
   	.mem_wdata(mem_wdata),
   	.mem_wstrb(mem_wstrb),
   	.mem_rdata(mem_rdata),
   
   	// Look-Ahead Interface
   	.mem_la_read(),
   	.mem_la_write(),
   	.mem_la_addr(),
   	.mem_la_wdata(),
   	.mem_la_wstrb(),
   
   	// Pico Co-Processor Interface (PCPI)
   	.pcpi_valid(),
   	.pcpi_insn(),
   	.pcpi_rs1(),
   	.pcpi_rs2(),
   	.pcpi_wr('h0),
   	.pcpi_rd(32'h0),
   	.pcpi_wait('h1),
   	.pcpi_ready('h0),

   
   	// IRQ Interface
   	.irq( {16'h0, irq} ),
   	.eoi( eoi32),
   
   	.trace_valid(),
   	.trace_data()
   );
    

   sram_simple SRAM_TOP(
      .clk(clk),
      .rstn(rstn),
      .mem_valid(mem_valid),
      .mem_instr(mem_instr),
      .mem_addr(mem_addr),
      .mem_wstrb(mem_wstrb),
      .mem_wdata(mem_wdata),
      .mem_rdata(mem_rdata),
      .mem_ready(mem_ready)
   );

endmodule
