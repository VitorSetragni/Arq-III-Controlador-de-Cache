// 7.5 Testes de Casos Limite
`timescale 1ns/1ps

module teste_limites;
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

  localparam logic [31:0] ADDR_MIN = tb_make_addr(18'h00000, 10'd0,    2'b00);
  localparam logic [31:0] ADDR_MAX = tb_make_addr(18'h3FFFF, 10'd1023, 2'b11);
  localparam logic [31:0] ADDR_HI  = 32'hFFFF_FFFC;

  initial begin
    logic [31:0] lido;
    logic        v, d;
    logic [17:0] tag_lido;
    int          c, i;

    falhas = 0;
    $display("=== teste_limites (7.5 Edge Cases) ===");
    tb_dut_reset();

    // --- 7.5.1 Cache inválida após reset ---
    for (i = 0; i < 1024; i += 512) begin
      tb_get_tag(tb_make_addr(18'h0, i[9:0], 2'b00), v, d, tag_lido);
      tb_check($sformatf("reset: linha %0d invalida", i), v === 1'b0, falhas);
    end

    // --- 7.5.2 Primeiro acesso (estado vazio) = miss ---
    tb_mem_write_word(ADDR_MIN, 32'h0000_0001);
    tb_cpu_read(ADDR_MIN, lido, c);
    tb_check("cache vazia: read miss", lido === 32'h0000_0001, falhas);
    tb_check("cache vazia: miss > 1 ciclo", c > 1, falhas);

    // --- 7.5.3 Endereços extremos (index 0 e 1023) ---
    tb_mem_write_word(ADDR_MAX, 32'hFFFF_000F);
    tb_cpu_read(ADDR_MAX, lido, c);
    tb_check("index max: leitura correta", lido === 32'hFFFF_000F, falhas);

    tb_dut_reset();
    tb_mem_write_word(ADDR_HI, 32'hDEAD_FFFF);
    tb_cpu_read(ADDR_HI, lido, c);
    tb_check("endereco alto: leitura correta", lido === 32'hDEAD_FFFF, falhas);

    tb_get_tag(ADDR_MAX, v, d, tag_lido);
    tb_check("index max: valid apos miss", v === 1'b1, falhas);

    if (falhas == 0)
      $display("teste_limites: PASS");
    else begin
      $display("teste_limites: FAIL (%0d falhas)", falhas);
      $fatal(1);
    end
    $finish;
  end
endmodule
