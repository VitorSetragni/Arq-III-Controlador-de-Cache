// Teste mínimo: read miss seguido de read hit
`timescale 1ns/1ps

module teste_minimo;
  logic        clk, reset;
  logic [31:0] cpu_addr, cpu_data, cpu_rdata;
  logic        cpu_rw, cpu_valid, cpu_ready;

  localparam logic [31:0] ADDR = 32'h0000_0040;

  cache_com_memoria dut (
      .clk       (clk),
      .reset     (reset),
      .cpu_addr  (cpu_addr),
      .cpu_data  (cpu_data),
      .cpu_rw    (cpu_rw),
      .cpu_valid (cpu_valid),
      .cpu_rdata (cpu_rdata),
      .cpu_ready (cpu_ready)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task automatic cpu_read(input logic [31:0] addr, output logic [31:0] data);
    cpu_addr  = addr;
    cpu_data  = '0;
    cpu_rw    = 1'b0;
    cpu_valid = 1'b1;
    @(posedge clk);
    while (!cpu_ready) @(posedge clk);
    data = cpu_rdata;
    cpu_valid = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    logic [31:0] lido;

    $dumpfile("build/teste_minimo.vcd");
    $dumpvars(0, teste_minimo);

    cpu_addr = '0;
    cpu_data = '0;
    cpu_rw   = 0;
    cpu_valid = 0;
    reset = 1'b1;
    repeat (3) @(posedge clk);
    reset = 1'b0;

    // Pré-carrega palavra na memória (bypass da cache)
    dut.u_mem.debug_write_word(ADDR, 32'hDEAD_BEEF);

    // 1ª leitura: miss
    cpu_read(ADDR, lido);
    if (lido !== 32'hDEAD_BEEF) begin
      $display("FALHA miss: esperado DEADBEEF, obtido %08h", lido);
      $fatal(1);
    end
    $display("OK read miss: %08h", lido);

    // 2ª leitura: hit
    cpu_read(ADDR, lido);
    if (lido !== 32'hDEAD_BEEF) begin
      $display("FALHA hit: esperado DEADBEEF, obtido %08h", lido);
      $fatal(1);
    end
    $display("OK read hit:  %08h", lido);

    $display("teste_minimo: PASS");
    $finish;
  end
endmodule
