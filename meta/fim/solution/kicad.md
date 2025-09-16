# KiCad

## Overview
Professional open-source EDA suite for schematic capture and PCB design. Industry-standard tool.

## Installation
```bash
# Ubuntu/Debian
apt-get install kicad

# macOS
brew install --cask kicad

# Windows
# Download from kicad.org
```

## Project Structure
```
project/
├── project.kicad_pro
├── project.kicad_sch
├── project.kicad_pcb
└── project-cache.lib
```

## Python Scripting
```python
import pcbnew

board = pcbnew.LoadBoard("design.kicad_pcb")
for module in board.GetModules():
    print(module.GetReference())
```

## Strengths
- Professional-grade
- 3D visualization
- Extensive libraries
- Python scripting
- Gerber generation

## Limitations
- Steep learning curve
- Complex for simple tasks
- Large installation
- No built-in simulation

## NPL-FIM Integration
```yaml
renderer: kicad
format: kicad_v6
export: [gerber, step, vrml, svg]
scripting: python
```