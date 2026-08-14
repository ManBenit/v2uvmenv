CWD = $(shell pwd)
HDL_SRC = ../../models/alu_taller
TOPLEVEL_LANG ?= verilog

# Variables de simulación
SIM ?= icarus
TOPLEVEL = ALU
MODULE = ALU_tb

# Sincronización de tiempos para Python (Cocotb)
# Le decimos explícitamente a cocotb cómo interpretar los tiempos (ej. await Timer(1, "ns"))
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps
export WAVES = 1



# ==========================================
# CONFIGURACIÓN ESPECÍFICA POR SIMULADOR
# ==========================================
ifeq ($(SIM),verilator)
    # --- VERILATOR ---
    # Verilator accept timescale through console
    EXTRA_ARGS += --timescale 1ns/1ps --trace -Wno-WIDTHEXPAND -Wno-fatal
    VERILOG_SOURCES = $(shell find $(HDL_SRC) -type f \( -name "*.v" -o -name "*.sv" \))
else
    # --- ICARUS ---
    # Trick: Dynamic timescale
    $(shell echo "\`timescale 1ns/1ps" > timescale.v)
    VERILOG_SOURCES = $(CWD)/timescale.v  $(shell find $(HDL_SRC) -type f \( -name "*.v" -o -name "*.sv" \))
endif

# Importar las reglas nativas de Cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim


clean_all: clean
	rm -rf __pycache__ results.xml sim_build dump.vcd *.fst *.vcd timescale.v wave_dump.v