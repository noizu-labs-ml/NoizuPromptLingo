# Verilog Diagrams

## Overview
Tools for visualizing Verilog/SystemVerilog hardware descriptions. RTL to schematic conversion.

## Installation
```bash
# Yosys (synthesis)
apt-get install yosys

# Netlistsvg
npm install -g netlistsvg

# WaveDrom for timing
npm install -g wavedrom-cli

# Python tools
pip install pyverilog
```

## Basic Example
```bash
# Verilog to JSON
yosys -p "read_verilog design.v;
         proc; opt;
         write_json design.json"

# JSON to SVG
netlistsvg design.json -o design.svg
```

## Python Visualization
```python
from pyverilog.dataflow.dataflow_analyzer import *

analyzer = VerilogDataflowAnalyzer("top.v", "top")
analyzer.generate()
analyzer.draw_graph("output.svg")
```

## Strengths
- RTL visualization
- Hierarchical views
- Dataflow graphs
- State machines
- Automatic layout

## Limitations
- Complex designs cluttered
- Limited customization
- Tool chain complexity
- Synthesis required

## NPL-FIM Integration
```yaml
renderer: [yosys, netlistsvg, pyverilog]
input: verilog|systemverilog
output: svg|dot|json
features: [hierarchy, fsm, dataflow]
```