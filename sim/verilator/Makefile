# Makefile - Verilator build system for the SM83 / DMG FPGA skeleton.
# Run from anywhere with: make -C sim/verilator <target>
#
# Targets:
#   make sim   - build the Verilator simulation executable
#   make run   - run the simulation
#   make trace - run the simulation and dump waveform.vcd
#   make clean - remove build artifacts

VERILATOR  ?= verilator
TOP_MODULE := top_sim
ROOT       := ../..
OBJ_DIR    := build
EXE        := $(OBJ_DIR)/Vtop_sim

RTL_SOURCES := \
	$(ROOT)/rtl/gb/cpu/sm83_cpu.sv \
	$(ROOT)/rtl/gb/mmu/mmu.sv \
	$(ROOT)/rtl/gb/ppu/ppu.sv \
	$(ROOT)/rtl/gb/apu/apu.sv \
	$(ROOT)/rtl/top/top_sim.sv

CPP_SOURCES := sim_main.cpp

VERILATOR_FLAGS := \
	--sv \
	--cc \
	--exe \
	--build \
	--top-module $(TOP_MODULE) \
	--Mdir $(OBJ_DIR) \
	-CFLAGS "-std=c++17 -O2"

.PHONY: sim run trace clean

sim: $(EXE)

$(EXE): $(RTL_SOURCES) $(CPP_SOURCES)
	$(VERILATOR) $(VERILATOR_FLAGS) $(RTL_SOURCES) $(CPP_SOURCES)

run: sim
	$(EXE)

trace: VERILATOR_FLAGS += --trace
trace: clean sim
	$(EXE) --trace
	@echo "wrote waveform.vcd (open with gtkwave waveform.vcd or surfer waveform.vcd)"

clean:
	rm -rf $(OBJ_DIR) waveform.vcd waveform.fst
