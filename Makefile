# Simulação com Icarus Verilog (SystemVerilog 2012)
IVERILOG ?= iverilog
VVP      ?= vvp

BUILD_DIR := build
RTL_PKG   := rtl/cache_def.sv
RTL_MODS  := rtl/dm_cache_tag.sv rtl/dm_cache_data.sv rtl/dm_cache_fsm.sv
HW        := hardware/controlador_cache.sv hardware/main_memory.sv hardware/cache_com_memoria.sv
TB_COMMON := tb/tb_common.svh

IVERILOG_FLAGS := -g2012 -Wall -Irtl -Ihardware -Itb

# Testes por classe (Trabalho Prático 1 — Seção 7)
TB_TESTS := teste_minimo teste_leitura teste_escrita teste_substituicao teste_consistencia teste_limites

.PHONY: all test sim_min clean dirs $(TB_TESTS)

all: test

dirs:
	@mkdir -p $(BUILD_DIR)

define RUN_TEST
$(BUILD_DIR)/$(1): dirs tb/$(1).sv $(TB_COMMON) $(RTL_PKG) $(RTL_MODS) $(HW)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $$@ tb/$(1).sv $(RTL_PKG) $(RTL_MODS) $(HW)
	$(VVP) $$@ | tee $(BUILD_DIR)/$(1).log
	@grep -q "PASS" $(BUILD_DIR)/$(1).log || (echo ">>> $(1) FALHOU <<<"; exit 1)
endef

$(foreach t,$(TB_TESTS),$(eval $(call RUN_TEST,$(t))))

test: $(addprefix $(BUILD_DIR)/,$(TB_TESTS))
	@echo ""
	@echo "========================================="
	@echo "  Todos os testes PASS ($(words $(TB_TESTS)))"
	@echo "========================================="

sim_min: $(BUILD_DIR)/teste_minimo

clean:
	rm -rf $(BUILD_DIR)
