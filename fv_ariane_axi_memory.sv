
`include "config.vh"

import ariane_pkg::*;
import ariane_axi::*;

module fv_ariane_axi_memory #(
    parameter RAM_DATA_WIDTH = 128,
    parameter int unsigned AxiNumWords       = 4, // data width in dwords, this is also the maximum burst length, must be >=2
    parameter int unsigned AxiIdWidth        = 4,  // stick to the spec
    parameter BOOT_ADDR = 'h100,                        // instruction fetch starts here and is constrainted to not go below this leaving the space below for data.
    parameter MEM_SIZE = (16*1024) // 16KB default
    ) 
   (
    input logic  clk_i,
    input logic  rst_ni,
    input ariane_axi::req_t axi_req_in,
    output ariane_axi::resp_t axi_resp_out
    );

   // PARAMETERS for AXI --------------------------------------------
   localparam  AXI_ID_W            = AxiIdWidth;  // width of ID fields
   localparam  AXI_ADDRESS_W       = $size(axi_req_in.ar.addr); // address width
   localparam  AXI_DATA_W          = RAM_DATA_WIDTH; // data symbol width 
   localparam  AXI_NUMBYTES        = (RAM_DATA_WIDTH/8);  // number of bytes per word

   // local variables for conversions

   //AXI write address bus ------------------------------------------
   logic [AXI_ID_W-1:0]      axs_awid;
   logic [AXI_ADDRESS_W-1:0] axs_awaddr;
   logic [ 3:0] 	     axs_awlen;   //burst length is 1 + (0 - 15)
   logic [ 2:0] 	     axs_awsize;  //size of each transfer in burst
   logic [ 1:0] 	     axs_awburst; //for bursts>1, accept only incr burst=01
   logic [ 1:0] 	     axs_awlock;  //only normal access supported axs_awlock=00
   logic [ 3:0] 	     axs_awcache; 
   logic [ 2:0] 	     axs_awprot;
   logic 		     axs_awvalid; //master addr valid
   logic 		     axs_awready; //slave ready to accept

   //AXI write data bus ---------------------------------------------
   logic [AXI_ID_W-1:0]      axs_wid;
   logic [AXI_DATA_W-1:0]    axs_wdata;
   logic [AXI_NUMBYTES-1:0]  axs_wstrb;   //1 strobe per byte
   logic 		     axs_wlast;   //last transfer in burst
   logic 		     axs_wvalid;  //master data valid
   logic 		     axs_wready;  //slave ready to accept

   //AXI write response bus -----------------------------------------
   logic [AXI_ID_W-1:0]      axs_bid;
   logic [ 1:0] 	     axs_bresp;
   logic 		     axs_bvalid;
   logic 		     axs_bready;
   
   //AXI read address bus -------------------------------------------
   logic [AXI_ID_W-1:0]      axs_arid;
   logic [AXI_ADDRESS_W-1:0] axs_araddr;
   logic [ 3:0] 	     axs_arlen;   //burst length - 1 to 16
   logic [ 2:0] 	     axs_arsize;  //size of each transfer in burst
   logic [ 1:0] 	     axs_arburst; //for bursts>1, accept only incr burst=01
   logic [ 1:0] 	     axs_arlock;  //only normal access supported axs_awlock=00
   logic [ 3:0] 	     axs_arcache; 
   logic [ 2:0] 	     axs_arprot;
   logic 		     axs_arvalid; //master addr valid
   logic 		     axs_arready; //slave ready to accept

   //AXI read data bus ----------------------------------------------
   logic [AXI_ID_W-1:0]      axs_rid;
   logic [AXI_DATA_W-1:0]    axs_rdata;
   logic [ 1:0] 	     axs_rresp;
   logic 		     axs_rlast; //last transfer in burst
   logic 		     axs_rvalid;//slave data valid
   logic 		     axs_rready;//master ready to accept

   // use 'wire' for unused signals for and name signal <..>_nc (not connected)

   ///////////////////////////////////////////////////////
   // write channel
   ///////////////////////////////////////////////////////

   // address
   assign axs_awid    = axi_req_in.aw.id;
   assign axs_awaddr  = axi_req_in.aw.addr;
   assign axs_awlen   = axi_req_in.aw.len[3:0]; // Note: len[7:0]
   assign axs_awsize  = axi_req_in.aw.size;
   assign axs_awburst = axi_req_in.aw.burst;
   assign axs_awlock  = {1'b0, axi_req_in.aw.lock}; // lock in AXI4 is only 1 bit
   assign axs_awcache = axi_req_in.aw.cache; // 4'b0
   assign axs_awprot  = axi_req_in.aw.prot;
   assign axs_awvalid = axi_req_in.aw_valid;

   assign axi_resp_out.aw_ready = axs_awready;

   // AXI4
   logic [UserWidth-1:0] wr_user_i, wr_user_o;
   assign wr_user_i        = axi_req_in.aw.user;
   wire [3:0] wr_region_nc = axi_req_in.aw.region; // 4'b0;
   wire [3:0] wr_qos_nc    = axi_req_in.aw.qos; // 4'b0
   // non-AXI?
   wire [5:0] wr_atop_nc   = axi_req_in.aw.atop; // '0 unused

//   logic [AXI_ID_W-1:0] aw_id_i, w_id_i;
   logic [AXI_ID_W-1:0] axs_awid_flopped;
   
   // data
//   assign aw_id_i    = axs_awid;
   assign axs_wid    = (axs_awvalid && axs_awready) ? axs_awid : axs_awid_flopped; // axi_req_in.w.id; // AXI4 does not define a wid, just awid
   assign axs_wdata  = axi_req_in.w.data;
   assign axs_wstrb  = axi_req_in.w.strb;
   assign axs_wlast  = axi_req_in.w.last;
   assign axs_wvalid = axi_req_in.w_valid;

   assign axi_resp_out.w_ready  = axs_wready;

   always @(posedge clk_i) begin
      if (axs_awvalid && axs_awready) begin // Note: what if reqs are buffered?
	 wr_user_o  <= wr_user_i;
	 axs_awid_flopped     <= axs_awid;
      end
   end

   // write response
   assign axi_resp_out.b.id    = axs_bid;
   assign axi_resp_out.b.resp  = axs_bresp;
   assign axi_resp_out.b_valid = axs_bvalid;

   assign axs_bready           = axi_req_in.b_ready;

   // AXI4
   assign axi_resp_out.b.user  = wr_user_o; // AXI4

   ///////////////////////////////////////////////////////
   // read channel
   ///////////////////////////////////////////////////////

   assign axs_arid      = axi_req_in.ar.id;
   assign axs_araddr    = axi_req_in.ar.addr;
   assign axs_arlen     = axi_req_in.ar.len[3:0]; // Note: len[7:0]
   assign axs_arsize    = axi_req_in.ar.size;
   assign axs_arburst   = axi_req_in.ar.burst;
   assign axs_arlock    = {1'b0, axi_req_in.ar.lock}; // lock in AXI4 is only 1 bit
   assign axs_arcache   = axi_req_in.ar.cache; // 4'b0
   assign axs_arprot    = axi_req_in.ar.prot;  // 3'b0

   // AXI4
   logic [UserWidth-1:0] rd_user_i, rd_user_o;

   assign rd_user_i        = axi_req_in.ar.user;
   wire [3:0] rd_region_nc = axi_req_in.ar.region; // 4'b0
   wire [3:0] rd_qos_nc    = axi_req_in.ar.qos;    // 4'b0

`ifdef FV_INCLUDE_IF_STAGE
   logic        instr_req_d, instr_req_i;
   logic        instr_rvalid; // driven by FV module
   logic [63:0] instr_rdata;  // driven by FV module

   logic [AXI_ID_W-1:0] instr_rid;

   logic        instr_gnt; // unused for now

   assign instr_req_i = axi_req_in.ar_valid && (axs_araddr >= BOOT_ADDR);

   assign axs_arvalid           = instr_req_i ? 1'b0 : axi_req_in.ar_valid; // block if instr request
   assign axi_resp_out.ar_ready = instr_req_i ? 1'b1 : axs_arready;

   always @(posedge clk_i) begin
      if (!rst_ni) begin
	instr_req_d  <= 0;
      end else begin
