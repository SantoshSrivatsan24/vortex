`include "VX_cache_define.vh"

module VX_tag_access #(
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

`ifdef PERF_ENABLE
    output wire perf_unused_prefetched_blocks,
`endif

    input wire                          stall,

    // read/fill
    input wire                          lookup,
    input wire[`LINE_ADDR_WIDTH-1:0]    addr,
    input wire                          fill,    
    input wire                          flush,
    // Assignment 6
    input wire                          write_prefetch,   
    output wire                         read_prefetch_used,                
    output wire                         tag_match
);

    `UNUSED_PARAM (CACHE_ID)
    `UNUSED_PARAM (BANK_ID)
    `UNUSED_VAR (reset)
    `UNUSED_VAR (lookup)

    // Assignment 6
    localparam UNUSED_BLOCK   = 1'b0;
    localparam USED_BLOCK     = 1'b1;

    wire [`TAG_SELECT_BITS-1:0] read_tag;
    wire read_valid;
    // Assignment 6
    wire read_prefetch;
    wire write_prefetch_used;
    
    wire [`LINE_SELECT_BITS-1:0] line_addr = addr[`LINE_SELECT_BITS-1:0];
    wire [`TAG_SELECT_BITS-1:0] line_tag = `LINE_TAG_ADDR(addr);

    VX_sp_ram #(
        .DATAW      (1 + 1 + `TAG_SELECT_BITS),
        .SIZE       (`LINES_PER_BANK),
        .NO_RWCHECK (1)
    ) tag_store (
        .clk   (clk),                 
        .addr  (line_addr),   
        .wren  (fill || flush),
        .wdata ({!flush, write_prefetch, line_tag}),
        .rdata ({read_valid, read_prefetch, read_tag})
    );

    assign tag_match = read_valid && (line_tag == read_tag);

    // Assignment 6

    // write_used is set if a block brought in by software prefetch is accessed by another instruction.
    // we don't want write_used to be set for a software prefetch but rather for instructions that access
    // a block brought in by software prefetch
    assign write_prefetch_used = tag_match && read_prefetch && !write_prefetch;

    // update metadata EXCEPT when we evict a block (fill operation)
    // during a fill operation, we want to read the metadata to check if the block has been used.
    VX_sp_ram #(
        .DATAW      (1),
        .SIZE       (`LINES_PER_BANK),
        .NO_RWCHECK (1)
    ) metadata_store (
        .clk    (clk),
        .addr   (line_addr),
        .wren   (~(fill || flush) && !write_prefetch),
        .wdata  (write_prefetch_used),
        // we read data during a fill operation. During a fill, we check if the block that we are
        // evicting has been used.
        .rdata  (read_prefetch_used)
    );

    // Assignment 6
    // checking if a block is unused when it is about to be evicted.
`ifdef PERF_ENABLE
    assign perf_unused_prefetched_blocks = (fill || flush) && !read_used;
`endif
    
    `UNUSED_VAR (stall)
    
`ifdef DBG_PRINT_CACHE_TAG
    always @(posedge clk) begin
        if (fill && ~stall) begin
            // We want to check if the block that is being evicted by prefetch is used or unused.
            dpi_trace("ASSIGNMENT 6 TAG: %d: cache%0d:%0d tag-fill: write_prefetch=%0b, used?=%0b, addr=%0h, blk_addr=%0d, tag_id=%0h\n", $time, CACHE_ID, BANK_ID, write_prefetch, read_used, `LINE_TO_BYTE_ADDR(addr, BANK_ID), line_addr, line_tag);
        end
        if (flush) begin
            dpi_trace("%d: cache%0d:%0d tag-flush: addr=%0h, blk_addr=%0d\n", $time, CACHE_ID, BANK_ID, `LINE_TO_BYTE_ADDR(addr, BANK_ID), line_addr);
        end
        if (lookup && ~stall) begin                
            if (tag_match) begin
                // instructions accessing the prefetched block
                dpi_trace("ASSIGNMENT 6 TAG: %d: cache%0d:%0d tag-hit: read_prefetch=%0b, used?=%0b, addr=%0h, wid=%0d, PC=%0h, blk_addr=%0d, tag_id=%0h\n", $time, CACHE_ID, BANK_ID, read_prefetch, read_used, `LINE_TO_BYTE_ADDR(addr, BANK_ID), debug_wid, debug_pc, line_addr, line_tag);                
            end else begin
                // the software prefetch instruction
                dpi_trace("ASSIGNMENT 6 TAG: %d: cache%0d:%0d tag-miss: write_prefetch=%0b, addr=%0h, wid=%0d, PC=%0h, blk_addr=%0d, tag_id=%0h, old_tag_id=%0h\n", $time, CACHE_ID, BANK_ID, write_prefetch, `LINE_TO_BYTE_ADDR(addr, BANK_ID), debug_wid, debug_pc, line_addr, line_tag, read_tag);
            end
        end           
    end    
`endif

endmodule