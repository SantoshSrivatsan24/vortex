`ifndef VX_PERF_CACHE_IF
`define VX_PERF_CACHE_IF

`include "VX_define.vh"

interface VX_perf_cache_if ();

    wire [`PERF_CTR_BITS-1:0] reads;
    wire [`PERF_CTR_BITS-1:0] writes;
    wire [`PERF_CTR_BITS-1:0] read_misses;
    wire [`PERF_CTR_BITS-1:0] write_misses;
    wire [`PERF_CTR_BITS-1:0] bank_stalls;
    wire [`PERF_CTR_BITS-1:0] mshr_stalls;
    wire [`PERF_CTR_BITS-1:0] pipe_stalls;
    wire [`PERF_CTR_BITS-1:0] crsp_stalls;
    // Assignment 6
    wire [`PERF_CTR_BITS-1:0] prefetch_requests;
    wire [`PERF_CTR_BITS-1:0] prefetched_blocks;
    wire [`PERF_CTR_BITS-1:0] unused_prefetched_blocks;
    wire [`PERF_CTR_BITS-1:0] late_prefetches;



    modport master (
        output reads,
        output writes,
        output read_misses,
        output write_misses,
        output bank_stalls,
        output mshr_stalls,
        output pipe_stalls,
        output crsp_stalls,
        // Assignment 6
        output prefetch_requests,
        output prefetched_blocks,
        output unused_prefetched_blocks,
        output late_prefetches
    );

    modport slave (
        input reads,
        input writes,
        input read_misses,
        input write_misses,
        input bank_stalls,
        input mshr_stalls,
        input pipe_stalls,
        input crsp_stalls,
        // Assignment 6
        input prefetch_requests,
        input prefetched_blocks,
        input unused_prefetched_blocks,
        input late_prefetches
    );

endinterface

`endif