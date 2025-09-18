# CircuiTikZ

## Overview
LaTeX package for professional circuit diagrams using TikZ. Native LaTeX integration with publication-quality output.

## Installation
```bash
# TeX Live
tlmgr install circuitikz

# Ubuntu/Debian
apt-get install texlive-pictures

# Include in LaTeX
\usepackage{circuitikz}
```

## Basic Example
```latex
\begin{circuitikz}
  \draw (0,0) to[R=10k] (2,0)
        to[C=100n] (2,-2)
        to[short] (0,-2)
        to[V=5V] (0,0);
  \draw (2,0) to[short] (4,0)
        to[L=1m] (4,-2)
        to[short] (2,-2);
\end{circuitikz}
```

## Strengths
- Native LaTeX integration
- Publication-quality vector graphics
- Extensive component library
- Precise control over positioning
- Mathematical annotations

## Limitations
- LaTeX dependency
- Learning curve for TikZ
- Compilation time for complex circuits
- Not interactive

## NPL-FIM Integration
```yaml
renderer: circuitikz
output: pdf|svg
inline: latex_document
```