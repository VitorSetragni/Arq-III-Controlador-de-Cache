// Tipos e parâmetros da cache — Patterson & Hennessy, Seção 5.12 (Figuras e5.12.1–e5.12.2)
// Cache direta: 1024 linhas, bloco de 4 palavras (128 bits), write-back
`timescale 1ns/1ps

package cache_def;

  parameter int TAGMSB = 31;
  parameter int TAGLSB = 14;
  parameter int INDEX_MSB = 13;
  parameter int INDEX_LSB = 4;
  parameter int NUM_LINES = 1024;

  typedef struct packed {
    logic        valid;
    logic        dirty;
    logic [TAGMSB:TAGLSB] tag;
  } cache_tag_type;

  typedef struct packed {
    logic [INDEX_MSB:INDEX_LSB] index;
    logic                       we;
  } cache_req_type;

  typedef logic [127:0] cache_data_type;

  // CPU -> cache
  typedef struct packed {
    logic [31:0] addr;
    logic [31:0] data;
    logic        rw;     // 0 = leitura, 1 = escrita
    logic        valid;
  } cpu_req_type;

  // cache -> CPU
  typedef struct packed {
    logic [31:0] data;
    logic        ready;
  } cpu_result_type;

  // cache -> memória
  typedef struct packed {
    logic [31:0]     addr;
    logic [127:0]    data;
    logic            rw;
    logic            valid;
  } mem_req_type;

  // memória -> cache
  typedef struct packed {
    cache_data_type data;
    logic           ready;
  } mem_data_type;

endpackage
