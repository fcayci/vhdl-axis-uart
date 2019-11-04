# author: Furkan Cayci, 2018
# description:
#   add ghdl to your PATH for simulation
#   add gtkwave to your PATH for displayin the waveform
#   run with make simulate ARCHNAME=tb_xxx STOPTIME=1us

CC = ghdl
SIM = gtkwave
WORKDIR = debug
QUIET = @

ARCHNAME?= tb_uart
STOPTIME= 100ms

VHDL_SOURCES = $(wildcard rtl/*.vhd)
#VHDL_SOURCES += $(wildcard impl/*.vhd)
TBS = $(wildcard sim/tb_*.vhd)
TB = sim/$(ARCHNAME).vhd

CFLAGS += --std=08 # enable ieee 2008 standard
CFLAGS += --warn-binding
CFLAGS += --warn-no-library # turn off warning on design replace with same name

.PHONY: all
all: check analyze
	@echo ">>> completed..."

.PHONY: check
check:
	@echo ">>> check syntax on all designs..."
	$(QUIET)$(CC) -s $(CFLAGS) $(VHDL_SOURCES) $(TBS)

.PHONY: analyze
analyze:
	@echo ">>> analyzing designs..."
	$(QUIET)mkdir -p $(WORKDIR)
	$(QUIET)$(CC) -a $(CFLAGS) --workdir=$(WORKDIR) $(VHDL_SOURCES) $(TBS)

.PHONY: simulate
simulate: analyze
	@echo ">>> simulating design:" $(TB)
	$(QUIET)$(CC) --elab-run $(CFLAGS) --workdir=$(WORKDIR) \
		-o $(WORKDIR)/$(ARCHNAME).bin $(ARCHNAME) \
		--vcd=$(WORKDIR)/$(ARCHNAME).vcd --stop-time=$(STOPTIME)
	@echo ">>> showing waveform for:" $(TB)
	$(QUIET)$(SIM) $(WORKDIR)/$(ARCHNAME).vcd

.PHONY: clean
clean:
	@echo "cleaning design..."
	$(QUIET)ghdl --remove --workdir=$(WORKDIR)
	$(QUIET)rm -f $(WORKDIR)/*
	$(QUIET)rm -rf $(WORKDIR)
