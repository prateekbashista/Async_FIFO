`timescale 1ps/1ps

// Synchroniser for Clock Domain Crossing
module two_FF_sync
#( 
    parameter integer WIDTH = 8
)
( 
    input clk,
    input aresetn,
    input [WIDTH : 0] data,
    output logic [WIDTH : 0] q_data
);

    reg [WIDTH - 1 : 0] q1, q2;

    always_ff @(posedge clk or negedge aresetn) begin
        if(!aresetn) begin
            q1 <= 0;
            q2 <= 0;
        end
        else begin
            q1 <= data;
            q2 <= q1;
        end
    end

    assign q_data = q2;

endmodule


// Binary to Gray Converter
module b2g_conv
#( 
    parameter integer WIDTH = 8
)
(   input [WIDTH : 0] data_in,
    output logic [WIDTH : 0] data_out
);

    assign data_out = (data_in >> 1) ^ data_in;
endmodule


// Gray to Binary Converter
module g2b_conv
#( 
    parameter integer WIDTH = 8
)
( 
    input [WIDTH : 0] data_in, 
    output logic [WIDTH : 0] data_out
);

    integer i;

    always_comb begin
        for(i = 0; i<WIDTH; i = i+1) begin
            data_out[i]  = ^(data_in >> i);
        end
    end

endmodule




module ASYNC_FIFO
#(
    parameter integer WIDTH  = 8, 
    parameter integer DEPTH = 8
)

(
    input                           w_clk, // write clock
    input                           r_clk, // read clock
    input                           aresetn, // asynchronous reset
    input [WIDTH - 1 : 0]           w_data, // write data 
    input                           w_enable, // write enable
    output logic [WIDTH - 1 : 0]    r_data, // read data 
    input                           r_enable, // read enable
    output logic                    full, // fifo full flag
    output logic                    empty // fifo empty flag
    
);



    reg [WIDTH - 1 : 0] fifo_mem [0 : DEPTH - 1]; // fifo mem


    // ==================== Write Pointer ===========================

    reg [$clog2(DEPTH) : 0] wptr; // write pointer
    logic [$clog2(DEPTH) : 0] next_wptr;

    reg [$clog2(DEPTH) : 0] gray_wptr; // gray write pointer
    logic [$clog2(DEPTH) : 0] next_gray_wptr;

    // write pointer reg
    always_ff @(posedge w_clk or negedge aresetn) begin
        if(!aresetn) begin
            wptr <= 0;
            gray_wptr <= 0;
        end
        else begin
            wptr <= next_wptr;
            gray_wptr <= next_gray_wptr;
        end
    end

    // wptr update
    assign next_wptr = wptr + (w_enable && !full);

    // binary to gray conversion
    b2g_conv #($clog2(DEPTH)) b1(next_wptr, next_gray_wptr);

    // Synchroniser for CDC
    logic [$clog2(DEPTH) : 0] sync_gray_wptr; // synchronised gray pointer
    two_FF_sync #($clog2(DEPTH)) w_sync(r_clk, aresetn, gray_wptr, sync_gray_wptr);

    // ==============================================================



    // ==================== Read Pointer ============================

    reg [$clog2(DEPTH) : 0] rptr; // read pointer
    logic [$clog2(DEPTH) : 0] next_rptr;

    reg [$clog2(DEPTH) : 0] gray_rptr; // gray read pointer
    logic [$clog2(DEPTH) : 0] next_gray_rptr;

    // read pointer reg
    always_ff @(posedge r_clk or negedge aresetn) begin
        if(!aresetn) begin
            rptr <= 0;
            gray_rptr <= 0;
        end
        else begin
            rptr <= next_rptr;
            gray_rptr <= next_gray_rptr;
        end
    end

    //rptr
    assign next_rptr = rptr + (r_enable && !empty);

    // binary to gray conversion
    b2g_conv #($clog2(DEPTH)) b2(next_rptr, next_gray_rptr);

    // Synchroniser for CDC
    logic [$clog2(DEPTH) : 0] sync_gray_rptr; // synchronised gray pointer
    two_FF_sync #($clog2(DEPTH)) r_sync(w_clk, aresetn, gray_rptr, sync_gray_rptr);

    // ==============================================================



    // ============== Logic for full and empty conditions ===========

    logic next_full, next_empty;

    // full 
    always_ff @(posedge w_clk or negedge aresetn) begin
        if(!aresetn) begin
            full <= 0;
        end
        else begin
            full <= next_full;
        end
    end

    //empty
    always_ff @(posedge r_clk or negedge aresetn) begin
        if(!aresetn) begin 
            empty <= 1;
        end
        else begin
            empty <= next_empty;
        end
    end

    // empty condition
    // if the synchronised write pointer equal to the next gray read pointer
    assign next_empty  = (sync_gray_wptr == next_gray_rptr);

    // full condition
    assign next_full = (next_gray_wptr == {~sync_gray_rptr[$clog2(DEPTH) : $clog2(DEPTH) -1],
                                            sync_gray_rptr[$clog2(DEPTH) - 2 : 0]});

    //===============================================================
    

    //=================== Fifo Mem access ===========================

    integer i;
    always_ff @(posedge w_clk or negedge aresetn) begin
        if(!aresetn) begin
            for(i = 0; i<DEPTH; i = i+1) begin
                fifo_mem[i] <= 0;
            end
        end
        else if(w_enable && !full) begin
            fifo_mem[wptr[$clog2(DEPTH) - 1 : 0]] <= w_data;
        end

    end

    always_ff @(posedge r_clk or negedge aresetn) begin // It introduces a cycle delay as request is serviced the next cycle
        if(!aresetn) begin
            r_data <= 0;
        end
        else if(r_enable) begin
            r_data <= fifo_mem[rptr[$clog2(DEPTH) - 1 : 0]];
        end
    end
    //===============================================================



endmodule