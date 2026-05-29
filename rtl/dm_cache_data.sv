// Memória de dados (linhas de 128 bits) — Figura e5.12.4 (Patterson, Seção 5.12)
import cache_def::*;

module dm_cache_data (
    input  logic           clk,
    input  logic           rst,
    input  cache_req_type  data_req,
    input  cache_data_type data_write,
    output cache_data_type data_read
);
  timeunit 1ns;
  timeprecision 1ps;

  cache_data_type data_mem [0:NUM_LINES-1];

  initial begin
    for (int i = 0; i < NUM_LINES; i++)
      data_mem[i] = '0;
  end

  assign data_read = data_mem[data_req.index];

  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < NUM_LINES; i++)
        data_mem[i] <= '0;
    end else if (data_req.we) begin
      data_mem[data_req.index] <= data_write;
    end
  end

endmodule
