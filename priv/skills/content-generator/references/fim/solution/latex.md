# LaTeX Document System

## Setup
```bash
# Ubuntu/Debian
apt-get install texlive-full

# macOS
brew install --cask mactex

# Minimal installation
apt-get install texlive-latex-base texlive-latex-extra
```

## Basic Document
```latex
\documentclass{article}
\usepackage{amsmath}
\begin{document}

\section{Equations}
The quadratic formula:
\[ x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a} \]

Inline math: $E = mc^2$

\section{Matrix}
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6
\end{bmatrix}

\end{document}
```

## Compilation
```bash
pdflatex document.tex
# Or with bibliography
pdflatex document.tex
bibtex document
pdflatex document.tex
pdflatex document.tex
```

## NPL-FIM Integration
```typescript
// Generate LaTeX from NPL
const equation = npl.parse("∫₀^∞ e^(-x²) dx");
const latex = equation.toLaTeX(); // "\int_0^\infty e^{-x^2} dx"
```

## Common Packages
- `amsmath`: Advanced math
- `tikz`: Graphics
- `listings`: Code blocks
- `hyperref`: Links
- `graphicx`: Images