
`timescale 1ns/1ps

module sync_fifo (
    input  wire        clk,
    input  wire        rst,
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [31:0] din,
    output reg  [31:0] dout,
    output wire        full,
    output wire        empty
);

    // FIFO storage: 16 entries, each 32 bits wide
    reg [31:0] mem [0:15];

    // Pointer and occupancy registers
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count;

    // FIFO status flags
    assign full  = (count == 5'd16);
    assign empty = (count == 5'd0);

    // Accepted read and write operations
    wire rd_accept;
    wire wr_accept;

    assign rd_accept = rd_en && !empty;
    assign wr_accept = wr_en && (!full || rd_accept);

    // Synchronous FIFO operation
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 4'd0;
            rd_ptr <= 4'd0;
            count  <= 5'd0;
            dout   <= 32'd0;
        end
        else begin

            // Write operation
            if (wr_accept) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read operation
            if (rd_accept) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Occupancy update
            case ({wr_accept, rd_accept})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

endmodule
