// 7.2 Testes de Escrita (Write Path) — write-back, write-allocate
`timescale 1ns/1ps

module teste_escrita;
  logic        clk, reset;
  logic [31:0] cpu_addr, cpu_data, cpu_rdata;
  logic        cpu_rw, cpu_valid, cpu_ready;

  int falhas;

  cache_com_memoria dut (
      .clk(clk), .reset(reset),
      .cpu_addr(cpu_addr), .cpu_data(cpu_data), .cpu_rw(cpu_rw),
      .cpu_valid(cpu_valid), .cpu_rdata(cpu_rdata), .cpu_ready(cpu_ready)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  `include "tb_common.svh"

  localparam logic [31:0] ADDR_W = tb_make_addr(18'h00001, 10'd20, 2'b01);

  initial begin
    logic [31:0] lido, mem_word;
    logic        v, d;
    logic [17:0] tag_lido;
    int          c;

    falhas = 0;
    $display("=== teste_escrita (7.2 Write Path) ===");
    tb_dut_reset();

    // --- 7.2.1 Write miss (write-allocate) ---
    tb_mem_write_word(ADDR_W, 32'h1111_1111);
    tb_cpu_write(ADDR_W, 32'hAAAA_AAAA, c);
    tb_check("write miss completa", c > 1, falhas);

    tb_cpu_read(ADDR_W, lido, c);
    tb_check("write miss: dado na cache", lido === 32'hAAAA_AAAA, falhas);

    tb_get_tag(ADDR_W, v, d, tag_lido);
    tb_check("write miss: valid=1", v === 1'b1, falhas);
    tb_check("write miss: dirty=1", d === 1'b1, falhas);

    // --- 7.2.2 Write hit ---
    tb_mem_read_word(ADDR_W, mem_word);
    tb_check("write-back: memoria ainda tem valor antigo apos write hit",
             mem_word === 32'h1111_1111, falhas);

    tb_cpu_write(ADDR_W, 32'hBBBB_BBBB, c);
    tb_check("write hit mais rapido que miss", c < 6, falhas);

    tb_cpu_read(ADDR_W, lido, c);
    tb_check("write hit: cache atualizada", lido === 32'hBBBB_BBBB, falhas);

    tb_get_tag(ADDR_W, v, d, tag_lido);
    tb_check("write hit: dirty permanece 1", d === 1'b1, falhas);

    tb_mem_read_word(ADDR_W, mem_word);
    tb_check("write-back: memoria ainda nao atualizada", mem_word === 32'h1111_1111, falhas);

    if (falhas == 0)
      $display("teste_escrita: PASS");
    else begin
      $display("teste_escrita: FAIL (%0d falhas)", falhas);
      $fatal(1);
    end
    $finish;
  end
endmodule
