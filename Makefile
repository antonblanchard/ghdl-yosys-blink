# Use local tools
#GHDL      = ghdl
#GHDLSYNTH = ghdl.so
#YOSYS     = yosys
#NEXTPNR   = nextpnr-ecp5
#ECPPACK   = ecppack

# Use Docker images
DOCKER=docker
#DOCKER=podman
PWD = $(shell pwd)
DOCKER_GHDL    = $(DOCKER) run --rm -t -i -v $(PWD):/src -w /src ghdl/synth:beta
DOCKER_NEXTPNR = $(DOCKER) run --rm -t -i -v $(PWD):/src -w /src ghdl/synth:nextpnr-ecp5
DOCKER_TRELLIS = $(DOCKER) run --rm -t -i -v $(PWD):/src -w /src ghdl/synth:trellis
GHDL           = ghdl
GHDLSYNTH      = /usr/local/share/yosys/plugins/ghdl.so
YOSYS          = yosys
NEXTPNR        = nextpnr-ecp5
ECPPACK        = ecppack


# OrangeCrab with ECP85
LPF=constraints/orange-crab.lpf
PACKAGE=CSFBGA285
NEXTPNRFLAGS=--um5g-85k --freq 50
OPENOCD_JTAG_CONFIG=openocd/olimex-arm-usb-tiny-h.cfg
OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-85F.cfg

# ECP5-EVN
#LPF=constraints/ecp5-evn.lpf
#PACKAGE=CABGA381
#NEXTPNRFLAGS=--um5g-85k --freq 50
#OPENOCD_JTAG_CONFIG=openocd/ecp5-evn.cfg
#OPENOCD_DEVICE_CONFIG=openocd/LFE5UM5G-85F.cfg

all: vhdl_blink.bit

vhdl_blink.json: vhdl_blink.vhdl
	$(DOCKER_GHDL) $(GHDL) -a --std=08 $<
	$(DOCKER_GHDL) $(YOSYS) -m $(GHDLSYNTH) -p "ghdl --std=08 toplevel; synth_ecp5 -json $@ -top toplevel"

vhdl_blink_out.config: vhdl_blink.json $(LPF)
	$(DOCKER_NEXTPNR) $(NEXTPNR) --json $< --lpf $(LPF) --textcfg $@ $(NEXTPNRFLAGS) --package $(PACKAGE)

vhdl_blink.bit: vhdl_blink_out.config
	$(DOCKER_TRELLIS) $(ECPPACK) --svf vhdl_blink.svf $< $@

%.svf: %.bit

prog: vhdl_blink.svf
	openocd -f $(OPENOCD_JTAG_CONFIG) -f $(OPENOCD_DEVICE_CONFIG) -c "transport select jtag; init; svf $<; exit"

clean:
	@rm -f work-obj08.cf *.bit *.json *.svf *.config

.PHONY: clean prog
.PRECIOUS: vhdl_blink.json vhdl_blink_out.config vhdl_blink.bit
