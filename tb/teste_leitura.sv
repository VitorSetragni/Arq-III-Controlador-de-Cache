// 7.1 Testes de Leitura (Read Path) — Trabalho Prático 1
`timescale 1ns/1ps

module teste_leitura;
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

  localparam logic [31:0] ADDR_A = tb_make_addr(18'h00000, 10'd10, 2'b00);
  localparam logic [9:0]  IDX_A  = 10'd10;

  initial begin
    logic [31:0] lido;
    logic [17:0] tag_lido;
    logic        v, d;
    int          c;

    falhas = 0;
    $display("=== teste_leitura (7.1 Read Path) ===");
    tb_dut_reset();

    // --- 7.1.1 Read miss + carga da memória ---
    tb_mem_write_word(ADDR_A, 32'hCAFE_BABE);
    tb_cpu_read(ADDR_A, lido, c);
    tb_check("read miss retorna dado da memoria", lido === 32'hCAFE_BABE, falhas);
    tb_check("read miss usa mais de 1 ciclo", c > 1, falhas);

    // --- 7.1.2 Read hit ---
    tb_cpu_read(ADDR_A, lido, c);
    tb_check("read hit retorna mesmo dado", lido === 32'hCAFE_BABE, falhas);
    tb_check("read hit mais rapido que miss", c < 4, falhas);

    // --- 7.1.3 Bits valid e tag após miss ---
    tb_get_tag(ADDR_A, v, d, tag_lido);
    tb_check("valid=1 apos miss", v === 1'b1, falhas);
    tb_check("tag correta", tag_lido === tb_tag_of(ADDR_A), falhas);
    tb_check("dirty=0 apos read miss", d === 1'b0, falhas);

    if (falhas == 0)
      $display("teste_leitura: PASS");
    else begin
      $display("teste_leitura: FAIL (%0d falhas)", falhas);
      $fatal(1);
    end
    $finish;
  end
endmodule
