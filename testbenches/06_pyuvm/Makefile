CWD = $(shell pwd)
HDL_SRC = /home/manbenit/Gitlab/uvm-excercices/models/alu_taller
SIM ?=  icarus
WAVES ?= 1

VERILOG_SOURCES = $(shell find $(HDL_SRC) -type f \( -name "*.v" -o -name "*.sv" \)) 
#VERILOG_SOURCES = ../../models/alu_taller/ALU.v ../../models/alu_taller/Sumador.v
MODULE = ALU_tb
TOPLEVEL = ALU
TOPLEVEL_LANG ?= verilog


include $(shell cocotb-config --makefiles)/Makefile.sim