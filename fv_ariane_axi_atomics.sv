
`include "config.vh"

import ariane_pkg::*;
import ariane_axi::*;

module fv_ariane_axi_atomics #(
    /// AXI Parameters
    parameter int unsigned AXI_ADDR_WIDTH = 0,
    parameter int unsigned AXI_DATA_WIDTH = 0,
    parameter int unsigned AXI_ID_WIDTH = 0,
    parameter int unsigned AXI_USER_WIDTH = 0,
    /// Maximum number of AXI bursts outstanding at the same time
    parameter int unsigned AXI_MAX_WRITE_TXNS = 0,
    // Word width of the widest RISC-V processor that can issue requests to this module.
    // 32 for RV32; 64 for RV64, where both 32-bit (.W suffix) and 64-bit (.D suffix) AMOs are
    // supported if `aw_strb` is set correctly.
    parameter int unsigned RISCV_WORD_WIDTH = 0,
    /// Derived Parameters (do NOT change manually!)
    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8
) (
    input  logic    clk_i,
    input  logic    rst_ni,
    input  ariane_axi::req_t  slv_i,
    output ariane_axi::resp_t slv_o,

    output ariane_axi::req_t  mst_o,
    input  ariane_axi::resp_t mst_i
);

    axi_riscv_atomics #(
        .AXI_ADDR_WIDTH     (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH     (AXI_DATA_WIDTH),
        .AXI_ID_WIDTH       (AXI_ID_WIDTH),
        .AXI_USER_WIDTH     (AXI_USER_WIDTH),
        .AXI_MAX_WRITE_TXNS (AXI_MAX_WRITE_TXNS),
        .RISCV_WORD_WIDTH   (RISCV_WORD_WIDTH)
    ) i_atomics (
        .clk_i           ( clk_i         ),
        .rst_ni          ( rst_ni        ),
        .slv_aw_addr_i   ( slv_i.aw.addr   ),
        .slv_aw_prot_i   ( slv_i.aw.prot   ),
        .slv_aw_region_i ( slv_i.aw.region ),
        .slv_aw_atop_i   ( slv_i.aw.atop   ),
        .slv_aw_len_i    ( slv_i.aw.len    ),
        .slv_aw_size_i   ( slv_i.aw.size   ),
        .slv_aw_burst_i  ( slv_i.aw.burst  ),
        .slv_aw_lock_i   ( slv_i.aw.lock   ),
        .slv_aw_cache_i  ( slv_i.aw.cache  ),
        .slv_aw_qos_i    ( slv_i.aw.qos    ),
        .slv_aw_id_i     ( slv_i.aw.id     ),
        .slv_aw_user_i   ( slv_i.aw.user   ),
        .slv_aw_ready_o  ( slv_o.aw_ready  ),
        .slv_aw_valid_i  ( slv_i.aw_valid  ),
        .slv_ar_addr_i   ( slv_i.ar.addr   ),
        .slv_ar_prot_i   ( slv_i.ar.prot   ),
        .slv_ar_region_i ( slv_i.ar.region ),
        .slv_ar_len_i    ( slv_i.ar.len    ),
        .slv_ar_size_i   ( slv_i.ar.size   ),
        .slv_ar_burst_i  ( slv_i.ar.burst  ),
        .slv_ar_lock_i   ( slv_i.ar.lock   ),
        .slv_ar_cache_i  ( slv_i.ar.cache  ),
        .slv_ar_qos_i    ( slv_i.ar.qos    ),
        .slv_ar_id_i     ( slv_i.ar.id     ),
        .slv_ar_user_i   ( slv_i.ar.user   ),
        .slv_ar_ready_o  ( slv_o.ar_ready  ),
        .slv_ar_valid_i  ( slv_i.ar_valid  ),
        .slv_w_data_i    ( slv_i.w.data    ),
        .slv_w_strb_i    ( slv_i.w.strb    ),
        .slv_w_user_i    ( slv_i.w.user    ),
        .slv_w_last_i    ( slv_i.w.last    ),
        .slv_w_ready_o   ( slv_o.w_ready   ),
        .slv_w_valid_i   ( slv_i.w_valid   ),
        .slv_r_data_o    ( slv_o.r.data    ),
        .slv_r_resp_o    ( slv_o.r.resp    ),
        .slv_r_last_o    ( slv_o.r.last    ),
        .slv_r_id_o      ( slv_o.r.id      ),
        .slv_r_user_o    ( slv_o.r.user    ),
        .slv_r_ready_i   ( slv_i.r_ready   ),
        .slv_r_valid_o   ( slv_o.r_valid   ),
        .slv_b_resp_o    ( slv_o.b.resp    ),
        .slv_b_id_o      ( slv_o.b.id      ),
        .slv_b_user_o    ( slv_o.b.user    ),
        .slv_b_ready_i   ( slv_i.b_ready   ),
        .slv_b_valid_o   ( slv_o.b_valid   ),

        .mst_aw_addr_o   ( mst_o.aw.addr   ),
        .mst_aw_prot_o   ( mst_o.aw.prot   ),
        .mst_aw_region_o ( mst_o.aw.region ),
        .mst_aw_atop_o   ( mst_o.aw.atop   ),
        .mst_aw_len_o    ( mst_o.aw.len    ),
        .mst_aw_size_o   ( mst_o.aw.size   ),
        .mst_aw_burst_o  ( mst_o.aw.burst  ),
        .mst_aw_lock_o   ( mst_o.aw.lock   ),
        .mst_aw_cache_o  ( mst_o.aw.cache  ),
        .mst_aw_qos_o    ( mst_o.aw.qos    ),
        .mst_aw_id_o     ( mst_o.aw.id     ),
        .mst_aw_user_o   ( mst_o.aw.user   ),
        .mst_aw_ready_i  ( mst_i.aw_ready  ),
        .mst_aw_valid_o  ( mst_o.aw_valid  ),
        .mst_ar_addr_o   ( mst_o.ar.addr   ),
        .mst_ar_prot_o   ( mst_o.ar.prot   ),
        .mst_ar_region_o ( mst_o.ar.region ),
        .mst_ar_len_o    ( mst_o.ar.len    ),
        .mst_ar_size_o   ( mst_o.ar.size   ),
        .mst_ar_burst_o  ( mst_o.ar.burst  ),
        .mst_ar_lock_o   ( mst_o.ar.lock   ),
        .mst_ar_cache_o  ( mst_o.ar.cache  ),
        .mst_ar_qos_o    ( mst_o.ar.qos    ),
        .mst_ar_id_o     ( mst_o.ar.id     ),
        .mst_ar_user_o   ( mst_o.ar.user   ),
        .mst_ar_ready_i  ( mst_i.ar_ready  ),
        .mst_ar_valid_o  ( mst_o.ar_valid  ),
        .mst_w_data_o    ( mst_o.w.data    ),
        .mst_w_strb_o    ( mst_o.w.strb    ),
        .mst_w_user_o    ( mst_o.w.user    ),
        .mst_w_last_o    ( mst_o.w.last    ),
        .mst_w_ready_i   ( mst_i.w_ready   ),
        .mst_w_valid_o   ( mst_o.w_valid   ),
        .mst_r_data_i    ( mst_i.r.data    ),
        .mst_r_resp_i    ( mst_i.r.resp    ),
        .mst_r_last_i    ( mst_i.r.last    ),
        .mst_r_id_i      ( mst_i.r.id      ),
        .mst_r_user_i    ( mst_i.r.user    ),
        .mst_r_ready_o   ( mst_o.r_ready   ),
        .mst_r_valid_i   ( mst_i.r_valid   ),
        .mst_b_resp_i    ( mst_i.b.resp    ),
        .mst_b_id_i      ( mst_i.b.id      ),
        .mst_b_user_i    ( mst_i.b.user    ),
        .mst_b_ready_o   ( mst_o.b_ready   ),
        .mst_b_valid_i   ( mst_i.b_valid   )
    );

endmodule // fv_ariane_axi_atomics

