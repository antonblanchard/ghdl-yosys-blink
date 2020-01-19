# ghdl-yosys-blink

Blink an LED on an FPGA using ghdl, yosys and nextpnr - a completely
Open Source VHDL synthesis flow.

# Supported Hardware

Right now only Lattice ECP5 boards are supported, but you should be able
to use anything that yosys and nextpnr supports. I've personally tested
the Lattice ECP5-EVN board and the OrangeCrab.

## Prerequisites

You can install the latest versions of GHDL, ghdlsynth-beta, yosys, prjtrellis
and nextpnr if you want, but thanks to the GHDL Docker project we have Docker
images for everything!

It also works fine with podman if you prefer that to Docker.

## Building

```
make
make prog
```
