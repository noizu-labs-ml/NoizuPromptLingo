# Lcapy

## Overview
Python package for linear circuit analysis and visualization. Symbolic circuit analysis with SymPy.

## Installation
```bash
pip install lcapy

# With plotting
pip install lcapy[plotting]

# Dependencies
pip install sympy matplotlib numpy
```

## Basic Example
```python
from lcapy import Circuit

cct = Circuit("""
V 1 0 dc 5
R 1 2 10k
C 2 0 100n
""")

# Analysis
H = cct.transfer(1, 0, 2, 0)
print(H)  # Transfer function

# Draw
cct.draw()
```

## Strengths
- Symbolic analysis
- AC/DC/transient analysis
- LaTeX equations
- Circuit drawing
- Transfer functions

## Limitations
- Linear circuits only
- No nonlinear components
- Limited component models
- Symbolic complexity grows

## NPL-FIM Integration
```yaml
renderer: lcapy
analysis: symbolic|numeric
output: latex|matplotlib
netlist: spice|lcapy
```