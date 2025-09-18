# TikZ/PGF TeX Graphics

## Setup
```latex
\documentclass{article}
\usepackage{tikz}
\usetikzlibrary{arrows.meta,positioning,calc,patterns,decorations.pathmorphing}
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
```

## Basic Shapes
```latex
\begin{tikzpicture}
  % Circle and rectangle
  \draw (0,0) circle (1cm);
  \draw (2,0) rectangle (4,2);

  % Arrow
  \draw[->,thick] (0,0) -- (2,1) node[midway,above] {$v$};

  % Filled polygon
  \filldraw[fill=blue!20] (0,0) -- (1,0) -- (0.5,1) -- cycle;
\end{tikzpicture}
```

## Function Plotting
```latex
\begin{tikzpicture}
  \begin{axis}[
    xlabel=$x$, ylabel=$y$,
    domain=-2:2, samples=100,
    grid=major
  ]
    \addplot[blue,thick] {x^2};
    \addplot[red,thick] {sin(deg(x))};
    \legend{$y=x^2$, $y=\sin(x)$}
  \end{axis}
\end{tikzpicture}
```

## Flowchart
```latex
\begin{tikzpicture}[node distance=2cm]
  \node[draw,rectangle] (start) {Start};
  \node[draw,diamond,below of=start] (decision) {$x > 0$?};
  \node[draw,rectangle,left of=decision] (no) {Return 0};
  \node[draw,rectangle,right of=decision] (yes) {Return $x^2$};

  \draw[->] (start) -- (decision);
  \draw[->] (decision) -- node[above] {No} (no);
  \draw[->] (decision) -- node[above] {Yes} (yes);
\end{tikzpicture}
```

## NPL-FIM Export
```javascript
// Generate TikZ from NPL graph
const graph = npl.parseGraph("A→B→C; B→D");
const tikz = graph.toTikZ();
// Output: \node (A) {A}; \node (B) {B}; ...
```