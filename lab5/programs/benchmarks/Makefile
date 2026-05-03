#=======================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#
SHELL := /bin/bash

default: all

bmarkdir := $(CURDIR)
bmarks_build_dir := $(bmarkdir)/../build/benchmarks
bmarks_build_bin_dir := $(bmarks_build_dir)/bin
bmarks_build_obj_dir := $(bmarks_build_dir)/obj
bmarks_build_dump_dir := $(bmarks_build_dir)/dump
bmarks_build_vmh_dir := $(bmarks_build_dir)/vmh

#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks = \
	median \
	qsort \
	towers \
	vvadd \
	multiply \

bmarks_host = \
	median \
	qsort \
	towers \
	vvadd \
	multiply \

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

HOST_OPTS = -std=gnu99 -DPREALLOCATE=0 -DHOST_DEBUG=1 -I$(bmarkdir)/common
HOST_COMP = gcc $(HOST_OPTS)

# RISCV_TOOL_DIR = /mit/6.175/rv32-gcc/bin
# RISCV_PREFIX = $(RISCV_TOOL_DIR)/riscv32-unknown-elf
RISCV_PREFIX = riscv64-unknown-elf
# gcc
RISCV_GCC = $(RISCV_PREFIX)-gcc
RISCV_GCC_OPTS = -march=rv32i_zicsr -mabi=ilp32 -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
# link
RISCV_LINK = $(RISCV_GCC) -march=rv32i_zicsr -mabi=ilp32 -T$(bmarkdir)/common/test.ld $(incs) -I$(bmarks_build_obj_dir)/
# RISCV_LINK_OPTS = -nostdlib -nostartfiles -ffast-math -lc -lgcc
RISCV_LINK_OPTS = -nostdlib -nostartfiles -ffast-math -lgcc #去掉-lc 和-nostdlib矛盾了
# objdump
RISCV_OBJDUMP = $(RISCV_PREFIX)-objdump --disassemble --disassemble-zeroes --section=.text --section=.text.startup --section=.data
# convert to VMH: 64KB memory
# RISCV_ELF2HEX = $(RISCV_TOOL_DIR)/elf2hex
RISCV_ELF2HEX = riscv64-unknown-elf-elf2hex
VMH_WIDTH = 64
VMH_DEPTH = 65536

VPATH += $(addprefix $(bmarkdir)/, $(bmarks))
VPATH += $(bmarkdir)/common
VPATH += $(bmarks_build_bin_dir)
VPATH += $(bmarks_build_obj_dir)
VPATH += $(bmarks_build_dump_dir)
VPATH += $(bmarks_build_vmh_dir)

incs  += -I$(bmarkdir)/../env -I$(bmarkdir)/common $(addprefix -I$(bmarkdir)/, $(bmarks))

include $(patsubst %, $(bmarkdir)/%/bmark.mk, $(bmarks))

#------------------------------------------------------------
# Build and run benchmarks on riscv simulator

bmarks_riscv_bin  = $(addsuffix .riscv, $(bmarks))
bmarks_riscv_dump = $(addsuffix .riscv.dump, $(bmarks))
bmarks_riscv_vmh = $(addsuffix .riscv.vmh, $(bmarks))

bmarks_defs   = -DPREALLOCATE=0 -DHOST_DEBUG=0
bmarks_cycles = 80000

$(bmarks_riscv_vmh): %.riscv.vmh: %.riscv
	@echo $(basename $<)
	@echo "@40" > $(bmarks_build_vmh_dir)/temp
	$(RISCV_ELF2HEX) --bit-width $(VMH_WIDTH) --input $(bmarks_build_bin_dir)/$< >> $(bmarks_build_vmh_dir)/temp
	python3 $(bmarkdir)/../trans_vmh.py $(bmarks_build_vmh_dir)/temp $(bmarks_build_vmh_dir)/$@

$(bmarks_riscv_dump): %.riscv.dump: %.riscv
	$(RISCV_OBJDUMP) $(bmarks_build_bin_dir)/$< > $(bmarks_build_dump_dir)/$@

%.o: %.c
	$(RISCV_GCC) $(RISCV_GCC_OPTS) $(bmarks_defs) \
	             -c $(incs) $< -o $(bmarks_build_obj_dir)/$@

%.o: %.S
	$(RISCV_GCC) $(RISCV_GCC_OPTS) $(bmarks_defs) -D__ASSEMBLY__=1 \
	             -c $(incs) $< -o $(bmarks_build_obj_dir)/$@

riscv: $(bmarks_build_bin_dir) $(bmarks_build_obj_dir) $(bmarks_build_dump_dir) $(bmarks_build_vmh_dir) $(bmarks_riscv_dump) $(bmarks_riscv_vmh)


#------------------------------------------------------------
# Build and run benchmarks on host machine

bmarks_host_bin = $(addsuffix .host, $(bmarks_host))

host: $(bmarks_build_bin_dir) $(bmarks_host_bin)


#------------------------------------------------------------
# Default
$(bmarks_build_bin_dir):
	mkdir -p $@

$(bmarks_build_obj_dir):
	mkdir -p $@

$(bmarks_build_dump_dir):
	mkdir -p $@

$(bmarks_build_vmh_dir):
	mkdir -p $@

all: riscv

# Clean up

clean:
	rm -rf $(bmarks_build_dir)

.PHONY: all clean riscv host


