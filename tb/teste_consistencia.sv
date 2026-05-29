// 7.4 Testes de Consistência — sequências R/W, repetição, conflito de index
`timescale 1ns/1ps

module teste_consistencia;
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

  // Mesmo index [13:4], tags distintos; tag[1:0] distinto => blocos distintos na memória
  localparam logic [9:0]  IDX_C   = 10'd100;
  localparam logic [31:0] ADDR_C0 = tb_make_addr(18'h000ABC, IDX_C, 2'b10);
  localparam logic [31:0] ADDR_C1 = tb_make_addr(18'h000ABD, IDX_C, 2'b10);

  initial begin
    logic [31:0] lido;
    int          c, i;

    falhas = 0;
    $display("=== teste_consistencia (7.4 Consistency) ===");
    tb_dut_reset();

    // --- 7.4.1 Sequência escrita -> leitura (mesmo endereço) ---
    tb_mem_write_word(ADDR_C0, 32'h0000_0000);
    tb_cpu_read(ADDR_C0, lido, c);
    tb_cpu_write(ADDR_C0, 32'h1234_5678, c);
    tb_cpu_read(ADDR_C0, lido, c);
    tb_check("write depois read: coerencia", lido === 32'h1234_5678, falhas);

    // --- 7.4.2 Acessos repetidos ao mesmo endereço ---
    for (i = 0; i < 5; i++) begin
      tb_cpu_read(ADDR_C0, lido, c);
      tb_check($sformatf("leitura repetida #%0d", i), lido === 32'h1234_5678, falhas);
    end

    // --- 7.4.3 Conflito: mesmo index, tags diferentes ---
    tb_dut_reset();
    tb_mem_write_word(ADDR_C0, 32'hAAAA_0000);
    tb_mem_write_word(ADDR_C1, 32'hBBBB_0000);

    tb_cpu_read(ADDR_C0, lido, c);
    tb_check("conflito: primeiro bloco", lido === 32'hAAAA_0000, falhas);

    tb_cpu_read(ADDR_C1, lido, c);
    tb_check("conflito: segundo bloco (mesmo index)", lido === 32'hBBBB_0000, falhas);

    tb_cpu_read(ADDR_C0, lido, c);  // miss novamente, recarrega da mem
    tb_check("conflito: reacesso ao primeiro bloco", lido === 32'hAAAA_0000, falhas);

    if (falhas == 0)
      $display("teste_consistencia: PASS");
    else begin
      $display("teste_consistencia: FAIL (%0d falhas)", falhas);
      $fatal(1);
    end
    $finish;
  end
endmodule
