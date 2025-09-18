# Digital Timing Diagrams

## Overview
Tools and formats for digital timing diagram generation. Protocol and signal visualization.

## Installation
```bash
# TimingAnalyzer
pip install timing-analyzer

# Tikz-timing (LaTeX)
tlmgr install tikz-timing

# Python timing
pip install timing-diagram
```

## Basic Example (tikz-timing)
```latex
\begin{tikztimingtable}
  Clock & 10{C} \\
  Data & 2D{Valid} 2U 3D{New} 3Z \\
  Enable & L H 6L H L \\
\end{tikztimingtable}
```

## Python Example
```python
from timing_diagram import TimingDiagram

td = TimingDiagram()
td.add_signal("CLK", "clock", period=2)
td.add_signal("DATA", "bus",
              values=["0x00", "0xFF", "0xAA"])
td.render()
```

## Strengths
- Protocol visualization
- Bus representations
- Timing relationships
- Multiple formats
- Annotations

## Limitations
- Tool fragmentation
- Format incompatibility
- Limited standardization
- Manual timing entry

## NPL-FIM Integration
```yaml
renderer: [tikz-timing, wavedrom, custom]
features: [bus, clock, annotations]
export: svg|pdf|png
```