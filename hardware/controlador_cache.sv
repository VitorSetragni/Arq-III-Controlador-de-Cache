// Wrapper: portas planas da CPU/memória <-> structs do pacote cache_def
`timescale 1ns/1ps

module controlador_cache (
    input  logic        clk,
    input  logic        rst,

    // CPU
    input  logic [31:0] cpu_addr,
    input  logic [31:0] cpu_data,
    input  logic        cpu_rw,
    input  logic        cpu_valid,
    output logic [31:0] cpu_rdata,
    output logic        cpu_ready,

    // Memória principal (bloco de 128 bits)
    input  logic        mem_ready,
    input  logic [127:0] mem_rdata,
    output logic [31:0] mem_addr,
    output logic [127:0] mem_wdata,
    output logic        mem_rw,
    output logic        mem_valid
);
  import cache_def::*;

  cpu_req_type    cpu_req;
  cpu_result_type cpu_res;
  mem_req_type    mem_req;
  mem_data_type   mem_data;

  assign cpu_req.addr  = cpu_addr;
  assign cpu_req.data  = cpu_data;
  assign cpu_req.rw    = cpu_rw;
  assign cpu_req.valid = cpu_valid;

  assign cpu_rdata  = cpu_res.data;
  assign cpu_ready  = cpu_res.ready;
  assign mem_addr   = mem_req.addr;
  assign mem_wdata  = mem_req.data;
  assign mem_rw     = mem_req.rw;
  assign mem_valid  = mem_req.valid;

  assign mem_data.data  = mem_rdata;
  assign mem_data.ready = mem_ready;

  dm_cache_fsm u_fsm (
      .clk     (clk),
      .rst     (rst),
      .cpu_req (cpu_req),
      .mem_data(mem_data),
      .mem_req (mem_req),
      .cpu_res (cpu_res)
  );

endmodule
