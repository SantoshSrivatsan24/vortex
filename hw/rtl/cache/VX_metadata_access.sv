`include "VX_cache_define.vh"

module VX_metadata_access #(
    parameter CACHE_ID          = 0,
    parameter BANK_ID           = 0,
    // Size of cache in bytes
    parameter CACHE_SIZE        = 1, 
    // Size of line inside a bank in bytes
    parameter CACHE_LINE_SIZE   = 1, 
    // Number of banks
    parameter NUM_BANKS         = 1, 
    // Size of a word in bytes
    parameter WORD_SIZE         = 1,
    // bank offset from beginning of index range
    parameter BANK_ADDR_OFFSET  = 0
) (
    input wire                          clk,
    input wire                          reset,

`ifdef DBG_CACHE_REQ_INFO
`IGNORE_UNUSED_BEGIN
    input wire[31:0]                    debug_pc,
    input wire[`NW_BITS-1:0]            debug_wid,
`IGNORE_UNUSED_END
`endif

    input wire                          stall,

    input wire[`LINE_ADDR_WIDTH-1:0]    addr,
    input wire                          fill, 
    input wire                          rw,
    input wire                          prefetch,
    output wire                         read_used           
);

    `UNUSED_PARAM   (CACHE_ID)
    `UNUSED_PARAM   (BANK_ID)
    `UNUSED_VAR     (reset)    
    `UNUSED_VAR(addr)

    wire [`LINE_SELECT_BITS-1:0] line_addr = addr[`LINE_SELECT_BITS-1:0];
    // we don't want a prefetch instruction to set the used bit
    wire wren = (rw && ~prefetch) || fill;
    wire write_used = ~fill;

    VX_dp_ram #(
        .DATAW          (1),
        .SIZE           (`LINES_PER_BANK),
        .INIT_ENABLE    (1),
        .INIT_VALUE     (0),
        .NO_RWCHECK     (1)
    ) metadata_store (
        .clk   (clk),                 
        .waddr (line_addr),  
        .raddr (line_addr),
        .wren  (wren),
        .wdata (write_used),
        .rdata (read_used)
    );

    `UNUSED_VAR     (stall)
        
`ifdef DBG_PRINT_CACHE_METADATA
    always @(posedge clk) begin
        if (fill) begin
            dpi_trace("%d: cache%0d:%0d metadata-fill: write_used=%0b, read_used=%0b, wren=%0b, prefetch_instruction=%0b, addr=%0h, blk_addr=%0d\n", $time, CACHE_ID, BANK_ID, write_used, read_used, wren, prefetch, `LINE_TO_BYTE_ADDR(addr, BANK_ID), line_addr);
        end
        if (wren) begin                
            dpi_trace("%d: cache%0d:%0d metadata-access: write_used=%0b, read_used=%0b, wren=%0b, prefetch_instruction=%0b, addr=%0h, wid=%0d, PC=%0h, blk_addr=%0d\n", $time, CACHE_ID, BANK_ID, write_used, read_used, wren, prefetch, `LINE_TO_BYTE_ADDR(addr, BANK_ID), debug_wid, debug_pc, line_addr);                
        end           
    end    
`endif

endmodule