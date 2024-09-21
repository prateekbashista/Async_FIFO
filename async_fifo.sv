

// Synchroniser for Clock Domain Crossing
module synchroniser
#( 
    parameter integer WIDTH = 8;
)
( 
    input clk,
    input aresetn,
    input [WIDTH - 1 : 0] data,
    output logic [WIDTH - 1 : 0] q_data,
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
    parameter integer WIDTH = 8;
)
(   input [WIDTH - 1 : 0] data_in,
    output logic [WIDTH - 1 : 0] data_out
);

    
endmodule




module ASYNC_FIFO
#(
    parameter integer WIDTH  = 8, 
    parameter integer DEPTH = 8
)

(
    input                           w_clk,
    input                           r_clk,
    input                           aresetn,
    input [WIDTH - 1 : 0]           w_data,
    input                           w_enable,
    output logic [WIDTH - 1 : 0]    r_data,
    input                           r_enable,
    output logic                    full,
    output logic                    empty
    
);

    reg [WIDTH - 1 : 0] fifo_mem [DEPTH]; // fifo mem


    reg [$clog2(DEPTH) - 1 : 0] wptr; // write pointer
    logic [$clog2(DEPTH) - 1 : 0] next_wptr;

    always_ff @(posedge w_clk or negedge aresetn) begin
        if(!aresetn) begin
            wptr <= 0;
        end
        else begin
            wptr <= next_wptr;
        end
    end

    reg [$clog2(DEPTH) - 1 : 0] rptr; // read pointer
    logic [$clog2(DEPTH) - 1 : 0] next_rptr;

    always_ff @(posedge r_clk or negedge aresetn) begin
        if(!aresetn) begin
            rptr <= 0;
        end
        else begin
            rptr <= next_rptr;
        end
    end


endmodule