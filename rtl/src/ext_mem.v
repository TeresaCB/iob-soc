
`timescale 1 ns / 1 ps

`include "system.vh"
`include "interconnect.vh"

module ext_mem
  (
   input                  clk,
   input                  rst,

   // Instruction bus
   input [`REQ_W-1:0]     i_req,
   output [`RESP_W-1:0]   i_resp,

   // Data bus
   input [`REQ_W-1:0]     d_req,
   output [`RESP_W-1:0]   d_resp,

   // AXI interface 
   // Address write
   output [0:0]           axi_awid, 
   output [`ADDR_W-1:0]   axi_awaddr,
   output [7:0]           axi_awlen,
   output [2:0]           axi_awsize,
   output [1:0]           axi_awburst,
   output [0:0]           axi_awlock,
   output [3:0]           axi_awcache,
   output [2:0]           axi_awprot,
   output [3:0]           axi_awqos,
   output                 axi_awvalid,
   input                  axi_awready,
   //Write
   output [`DATA_W-1:0]   axi_wdata,
   output [`DATA_W/8-1:0] axi_wstrb,
   output                 axi_wlast,
   output                 axi_wvalid, 
   input                  axi_wready,
   input [0:0]            axi_bid,
   input [1:0]            axi_bresp,
   input                  axi_bvalid,
   output                 axi_bready,
   //Address Read
   output [0:0]           axi_arid,
   output [`ADDR_W-1:0]   axi_araddr, 
   output [7:0]           axi_arlen,
   output [2:0]           axi_arsize,
   output [1:0]           axi_arburst,
   output [0:0]           axi_arlock,
   output [3:0]           axi_arcache,
   output [2:0]           axi_arprot,
   output [3:0]           axi_arqos,
   output                 axi_arvalid, 
   input                  axi_arready,
   //Read
   input [0:0]            axi_rid,
   input [`DATA_W-1:0]    axi_rdata,
   input [1:0]            axi_rresp,
   input                  axi_rlast, 
   input                  axi_rvalid, 
   output                 axi_rready
   );

   //
   // INSTRUCTION CACHE
   //

   // Front-end bus

   wire [`REQ_W-1:0]      icache_fe_req;
   wire [`RESP_W-1:0]     icache_fe_resp;

   assign icache_fe_req = i_req;
   assign i_resp = icache_fe_resp;

   // Back-end bus
   wire [`REQ_W-1:0]      icache_be_req;
   wire [`RESP_W-1:0]     icache_be_resp;

   // Instruction cache instance
   iob_cache # (
                .ADDR_W(`ADDR_W),
                .N_WAYS(2),        //Number of ways
                .LINE_OFF_W(4),    //Cache Line Offset (number of lines)
                .WORD_OFF_W(4),    //Word Offset (number of words per line)
                .WTBUF_DEPTH_W(4), //FIFO's depth
                .MEM_NATIVE(1),    //Back-end uses Native Interface
                //Ctrls parameters
                .CTRL_CNT_ID(0),   //Remove counters with distinct data-instr accesses
                .CTRL_CNT(1)       //Counters for hits and misses (since previous parameter is 0)
                )
   icache (
           .clk   (clk),
           .reset (rst),

           // Front-end interface
           .valid (icache_fe_req[`valid(0)]),
           .addr  (icache_fe_req[`address(0)]),
           .wdata (icache_fe_req[`wdata(0)]),
           .wstrb (icache_fe_req[`wstrb(0)]),
           .rdata (icache_fe_resp[`rdata(0)]),
           .ready (icache_fe_resp[`ready(0)]),
           //Currently unused ports
           .instr(1'b0),
           .select(1'b0), // currently I-cache controllers is unselectable
           // Back-end interface
           .mem_valid (icache_be_req[`valid(0)]),
           .mem_addr  (icache_be_req[`address(0)]),
           .mem_wdata (icache_be_req[`wdata(0)]),
           .mem_wstrb (icache_be_req[`wstrb(0)]),
           .mem_rdata (icache_be_resp[`rdata(0)]),
           .mem_ready (icache_be_resp[`ready(0)])
           );

   //
   // DATA CACHE
   //

   // Front-end bus
   wire [`REQ_W-1:0]      dcache_fe_req;
   wire [`RESP_W-1:0]     dcache_fe_resp;

   assign dcache_fe_req = d_req;
   assign d_resp = dcache_fe_resp;

   // Back-end bus
   wire [`REQ_W-1:0]      dcache_be_req;
   wire [`RESP_W-1:0]     dcache_be_resp;

   // Data cache instance
   iob_cache # (
                .ADDR_W(`ADDR_W),
                .N_WAYS(2),        //Number of ways
                .LINE_OFF_W(4),    //Cache Line Offset (number of lines)
                .WORD_OFF_W(4),    //Word Offset (number of words per line)
                .WTBUF_DEPTH_W(4), //FIFO's depth
                .MEM_NATIVE(1),    //Back-end uses Native Interface
                //Ctrls parameters
                .CTRL_CNT_ID(0),   //Remove counters with distinct data-instr accesses
                .CTRL_CNT(1)       //Counters for hits and misses (since previous parameter is 0)
                )
   dcache (
           .clk   (clk),
           .reset (rst),

           // Front-end interface
           .valid (dcache_fe_req[`valid(0)]),
           .addr  (dcache_fe_req[`address(0)]),
           .wdata (dcache_fe_req[`wdata(0)]),
           .wstrb (dcache_fe_req[`wstrb(0)]),
           .rdata (dcache_fe_resp[`rdata(0)]),
           .ready (dcache_fe_resp[`ready(0)]),
           .instr (1'b0),
           .select(dcache_fe_req[`REQ_W+`ADDR_P+`ADDR_W-1]), //so during boot.c the buffer can be checked to see if it's empty, using the MSB of address
           // Back-end interface
           .mem_valid (dcache_be_req[`valid(0)]),
           .mem_addr  (dcache_be_req[`address(0)]),
           .mem_wdata (dcache_be_req[`wdata(0)]),
           .mem_wstrb (dcache_be_req[`wstrb(0)]),
           .mem_rdata (dcache_be_resp[`rdata(0)]),
           .mem_ready (dcache_be_resp[`ready(0)])
           );

   // Merge caches back-ends
   wire [`REQ_W-1:0]      l2cache_req;
   wire [`RESP_W-1:0]     l2cache_resp;

   merge
     ibus_merge (
                 // masters
                 .m_req  ({icache_be_req, dcache_be_req}),
                 .m_resp ({icache_be_resp, dcache_be_resp}),

                 // slave
                 .s_req  (l2cache_req),
                 .s_resp (l2cache_resp)
                 );

   // L2 cache instance
   iob_cache # (
                .ADDR_W(`ADDR_W),
                .N_WAYS(4),        //Number of Ways
                .LINE_OFF_W(4),    //Cache Line Offset (number of lines)
                .WORD_OFF_W(4),    //Word Offset (number of words per line)
                .WTBUF_DEPTH_W(4), //FIFO's depth
                .MEM_NATIVE(0),    //Back-end uses AXI Interface
                //Ctrls parameters
                .CTRL_CNT_ID(0),   //Remove counters with distinct data-instr accesses
                .CTRL_CNT(1)       //Counters for hits and misses (since previous parameter is 0)
                )
   l2cache (
            // Native interface
            .valid    (l2cache_req[`valid(0)]),
            .addr     (l2cache_req[`address(0)]),
            .wdata    (l2cache_req[`wdata(0)]),
            .wstrb    (l2cache_req[`wstrb(0)]),
            .rdata    (l2cache_resp[`rdata(0)]),
            .ready    (l2cache_resp[`ready(0)]),
            .instr    (1'b0),
            .select   (1'b0),
            // AXI interface
            // Address write
            .axi_awid(axi_awid), 
            .axi_awaddr(axi_awaddr), 
            .axi_awlen(axi_awlen), 
            .axi_awsize(axi_awsize), 
            .axi_awburst(axi_awburst), 
            .axi_awlock(axi_awlock), 
            .axi_awcache(axi_awcache), 
            .axi_awprot(axi_awprot),
            .axi_awqos(axi_awqos), 
            .axi_awvalid(axi_awvalid), 
            .axi_awready(axi_awready), 
            //write
            .axi_wdata(axi_wdata), 
            .axi_wstrb(axi_wstrb), 
            .axi_wlast(axi_wlast), 
            .axi_wvalid(axi_wvalid), 
            .axi_wready(axi_wready), 
            //write response
            .axi_bid(axi_bid), 
            .axi_bresp(axi_bresp), 
            .axi_bvalid(axi_bvalid), 
            .axi_bready(axi_bready), 
            //address read
            .axi_arid(axi_arid), 
            .axi_araddr(axi_araddr), 
            .axi_arlen(axi_arlen), 
            .axi_arsize(axi_arsize), 
            .axi_arburst(axi_arburst), 
            .axi_arlock(axi_arlock), 
            .axi_arcache(axi_arcache), 
            .axi_arprot(axi_arprot), 
            .axi_arqos(axi_arqos), 
            .axi_arvalid(axi_arvalid), 
            .axi_arready(axi_arready), 
            //read 
            .axi_rid(axi_rid), 
            .axi_rdata(axi_rdata), 
            .axi_rresp(axi_rresp), 
            .axi_rlast(axi_rlast), 
            .axi_rvalid(axi_rvalid),  
            .axi_rready(axi_rready)
            );

endmodule
