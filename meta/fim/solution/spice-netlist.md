# SPICE Netlist

## Overview
Circuit description format for SPICE simulators. Industry-standard netlist representation.

## Installation
```bash
# Ngspice
apt-get install ngspice

# LTspice (GUI)
# Download from analog.com

# Python tools
pip install spicelib
pip install PyLTSpice
```

## Basic Example
```spice
* RC Low-pass Filter
.title RC Filter

V1 in 0 DC 5 AC 1
R1 in out 1k
C1 out 0 100n

.ac dec 10 1 100k
.tran 0 10m 0 10u
.end
```

## Subcircuit Example
```spice
.subckt opamp in+ in- out vcc vee
* Ideal op-amp model
Rin in+ in- 10Meg
Eout out 0 in+ in- 1e6
.ends opamp
```

## Strengths
- Industry standard
- All simulators support
- Hierarchical design
- Parameter sweeps
- Monte Carlo analysis

## Limitations
- Text-based only
- No schematic info
- Error-prone syntax
- Manual node numbering

## NPL-FIM Integration
```yaml
format: spice3
simulator: [ngspice, ltspice, hspice]
analysis: [dc, ac, tran, noise, monte]
includes: models/*.lib
```