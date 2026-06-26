


module FIFO_buffer(clk,s_reset,write_data,wr_en,full,rd_en,read_data,empty);

// Inputs
input clk,s_reset,wr_en,rd_en;
input [7:0]write_data;

// Outputs
output empty,full;
output reg [7:0]read_data;

// FIFO parameters
parameter DEPTH=1024,WIDTH=8;

// FIFO memory array
reg [WIDTH-1:0]mem[0:DEPTH-1];

// Write pointer, Read pointer and occupancy count
reg [9:0] wr_ptr;
reg [9:0] rd_ptr;
reg [10:0]count;

// Status flags derived from count
assign empty = (count==0)     ? 1 : 0;
assign full  = (count==DEPTH) ? 1 : 0;

// Initial values (mainly for simulation)
initial
begin
    wr_ptr = 0;
    rd_ptr = 0;
    count  = 0;
end

// Main FIFO operation
always @(posedge clk)
begin

    // Synchronous reset
    if (s_reset)
    begin
        wr_ptr    <= 0;
        rd_ptr    <= 0;
        count     <= 0;
        read_data <= 0;
    end

    // ---------------------------
    // Write operation only
    // ---------------------------
    else if(wr_en && !rd_en && !full)
    begin
        // Store incoming data
        mem[wr_ptr] <= write_data;

        // Increase occupancy count
        count <= count + 1;

        // Circular write pointer update
        if(wr_ptr == DEPTH-1)
            wr_ptr <= 0;
        else
            wr_ptr <= wr_ptr + 1;
    end

    // ---------------------------
    // Read operation only
    // ---------------------------
    else if(!wr_en && rd_en && !empty)
    begin
        // Read oldest data
        read_data <= mem[rd_ptr];

        // Decrease occupancy count
        count <= count - 1;

        // Circular read pointer update
        if(rd_ptr == DEPTH-1)
            rd_ptr <= 0;
        else
            rd_ptr <= rd_ptr + 1;
    end

    // ---------------------------
    // Simultaneous read and write
    // FIFO not empty
    // ---------------------------
    else if(wr_en && rd_en && !empty)
    begin
        // Write new data
        mem[wr_ptr] <= write_data;

        // Read old data
        read_data <= mem[rd_ptr];

        // Count unchanged
        // (+1 write and -1 read)

        // Update write pointer
        if(wr_ptr == DEPTH-1)
            wr_ptr <= 0;
        else
            wr_ptr <= wr_ptr + 1;

        // Update read pointer
        if(rd_ptr == DEPTH-1)
            rd_ptr <= 0;
        else
            rd_ptr <= rd_ptr + 1;
    end

    // ---------------------------
    // FWFT bypass case
    // FIFO empty and both
    // read and write requested
    // ---------------------------
    else if(wr_en && rd_en && empty)
    begin
        // Directly pass input to output
        // without storing in FIFO
        read_data <= write_data;
    end

end

endmodule

/* The FIFO uses count-based full and empty detection.
Write and read pointers are implemented as circular pointers.
A First-Word Fall-Through (FWFT) bypass path is provided when the FIFO is empty and both read and write are asserted simultaneously.
*/


module test_FIFO;

reg clk,s_reset,wr_en,rd_en;
reg [7:0]write_data;

wire empty,full;
wire [7:0]read_data;

integer i;

FIFO_buffer F1 (clk,s_reset,write_data,wr_en,full,rd_en,read_data,empty);

initial 
begin
clk=0;
s_reset=1;
wr_en=0;
rd_en=0;
end

always #5 clk=~clk;

initial 
        begin
        #3 s_reset=0; wr_en=1;
        #1;
        for (i=0;i<1024;i=i+1)
        begin
        write_data=i;
        #10;
        end 
        #10 wr_en=0; write_data=0; rd_en=1;
        #50 wr_en=0; rd_en=1; s_reset=1;
        #10 wr_en=1; rd_en=1; s_reset=0;
            
         end 

initial  begin
        $dumpfile("test_FIFO.vcd");
        $dumpvars(0,test_FIFO);
        $monitor("T=%0t reset=%b wr_en=%b rd_en=%b wr_data=%d full=%b rd_data=%d empty=%b ",$time,s_reset,wr_en,rd_en,write_data,full,read_data,empty);
        #20400 $finish;
        end 
        endmodule



