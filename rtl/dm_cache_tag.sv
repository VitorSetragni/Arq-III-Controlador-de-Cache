// Memória de tags — Figura e5.12.4 (Patterson, Seção 5.12)
import cache_def::*;

module dm_cache_tag (
    input  logic           clk,
    input  logic           rst,
    input  cache_req_type  tag_req,
    input  cache_tag_type  tag_write,
    output cache_tag_type  tag_read
);
  timeunit 1ns;
  timeprecision 1ps;

  cache_tag_type tag_mem [0:NUM_LINES-1];

  initial begin
    for (int i = 0; i < NUM_LINES; i++)
      tag_mem[i] = '0;
  end

  assign tag_read = tag_mem[tag_req.index];

  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < NUM_LINES; i++)
        tag_mem[i] <= '0;
    end else if (tag_req.we) begin
      tag_mem[tag_req.index] <= tag_write;
    end
  end

  // Leitura para testbench (simulação)
  function automatic logic [19:0] debug_peek(input logic [9:0] idx);
    return tag_mem[idx];
  endfunction

endmodule
