# PySpice

## Overview
Python interface to SPICE circuit simulators. Bridges Python with Ngspice/Xyce for circuit simulation.

## Installation
```bash
# PySpice
pip install PySpice

# Ngspice backend
apt-get install ngspice
# or
brew install ngspice

# Windows
# Download from ngspice.sourceforge.net
```

## Basic Example
```python
from PySpice.Spice.Netlist import Circuit
from PySpice.Unit import *

circuit = Circuit('RC Filter')
circuit.V('input', 1, circuit.gnd, 10@u_V)
circuit.R(1, 1, 2, 1@u_kΩ)
circuit.C(1, 2, circuit.gnd, 1@u_uF)

simulator = circuit.simulator()
analysis = simulator.transient(step_time=1@u_us,
                              end_time=100@u_us)
```

## Strengths
- Full SPICE capabilities
- Python integration
- Unit-aware calculations
- Plotting with matplotlib
- Parametric analysis

## Limitations
- Ngspice installation required
- SPICE syntax knowledge needed
- Convergence issues
- Limited component library

## NPL-FIM Integration
```yaml
renderer: pyspice
simulator: ngspice|xyce
analysis: [dc, ac, transient, noise]
units: enabled
```