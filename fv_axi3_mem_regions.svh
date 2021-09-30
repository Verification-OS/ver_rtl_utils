
/*
0x00_0000_0000~0x00_8fff_ffff: weak order, cacheable  
0x00_9000_0000~0x00_bfff_ffff: strong order, uncacheable  
0x00_c000_0000~0x00_cfff_ffff: weak order, uncacheable  
0x00_d000_0000~0x00_efff_ffff: weak order, cacheable  
0x00_f000_0000~0x00_ffff_ffff: weak order, cacheable  
0x01_0000_0000~0x3f_ffff_ffff: weak order, cacheable  
0x40_0000_0000~0x4f_ffff_ffff: strong order, uncacheable  
0x50_0000_0000~0xff_ffff_ffff: weak order, cacheable 

NOTE: Address space 0x40_0000_0000 ~ 0x4f_ffff_ffff is reserved for peripherals and is not accessible to S mode.
 */

assign mem_base[0]  = 40'h00_0000_0000;
assign mem_limit[0] = 40'h00_8fff_ffff;
assign mem_base[1]  = 40'h00_9000_0000;
assign mem_limit[1] = 40'h00_bfff_ffff;
assign mem_base[2]  = 40'h00_c000_0000;
assign mem_limit[2] = 40'h00_cfff_ffff;
assign mem_base[3]  = 40'h00_d000_0000;
assign mem_limit[3] = 40'h00_efff_ffff;
assign mem_base[4]  = 40'h00_f000_0000;
assign mem_limit[4] = 40'h00_ffff_ffff;
assign mem_base[5]  = 40'h01_0000_0000;
assign mem_limit[5] = 40'h3f_ffff_ffff;
assign mem_base[6]  = 40'h40_0000_0000;
assign mem_limit[6] = 40'h4f_ffff_ffff;
assign mem_base[7]  = 40'h50_0000_0000;
assign mem_limit[7] = 40'hff_ffff_ffff;
