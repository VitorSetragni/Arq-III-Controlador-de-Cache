// 7.3 Testes de Substituição — eviction, write-back de bloco dirty
`timescale 1ns/1ps

module teste_substituicao;
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

  localparam logic [9:0]  IDX       = 10'd42;
  localparam logic [31:0] ADDR_TAG0 = tb_make_addr(18'h00000, IDX, 2'b00);
  localparam logic [31:0] ADDR_TAG1 = tb_make_addr(18'h00001, IDX, 2'b00);

  initial begin
    logic [31:0] lido, mem_a, mem_b;
    logic        v, d;
    logic [17:0] tag_lido;
    int          c;

    falhas = 0;
    $display("=== teste_substituicao (7.3 Replacement) ===");
    tb_dut_reset();

    // --- 7.3.1 Substituição de linha limpa (valid, dirty=0) ---
    tb_mem_write_word(ADDR_TAG0, 32'h1000_0001);
    tb_cpu_read(ADDR_TAG0, lido, c);  // miss, carrega, dirty=0

    tb_mem_write_word(ADDR_TAG1, 32'h2000_0002);
    tb_cpu_read(ADDR_TAG1, lido, c);  // miss, substitui linha limpa (sem write-back)

    tb_check("substituicao limpa: novo dado na cache", lido === 32'h2000_0002, falhas);
    tb_get_tag(ADDR_TAG1, v, d, tag_lido);
    tb_check("substituicao limpa: nova tag", tag_lido === tb_tag_of(ADDR_TAG1), falhas);
    tb_check("substituicao limpa: dirty=0 apos read miss", d === 1'b0, falhas);

    // --- 7.3.2 Substituição de linha dirty (write-back) ---
    tb_dut_reset();

    tb_mem_write_word(ADDR_TAG0, 32'hA000_000A);
    tb_cpu_read(ADDR_TAG0, lido, c);
    tb_cpu_write(ADDR_TAG0, 32'hA111_111A, c);  // dirty=1

    tb_mem_write_word(ADDR_TAG1, 32'hB000_000B);
    tb_cpu_read(ADDR_TAG1, lido, c);  // miss -> write_back -> allocate

    tb_mem_read_word(ADDR_TAG0, mem_a);
    tb_check("write-back: bloco antigo escrito na memoria",
             mem_a === 32'hA111_111A, falhas);

    tb_cpu_read(ADDR_TAG1, lido, c);
    tb_check("novo bloco na cache", lido === 32'hB000_000B, falhas);

    tb_get_tag(ADDR_TAG1, v, d, tag_lido);
    tb_check("tag atualizada para bloco novo", tag_lido === tb_tag_of(ADDR_TAG1), falhas);

    if (falhas == 0)
      $display("teste_substituicao: PASS");
    else begin
      $display("teste_substituicao: FAIL (%0d falhas)", falhas);
      $fatal(1);
    end
    $finish;
  end
endmodule