//	 if (axs_arvalid && axs_arready) // Note: what if reqs are buffered?
//	 if (axi_req_in.ar_valid && axs_arready) // Note: what if reqs are buffered?
	 instr_req_d  <= instr_req_i;
      end
      instr_rid <= axs_arid;
   end

   assign axi_resp_out.r_valid = instr_req_d ? instr_rvalid : axs_rvalid;
   assign axi_resp_out.r.data  = instr_req_d ? instr_rdata  : axs_rdata;
   assign axi_resp_out.r.id    = instr_req_d ? instr_rid    : axs_rid;
   assign axi_resp_out.r.resp  = instr_req_d ? 2'b00        : axs_rresp;
   assign axi_resp_out.r.last  = instr_req_d ? 1'b1         : axs_rlast;
   assign axs_rready           = instr_req_d ? 1'b1         : axi_req_in.r_ready;
`else
   assign axs_arvalid           = axi_req_in.ar_valid;
   assign axi_resp_out.ar_ready = axs_arready;

   assign axi_resp_out.r_valid = axs_rvalid;
   assign axi_resp_out.r.data  = axs_rdata;
   assign axi_resp_out.r.id    = axs_rid;
   assign axi_resp_out.r.resp  = axs_rresp;
   assign axi_resp_out.r.last  = axs_rlast;
   assign axs_rready           = axi_req_in.r_ready;
`endif

   always @(posedge clk_i) begin
      if (axi_req_in.ar_valid && axs_arready) // Note: what if reqs are buffered?
	rd_user_o    <= rd_user_i;
   end

   // AXI4
   assign axi_resp_out.r.user  = rd_user_o;
    

   fv_axi3_memory 
     #(.AXI_ID_W       (AXI_ID_W),
       .AXI_ADDRESS_W  (AXI_ADDRESS_W),
       .AXI_DATA_W     (AXI_DATA_W),
       .AXI_NUMBYTES   (AXI_NUMBYTES),
       .MEM_SIZE       (MEM_SIZE)
       ) 
   axi_mem_i
     (
      .clk(clk_i),
      .reset_(rst_ni),
      .*
      );

   // check if upper bits of len are 0s
   FV_axi_mem_axi4_arlen: assert property (@(posedge clk_i) axi_req_in.ar_valid |-> (axi_req_in.ar.len[7:4] == 4'b0));
   FV_axi_mem_axi4_awlen: assert property (@(posedge clk_i) axi_req_in.aw_valid |-> (axi_req_in.aw.len[7:4] == 4'b0));

endmodule // fv_ariane_axi_memory

