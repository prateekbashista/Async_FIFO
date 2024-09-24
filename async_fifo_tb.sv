`timescale 1ps/1ps


module fifo_tb;

logic wclk, rclk,aresetn, w_enable, r_enable, full, empty;

logic [7:0] wdata,rdata;


// write clock
initial begin
    wclk = 0;
    forever begin
        #35ns wclk = ~wclk;
    end
end

// read clock
initial begin
    rclk = 0;
    forever begin
        #10ns rclk = ~rclk;
    end
end

integer i;
// operation
initial begin
            aresetn = 1;
            wdata = 0;
            w_enable = 0;
            r_enable = 0;
    #30ns   aresetn = 0;
    #70ns   aresetn = 1;

    for(i = 0; i < 9; i = i+1) begin
        #70ns   wdata = i+2; w_enable = 1'b1;
        #70ns    wdata = 8'h0; w_enable = 1'b0;
    end

    for(i = 0; i < 10; i = i+1) begin
        #20ns   r_enable = 1'b1;
        #20ns   r_enable = 1'b0;
    end


    for(i = 0; i < 9; i = i+1) begin
        #70ns   wdata = 8'hEE; w_enable = 1'b1;
        #70ns    wdata = 8'h0; w_enable = 1'b0;
    end

    #20ns   r_enable = 1'b1;
    #20ns   r_enable = 1'b0;
    #70ns   wdata = 8'hEE; w_enable = 1'b1;
    #70ns    wdata = 8'h0; w_enable = 1'b0;

end

ASYNC_FIFO
#(
    .WIDTH(8), 
    .DEPTH(8)
)
fifo1
(
    .w_clk(wclk), // write clock
    .r_clk(rclk), // read clock
    .aresetn(aresetn), // asynchronous reset
    .w_data(wdata), // write data 
    .w_enable(w_enable), // write enable
    .r_data(rdata), // read data 
    .r_enable(r_enable), // read enable
    .full(full), // fifo full flag
    .empty(empty) // fifo empty flag
    
);




endmodule