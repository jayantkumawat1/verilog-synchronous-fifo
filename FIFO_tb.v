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
