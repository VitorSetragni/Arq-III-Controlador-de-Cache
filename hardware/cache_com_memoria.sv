// Top de simulação: CPU <-> cache <-> memória principal
`timescale 1ns/1ps

module cache_com_memoria (
    input  logic        clk,
    input  logic        reset,

    input  logic [31:0] cpu_addr,
    input  logic [31:0] cpu_data,
    input  logic        cpu_rw,
    input  logic        cpu_valid,
    output logic [31:0] cpu_rdata,
    output logic        cpu_ready
);
  logic [31:0]  mem_addr;
  logic [127:0] mem_wdata, mem_rdata;
  logic         mem_rw, mem_valid, mem_ready;

  controlador_cache u_cache (
      .clk       (clk),
      .rst       (reset),
      .cpu_addr  (cpu_addr),
      .cpu_data  (cpu_data),
      .cpu_rw    (cpu_rw),
      .cpu_valid (cpu_valid),
      .cpu_rdata (cpu_rdata),
      .cpu_ready (cpu_ready),
      .mem_ready (mem_ready),
      .mem_rdata (mem_rdata),
      .mem_addr  (mem_addr),
      .mem_wdata (mem_wdata),
      .mem_rw    (mem_rw),
      .mem_valid (mem_valid)
  );

  main_memory #(
      .ADDR_WIDTH (32),
      .DATA_WIDTH (32),
      .BLOCK_WORDS(4),
      .MEM_BLOCKS (4096),
      .LATENCY    (1)
  ) u_mem (
      .clk       (clk),
      .reset     (reset),
      .mem_valid (mem_valid),
      .mem_rw    (mem_rw),
      .mem_addr  (mem_addr),
      .mem_wdata (mem_wdata),
      .mem_rdata (mem_rdata),
      .mem_ready (mem_ready)
  );

endmodule
