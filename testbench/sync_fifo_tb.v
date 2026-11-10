`timescale 1ns/1ps


module sync_fifo_tb;

reg clk;
reg rst;
reg wr_en;
reg rd_en;
reg [31:0] din;

wire [31:0] dout;
wire full;
wire empty;

integer i;

// DUT: Device Under Test
sync_fifo dut (
.clk(clk),
.rst(rst),
.wr_en(wr_en),
.rd_en(rd_en),
.din(din),
.dout(dout),
.full(full),
.empty(empty)
);

// 10 ns clock period
initial begin
clk = 0;
forever #5 clk = ~clk;
end

// Write one data word
task write_item;
input [31:0] value;
begin
@(negedge clk);
if (full)
$fatal(1, "Unexpected FULL before write");

wr_en = 1;
din = value;

@(posedge clk);
#1;
wr_en = 0;
end
endtask

// Read one data word and check it
task read_item;
input [31:0] expected;
begin
@(negedge clk);
if (empty)
$fatal(1, "Unexpected EMPTY before read");

rd_en = 1;

@(posedge clk);
#1;

if (dout !== expected)
$fatal(1, "Read mismatch: expected %h, got %h",
expected, dout);

rd_en = 0;
end
endtask

initial begin
$dumpfile("simulation/sync_fifo.vcd");
$dumpvars(0, sync_fifo_tb);

rst = 1;
wr_en = 0;
rd_en = 0;
din = 0;

// Reset
@(negedge clk);
rst = 0;

if (!empty)
$fatal(1, "FIFO should be EMPTY after reset");

$display("TEST 1: Filling FIFO");

// Fill all 16 entries
for (i = 0; i < 16; i = i + 1)
write_item(32'h1000 + i);

if (!full)
$fatal(1, "FIFO did not become FULL");

$display("PASS: FIFO became FULL");

// Attempt an extra write while FULL
@(negedge clk);
wr_en = 1;
din = 32'hDEADBEEF;

@(posedge clk);
#1;
wr_en = 0;

if (!full)
$fatal(1, "FULL flag changed after rejected write");

$display("PASS: Overflow write rejected");

$display("TEST 2: Reading all 16 entries");

// Read and verify all entries in order
for (i = 0; i < 16; i = i + 1)
read_item(32'h1000 + i);

if (!empty)
$fatal(1, "FIFO did not become EMPTY");

$display("PASS: All 16 words read correctly");
$display("PASS: FIFO became EMPTY");

// Attempt an invalid read while EMPTY
@(negedge clk);
rd_en = 1;

@(posedge clk);
#1;
rd_en = 0;

if (!empty)
$fatal(1, "EMPTY flag changed after rejected read");

$display("PASS: Underflow read rejected");

$display("TEST 3: Simultaneous read and write");

write_item(32'hAAAA0001);
write_item(32'hBBBB0002);

// Read the oldest word and write a new word together
@(negedge clk);
wr_en = 1;
rd_en = 1;
din = 32'hCCCC0003;

@(posedge clk);
#1;

if (dout !== 32'hAAAA0001)
$fatal(1, "Simultaneous read/write data mismatch");

wr_en = 0;
rd_en = 0;

// Check remaining FIFO order
read_item(32'hBBBB0002);
read_item(32'hCCCC0003);

if (!empty)
$fatal(1, "FIFO should be EMPTY at end");

$display("PASS: Simultaneous read/write");
$display("ALL FIFO TESTS PASSED");

#10;
$finish;
end

endmodule
