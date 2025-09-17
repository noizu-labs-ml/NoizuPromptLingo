# Mathematical and Scientific Documents with LaTeX

Professional typesetting system for academic papers, research publications, mathematical formulas, scientific reports, thesis documents, and technical documentation with publication-quality output.

## Quick Start Templates

### Basic Research Paper Template
```latex
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb,amsfonts,amsthm}
\usepackage{graphicx,booktabs,array}
\usepackage{geometry}
\usepackage{natbib}
\usepackage{hyperref}
\usepackage{cleveref}

\geometry{margin=1in}
\bibliographystyle{plainnat}

\title{Mathematical Analysis of Complex Systems}
\author{Dr. Jane Smith\thanks{Department of Mathematics, University College}}
\date{\today}

\begin{document}
\maketitle

\begin{abstract}
This paper presents a comprehensive mathematical analysis of complex dynamical systems, focusing on stability criteria and bifurcation phenomena. We develop novel theoretical frameworks and provide rigorous proofs for key stability conditions.
\end{abstract}

\section{Introduction}
Mathematical modeling of complex systems requires sophisticated analytical tools and rigorous theoretical foundations. In this work, we establish fundamental principles for analyzing nonlinear dynamics.

\section{Mathematical Framework}
\subsection{Dynamical Systems Theory}
Consider a dynamical system described by the differential equation:
\begin{equation}\label{eq:dynamics}
\frac{dx}{dt} = f(x,t)
\end{equation}
where $x \in \mathbb{R}^n$ represents the state vector and $f: \mathbb{R}^n \times \mathbb{R} \to \mathbb{R}^n$ is a smooth vector field.

\subsection{Stability Analysis}
The Lyapunov stability criterion requires the existence of a function $V(x)$ such that:
\begin{align}
V(x) &> 0 \quad \forall x \neq 0 \label{eq:positive}\\
\dot{V}(x) &\leq 0 \quad \forall x \label{eq:derivative}
\end{align}

\section{Numerical Results}
\begin{table}[htbp]
\centering
\begin{tabular}{@{}lccc@{}}
\toprule
System & Stability Index & Convergence Rate & Error Bound \\
\midrule
Linear & 0.95 & $O(h^2)$ & $10^{-6}$ \\
Nonlinear & 0.87 & $O(h^{3/2})$ & $10^{-4}$ \\
Chaotic & 0.42 & $O(h)$ & $10^{-2}$ \\
\bottomrule
\end{tabular}
\caption{Comparative analysis of system stability metrics}
\label{tab:stability}
\end{table}

\section{Conclusions}
Our analysis demonstrates that the proposed theoretical framework provides robust tools for understanding complex dynamical behavior.

\bibliography{references}
\end{document}
```

### Physics Research Paper Template
```latex
\documentclass[aps,prl,twocolumn,showpacs]{revtex4-2}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{dcolumn}
\usepackage{bm}
\usepackage{hyperref}

\begin{document}

\title{Quantum Mechanical Analysis of Semiconductor Nanostructures}
\author{Prof. Robert Johnson}
\affiliation{Department of Physics, Research University}
\author{Dr. Maria Garcia}
\affiliation{Institute for Quantum Materials}

\date{\today}

\begin{abstract}
We present a comprehensive quantum mechanical study of electronic properties in semiconductor nanostructures. Using density functional theory calculations, we demonstrate novel quantum confinement effects and their implications for optoelectronic applications.
\end{abstract}

\pacs{73.21.La, 78.67.Hc, 71.15.Mb}

\maketitle

\section{Introduction}
Quantum confinement in semiconductor nanostructures leads to size-dependent electronic and optical properties that differ significantly from bulk materials.

\section{Theoretical Framework}
The electronic structure is described by the time-independent Schrödinger equation:
\begin{equation}
\hat{H}\psi = E\psi
\end{equation}
where the Hamiltonian includes kinetic energy, potential energy, and exchange-correlation terms:
\begin{equation}
\hat{H} = -\frac{\hbar^2}{2m}\nabla^2 + V_{ext}(\mathbf{r}) + V_{xc}[\rho(\mathbf{r})]
\end{equation}

For a quantum well of width $L$, the energy levels are given by:
\begin{equation}
E_n = \frac{n^2\pi^2\hbar^2}{2m^*L^2} + E_g
\end{equation}
where $m^*$ is the effective mass and $E_g$ is the band gap.

\section{Computational Methods}
Electronic structure calculations were performed using the Vienna Ab initio Simulation Package (VASP) with projector-augmented wave pseudopotentials. The exchange-correlation functional was treated within the generalized gradient approximation (GGA-PBE).

\section{Results and Discussion}
\begin{figure}[htb]
\includegraphics[width=\columnwidth]{bandstructure.pdf}
\caption{Electronic band structure showing quantum confinement effects. The discrete energy levels demonstrate strong size dependence.}
\label{fig:bands}
\end{figure}

The calculated band gaps show excellent agreement with experimental measurements, with a mean absolute error of 0.05 eV across all studied systems.

\section{Conclusions}
Our quantum mechanical analysis provides fundamental insights into nanostructure electronics and establishes design principles for next-generation optoelectronic devices.

\begin{acknowledgments}
This work was supported by the National Science Foundation under Grant No. DMR-12345678.
\end{acknowledgments}

\bibliography{quantum_references}

\end{document}
```

### Mathematical Thesis Template
```latex
\documentclass[12pt,oneside]{book}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath,amssymb,amsfonts,amsthm}
\usepackage{mathtools}
\usepackage{geometry}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{tocloft}
\usepackage{graphicx}
\usepackage{booktabs}
\usepackage{algorithm}
\usepackage{algorithmic}
\usepackage{natbib}
\usepackage{hyperref}
\usepackage{cleveref}

\geometry{
    a4paper,
    left=1.5in,
    right=1in,
    top=1in,
    bottom=1in
}

% Theorem environments
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}

% Custom commands
\newcommand{\R}{\mathbb{R}}
\newcommand{\C}{\mathbb{C}}
\newcommand{\N}{\mathbb{N}}
\newcommand{\Z}{\mathbb{Z}}
\newcommand{\norm}[1]{\left\|#1\right\|}
\newcommand{\abs}[1]{\left|#1\right|}

\title{Nonlinear Partial Differential Equations: \\
Existence and Uniqueness Theory}
\author{Sarah Elizabeth Williams}
\date{June 2024}

\begin{document}

\frontmatter
\maketitle

\tableofcontents
\listoffigures
\listoftables

\chapter{Abstract}
This thesis develops a comprehensive theory for the existence and uniqueness of solutions to nonlinear partial differential equations of elliptic and parabolic type. We establish novel regularity results and provide constructive algorithms for numerical approximation.

\chapter{Acknowledgments}
I express my deepest gratitude to my advisor, Professor John Davis, for his invaluable guidance and mentorship throughout this research.

\mainmatter

\chapter{Introduction}

\section{Background and Motivation}
Nonlinear partial differential equations arise naturally in many areas of mathematical physics, engineering, and applied mathematics. The study of existence and uniqueness of solutions is fundamental to understanding the mathematical structure of these equations.

\section{Literature Review}
The classical theory of PDEs, as developed by Hilbert, Sobolev, and others, provides the foundation for modern analysis of partial differential equations.

\section{Main Contributions}
This thesis makes the following novel contributions:
\begin{enumerate}
\item A new existence theorem for quasilinear elliptic equations
\item Improved regularity estimates for parabolic systems
\item Efficient numerical algorithms with proven convergence rates
\end{enumerate}

\chapter{Mathematical Preliminaries}

\section{Function Spaces}
\begin{definition}[Sobolev Space]
For $p \geq 1$ and integer $k \geq 0$, the Sobolev space $W^{k,p}(\Omega)$ is defined as:
\begin{equation}
W^{k,p}(\Omega) = \{u \in L^p(\Omega) : D^\alpha u \in L^p(\Omega), \quad |\alpha| \leq k\}
\end{equation}
equipped with the norm:
\begin{equation}
\norm{u}_{W^{k,p}} = \left(\sum_{|\alpha| \leq k} \norm{D^\alpha u}_{L^p}^p\right)^{1/p}
\end{equation}
\end{definition}

\section{Weak Solutions}
\begin{definition}[Weak Solution]
A function $u \in H^1(\Omega)$ is called a weak solution of the boundary value problem:
\begin{align}
-\Delta u + f(u) &= g \quad \text{in } \Omega \\
u &= 0 \quad \text{on } \partial\Omega
\end{align}
if for all $v \in H_0^1(\Omega)$:
\begin{equation}
\int_\Omega \nabla u \cdot \nabla v \, dx + \int_\Omega f(u)v \, dx = \int_\Omega gv \, dx
\end{equation}
\end{definition}

\chapter{Existence Theory}

\section{Linear Elliptic Equations}
We begin with the classical Lax-Milgram theorem for linear elliptic boundary value problems.

\begin{theorem}[Lax-Milgram]
Let $V$ be a Hilbert space and $a: V \times V \to \R$ be a bilinear form that is:
\begin{enumerate}
\item Continuous: $|a(u,v)| \leq C\norm{u}_V\norm{v}_V$
\item Coercive: $a(u,u) \geq \alpha\norm{u}_V^2$ for some $\alpha > 0$
\end{enumerate}
Then for any $F \in V^*$, there exists a unique $u \in V$ such that $a(u,v) = F(v)$ for all $v \in V$.
\end{theorem}

\section{Nonlinear Elliptic Equations}
For nonlinear problems, we employ fixed-point arguments and monotonicity methods.

\begin{theorem}[Main Existence Result]
Consider the nonlinear elliptic equation:
\begin{align}
-\div(A(x,u,\nabla u)) + B(x,u,\nabla u) &= f \quad \text{in } \Omega \\
u &= 0 \quad \text{on } \partial\Omega
\end{align}
Assume the structure conditions:
\begin{align}
A(x,s,\xi) \cdot \xi &\geq \alpha|\xi|^p \\
|A(x,s,\xi)| &\leq \beta(1 + |s|^{p-1} + |\xi|^{p-1}) \\
B(x,s,\xi)s &\geq -\gamma|s|^p - C
\end{align}
Then there exists a weak solution $u \in W_0^{1,p}(\Omega)$.
\end{theorem}

\chapter{Uniqueness and Regularity}

\section{Comparison Principles}
Uniqueness often follows from comparison principles for elliptic and parabolic equations.

\section{Regularity Theory}
Higher regularity of solutions requires careful analysis of the nonlinear structure.

\chapter{Numerical Methods}

\section{Finite Element Discretization}
We discretize using conforming finite element spaces $V_h \subset H_0^1(\Omega)$.

\begin{algorithm}
\caption{Newton's Method for Nonlinear PDEs}
\begin{algorithmic}
\STATE Initialize $u_h^0 \in V_h$
\FOR{$k = 0, 1, 2, \ldots$}
\STATE Solve: Find $\delta u_h \in V_h$ such that
\STATE $J(u_h^k)[\delta u_h, v_h] = -R(u_h^k)[v_h]$ for all $v_h \in V_h$
\STATE Update: $u_h^{k+1} = u_h^k + \delta u_h$
\STATE Check convergence: if $\norm{\delta u_h} < \text{tol}$, stop
\ENDFOR
\end{algorithmic}
\end{algorithm}

\section{Error Analysis}
\begin{theorem}[Convergence Rate]
Under appropriate regularity assumptions, the finite element error satisfies:
\begin{equation}
\norm{u - u_h}_{H^1} \leq Ch^{\min(k,s-1)}\norm{u}_{H^s}
\end{equation}
where $h$ is the mesh size, $k$ is the polynomial degree, and $s$ is the regularity index.
\end{theorem}

\chapter{Applications}

\section{Reaction-Diffusion Equations}
Consider the semilinear equation:
\begin{equation}
u_t - \Delta u + f(u) = 0
\end{equation}
with applications to population dynamics and chemical reactions.

\section{Minimal Surface Equations}
The minimal surface equation in divergence form:
\begin{equation}
\div\left(\frac{\nabla u}{\sqrt{1 + |\nabla u|^2}}\right) = 0
\end{equation}
models surfaces of minimal area.

\chapter{Conclusions and Future Work}

\section{Summary of Results}
This thesis has established existence and uniqueness theory for a broad class of nonlinear PDEs, with particular emphasis on computational aspects.

\section{Open Problems}
Several interesting questions remain open:
\begin{enumerate}
\item Extension to systems of equations
\item Optimal regularity in non-smooth domains
\item Adaptive mesh refinement strategies
\end{enumerate}

\backmatter

\bibliographystyle{amsplain}
\bibliography{thesis_references}

\appendix
\chapter{Technical Lemmas}
This appendix contains detailed proofs of technical results used in the main text.

\end{document}
```

## Complete Package Requirements

### Essential LaTeX Packages
```latex
% Core mathematical packages
\usepackage{amsmath}        % Enhanced math environments
\usepackage{amssymb}        % Mathematical symbols
\usepackage{amsfonts}       % Mathematical fonts
\usepackage{amsthm}         % Theorem environments
\usepackage{mathtools}      % Extension of amsmath

% Advanced mathematical packages
\usepackage{mathrsfs}       % Script fonts (\mathscr)
\usepackage{dsfont}         % Double-struck fonts
\usepackage{bbm}           % Blackboard bold numbers
\usepackage{cancel}         % Cancel terms in equations
\usepackage{xfrac}         % Flexible fractions

% Scientific notation and units
\usepackage{siunitx}        % SI units and scientific notation
\usepackage{mhchem}         % Chemical formulas and reactions
\usepackage{physics}        % Physics notation shortcuts

% Tables and figures
\usepackage{booktabs}       % Professional tables
\usepackage{array}          % Extended array and tabular
\usepackage{longtable}      % Multi-page tables
\usepackage{graphicx}       % Include graphics
\usepackage{subfig}         % Subfigures
\usepackage{tikz}          % Programming graphics
\usepackage{pgfplots}      % Function plotting

% Bibliography and citations
\usepackage{natbib}         % Natural bibliography
\usepackage{biblatex}       % Advanced bibliography
\usepackage{cite}           % Citation management

% Cross-referencing
\usepackage{hyperref}       % Hyperlinks and PDF features
\usepackage{cleveref}       % Intelligent cross-referencing
\usepackage{nameref}        % Reference by name

% Document formatting
\usepackage{geometry}       % Page layout
\usepackage{fancyhdr}       % Headers and footers
\usepackage{titlesec}       % Section formatting
\usepackage{enumitem}       % List formatting
\usepackage{multicol}       % Multiple columns
```

### Algorithm and Code Packages
```latex
% Algorithms
\usepackage{algorithm}      % Algorithm floats
\usepackage{algorithmic}    % Algorithm typesetting
\usepackage{algorithmicx}   % Extended algorithmic
\usepackage{algpseudocode}  % Pseudocode formatting

% Code listings
\usepackage{listings}       % Source code formatting
\usepackage{minted}         % Syntax highlighting
\usepackage{verbatim}       % Verbatim text

% Configuration for code
\lstset{
    language=Python,
    basicstyle=\ttfamily\small,
    keywordstyle=\color{blue},
    commentstyle=\color{gray},
    numbers=left,
    numberstyle=\tiny,
    frame=single,
    breaklines=true
}
```

## Mathematical Notation Guide

### Basic Mathematical Structures
```latex
% Sets and spaces
\mathbb{R}          % Real numbers
\mathbb{C}          % Complex numbers
\mathbb{N}          % Natural numbers
\mathbb{Z}          % Integers
\mathbb{Q}          % Rational numbers
\mathcal{H}         % Hilbert space
\mathfrak{g}        % Lie algebra

% Operators and functions
\partial            % Partial derivative
\nabla              % Gradient/nabla
\Delta              % Laplacian
\div                % Divergence
\curl               % Curl
\int_a^b           % Definite integral
\oint              % Contour integral
\sum_{i=1}^n       % Summation
\prod_{i=1}^n      % Product

% Greek letters
\alpha, \beta, \gamma, \delta
\epsilon, \varepsilon
\theta, \vartheta
\phi, \varphi
\lambda, \mu, \nu
\sigma, \tau
\omega, \Omega
```

### Advanced Mathematical Constructs
```latex
% Fractions and binomials
\frac{a}{b}                % Standard fraction
\dfrac{a}{b}              % Display-style fraction
\tfrac{a}{b}              % Text-style fraction
\binom{n}{k}              % Binomial coefficient
\genfrac{(}{)}{0pt}{}{n}{k} % Custom fraction

% Matrices and vectors
\begin{pmatrix}
a & b \\
c & d
\end{pmatrix}

\begin{bmatrix}
x_1 \\ x_2 \\ \vdots \\ x_n
\end{bmatrix}

\begin{vmatrix}
\cos\theta & -\sin\theta \\
\sin\theta & \cos\theta
\end{vmatrix}

% Vector notation
\vec{v}                   % Vector arrow
\mathbf{v}               % Bold vector
\boldsymbol{\phi}        % Bold Greek
\hat{n}                  % Unit vector
\tilde{x}                % Tilde accent
```

### Equation Environments
```latex
% Single equation with number
\begin{equation}
E = mc^2
\end{equation}

% Single equation without number
\begin{equation*}
F = ma
\end{equation*}

% Multiple aligned equations
\begin{align}
x &= a + b \\
y &= c + d \\
z &= e + f
\end{align}

% Split long equation
\begin{split}
f(x) &= (x+1)(x+2)(x+3) \\
     &= x^3 + 6x^2 + 11x + 6
\end{split}

% Gather equations without alignment
\begin{gather}
x = a + b \\
y = c + d
\end{gather}

% Cases/piecewise functions
f(x) = \begin{cases}
x^2 & \text{if } x \geq 0 \\
-x^2 & \text{if } x < 0
\end{cases}
```

## Scientific Document Types

### Research Article Template
```latex
\documentclass[11pt,twocolumn]{article}
\usepackage[margin=0.75in]{geometry}
\usepackage{amsmath,amssymb,graphicx}
\usepackage{natbib}
\usepackage{hyperref}

\title{Title of Research Article}
\author{Author One$^1$, Author Two$^{1,2}$}
\date{}

\begin{document}
\maketitle

\begin{abstract}
Research abstract summarizing methodology, results, and conclusions in 150-250 words.
\end{abstract}

\section{Introduction}
Background, motivation, and objectives.

\section{Methods}
Detailed methodology and experimental procedures.

\section{Results}
Presentation of findings with figures and tables.

\section{Discussion}
Interpretation of results and comparison with literature.

\section{Conclusions}
Summary of main findings and future work.

\section*{Acknowledgments}
Funding sources and acknowledgments.

\bibliographystyle{plainnat}
\bibliography{references}
\end{document}
```

### Conference Paper Template
```latex
\documentclass[conference]{IEEEtran}
\usepackage{amsmath,graphicx}
\usepackage{cite}

\title{Conference Paper Title}
\author{\IEEEauthorblockN{First Author}
\IEEEauthorblockA{Department\\
University\\
Email: first@university.edu}
\and
\IEEEauthorblockN{Second Author}
\IEEEauthorblockA{Institute\\
Organization\\
Email: second@institute.org}}

\begin{document}
\maketitle

\begin{abstract}
Conference abstract in IEEE format.
\end{abstract}

\begin{IEEEkeywords}
keyword1, keyword2, keyword3
\end{IEEEkeywords}

\section{Introduction}
\IEEEPARstart{T}{his} is the first paragraph...

\section{Methodology}
Technical approach and implementation.

\section{Results}
Experimental results and analysis.

\section{Conclusion}
Summary and future directions.

\begin{thebibliography}{1}
\bibitem{ref1}
Author, "Title," Journal, vol. X, no. Y, pp. Z-W, Year.
\end{thebibliography}

\end{document}
```

### Technical Report Template
```latex
\documentclass[12pt]{report}
\usepackage[margin=1in]{geometry}
\usepackage{amsmath,graphicx,booktabs}
\usepackage{fancyhdr}
\usepackage{hyperref}

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\leftmark}
\fancyhead[R]{\thepage}

\title{Technical Report Title}
\author{Research Team}
\date{\today}

\begin{document}
\maketitle

\tableofcontents
\listoffigures
\listoftables

\chapter{Executive Summary}
High-level overview of the report.

\chapter{Introduction}
Background and objectives.

\chapter{Technical Approach}
Detailed methodology and implementation.

\chapter{Results and Analysis}
Findings and interpretation.

\chapter{Conclusions and Recommendations}
Summary and next steps.

\appendix
\chapter{Detailed Calculations}
Supporting mathematical derivations.

\end{document}
```

## Advanced Mathematical Features

### Custom Theorem Environments
```latex
\usepackage{amsthm}

% Define theorem styles
\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}

\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{example}[theorem]{Example}
\newtheorem{exercise}[theorem]{Exercise}

\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}
\newtheorem{note}[theorem]{Note}

% Usage
\begin{theorem}[Fundamental Theorem of Calculus]
If $f$ is continuous on $[a,b]$ and $F$ is an antiderivative of $f$, then:
\[\int_a^b f(x)\,dx = F(b) - F(a)\]
\end{theorem}

\begin{proof}
The proof follows from the definition of the derivative...
\end{proof}
```

### Chemical Formulas and Reactions
```latex
\usepackage{mhchem}

% Chemical formulas
\ce{H2O}                  % Water
\ce{CO2}                  % Carbon dioxide
\ce{C6H12O6}             % Glucose
\ce{^{14}C}              % Carbon-14 isotope
\ce{Fe^2+}               % Iron(II) ion

% Chemical reactions
\ce{2H2 + O2 -> 2H2O}
\ce{CH4 + 2O2 -> CO2 + 2H2O}

% Complex reactions with states
\ce{CaCO3(s) -> CaO(s) + CO2(g)}
\ce{Zn^2+ + 2e- -> Zn(s)}

% Equilibrium reactions
\ce{N2 + 3H2 <=> 2NH3}
\ce{A + B <=>> C + D}
```

### Physics Notation
```latex
\usepackage{physics}

% Derivatives
\dv{x}                   % d/dx
\dv{f}{x}               % df/dx
\dv[2]{f}{x}            % d²f/dx²
\pdv{f}{x}              % ∂f/∂x
\pdv{f}{x}{y}           % ∂²f/∂x∂y

% Vector operations
\grad                   % Gradient
\div                    % Divergence
\curl                   % Curl
\laplacian              % Laplacian

% Brackets and norms
\abs{x}                 % |x|
\norm{v}                % ||v||
\braket{a}{b}           % ⟨a|b⟩
\expectationvalue{A}    % ⟨A⟩

% Quantum mechanics
\ket{\psi}              % |ψ⟩
\bra{\phi}              % ⟨φ|
\braket{\phi}{\psi}     % ⟨φ|ψ⟩
```

### SI Units and Measurements
```latex
\usepackage{siunitx}

% Basic units
\SI{299792458}{\meter\per\second}     % Speed of light
\SI{9.81}{\meter\per\second\squared}  % Acceleration
\SI{1.602e-19}{\coulomb}              % Elementary charge

% Temperature
\SI{298.15}{\kelvin}
\SI{25}{\celsius}
\SI{77}{\fahrenheit}

% Ranges and uncertainties
\SIrange{10}{20}{\meter}              % 10 m to 20 m
\SI{1.23(4)}{\meter}                  % 1.23 ± 0.04 m
\SI{1.23 \pm 0.04}{\meter}           % Explicit uncertainty

% Scientific notation
\num{1.23e-4}                         % 1.23 × 10⁻⁴
\num{6.022e23}                        % Avogadro's number

% Angles
\ang{45}                              % 45°
\ang{30;15}                           % 30°15'
\ang{30;15;30}                        % 30°15'30"
```

## Graphics and Visualization

### TikZ Graphics for Mathematical Diagrams
```latex
\usepackage{tikz}
\usetikzlibrary{arrows,shapes,positioning}

% Function plotting
\begin{tikzpicture}
\begin{axis}[
    axis lines = left,
    xlabel = $x$,
    ylabel = {$f(x) = x^2$},
]
\addplot [
    domain=-3:3,
    samples=100,
    color=red,
]
{x^2};
\end{axis}
\end{tikzpicture}

% Geometric diagrams
\begin{tikzpicture}
\draw (0,0) circle (2cm);
\draw (-2,0) -- (2,0);
\draw (0,-2) -- (0,2);
\node at (1.4,1.4) {$r$};
\draw[->] (0,0) -- (1.4,1.4);
\end{tikzpicture}

% Flow charts
\begin{tikzpicture}[node distance=2cm]
\node (start) [startstop] {Start};
\node (input) [io, below of=start] {Input data};
\node (process) [process, below of=input] {Process calculation};
\node (output) [io, below of=process] {Output result};
\node (stop) [startstop, below of=output] {Stop};

\draw [arrow] (start) -- (input);
\draw [arrow] (input) -- (process);
\draw [arrow] (process) -- (output);
\draw [arrow] (output) -- (stop);
\end{tikzpicture}
```

### PGFPlots for Data Visualization
```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

% Line plot
\begin{tikzpicture}
\begin{axis}[
    xlabel={Time (s)},
    ylabel={Amplitude},
    legend pos=north west,
]
\addplot table {
x  y
0  0
1  1
2  4
3  9
4  16
};
\addlegendentry{$y = x^2$}
\end{axis}
\end{tikzpicture}

% Bar chart
\begin{tikzpicture}
\begin{axis}[
    ybar,
    xlabel={Category},
    ylabel={Value},
    symbolic x coords={A,B,C,D},
    xtick=data,
]
\addplot coordinates {
    (A,10) (B,15) (C,8) (D,12)
};
\end{axis}
\end{tikzpicture}

% 3D surface plot
\begin{tikzpicture}
\begin{axis}[
    3d box,
    xlabel={$x$},
    ylabel={$y$},
    zlabel={$z$},
]
\addplot3[surf,samples=20] {x^2 + y^2};
\end{axis}
\end{tikzpicture}
```

## Table Formatting

### Professional Scientific Tables
```latex
\usepackage{booktabs,array,multirow}

% Basic professional table
\begin{table}[htbp]
\centering
\begin{tabular}{@{}lccr@{}}
\toprule
Parameter & Symbol & Value & Units \\
\midrule
Temperature & $T$ & 298.15 & K \\
Pressure & $P$ & 1.013 & bar \\
Volume & $V$ & 22.4 & L \\
\bottomrule
\end{tabular}
\caption{Standard conditions for gas measurements}
\label{tab:conditions}
\end{table}

% Complex table with multirow and multicolumn
\begin{table}[htbp]
\centering
\begin{tabular}{@{}lcccc@{}}
\toprule
\multirow{2}{*}{Material} & \multicolumn{2}{c}{Mechanical Properties} & \multicolumn{2}{c}{Thermal Properties} \\
\cmidrule(lr){2-3} \cmidrule(lr){4-5}
& Modulus (GPa) & Strength (MPa) & Conductivity (W/mK) & Expansion (10⁻⁶/K) \\
\midrule
Steel & 200 & 400 & 50 & 12 \\
Aluminum & 70 & 250 & 237 & 23 \\
Titanium & 110 & 900 & 22 & 8.6 \\
\bottomrule
\end{tabular}
\caption{Material properties comparison}
\label{tab:materials}
\end{table}

% Long table spanning multiple pages
\begin{longtable}{@{}lccc@{}}
\caption{Comprehensive experimental data} \label{tab:longdata} \\
\toprule
Sample & Temperature & Pressure & Result \\
\midrule
\endfirsthead

\multicolumn{4}{c}{\tablename\ \thetable\ -- \textit{Continued from previous page}} \\
\toprule
Sample & Temperature & Pressure & Result \\
\midrule
\endhead

\midrule
\multicolumn{4}{r}{\textit{Continued on next page}} \\
\endfoot

\bottomrule
\endlastfoot

% Data rows
A1 & 300 & 1.0 & 0.95 \\
A2 & 310 & 1.1 & 0.98 \\
% ... many more rows
\end{longtable}
```

## Bibliography and Citations

### Citation Styles and Management
```latex
% Using natbib
\usepackage{natbib}
\bibliographystyle{plainnat}

% Citation commands
\cite{key}              % (Author, Year)
\citep{key}             % (Author, Year)
\citet{key}             % Author (Year)
\citeauthor{key}        % Author
\citeyear{key}          % Year

% Multiple citations
\cite{key1,key2,key3}
\cite[see][]{key}
\cite[chapter 3]{key}

% Bibliography file (references.bib)
@article{einstein1905,
    author = {Albert Einstein},
    title = {Zur Elektrodynamik bewegter K{\"o}rper},
    journal = {Annalen der Physik},
    volume = {17},
    number = {10},
    pages = {891--921},
    year = {1905},
    doi = {10.1002/andp.19053221004}
}

@book{griffiths2017,
    author = {David J. Griffiths},
    title = {Introduction to Electrodynamics},
    edition = {4th},
    publisher = {Cambridge University Press},
    year = {2017},
    isbn = {978-1108420419}
}

@inproceedings{smith2020,
    author = {John Smith and Jane Doe},
    title = {Advanced Computational Methods},
    booktitle = {Proceedings of the International Conference},
    pages = {123--145},
    year = {2020},
    address = {New York},
    publisher = {IEEE}
}
```

### BibLaTeX (Modern Bibliography)
```latex
\usepackage[style=nature,backend=biber]{biblatex}
\addbibresource{references.bib}

% Citation commands
\autocite{key}          % Automatic citation style
\textcite{key}          % In-text citation
\parencite{key}         % Parenthetical citation
\footcite{key}          % Footnote citation

% Print bibliography
\printbibliography[title=References]
```

## Cross-Referencing System

### Intelligent References with cleveref
```latex
\usepackage{hyperref}
\usepackage{cleveref}

% Label equations, figures, tables
\begin{equation}\label{eq:maxwell}
\nabla \times \mathbf{E} = -\frac{\partial \mathbf{B}}{\partial t}
\end{equation}

\begin{figure}[htbp]
\centering
\includegraphics[width=0.8\textwidth]{diagram.pdf}
\caption{Experimental setup}
\label{fig:setup}
\end{figure}

\begin{table}[htbp]
\centering
\begin{tabular}{cc}
A & B \\
C & D
\end{tabular}
\caption{Data summary}
\label{tab:data}
\end{table}

% Smart referencing
\cref{eq:maxwell}       % Equation (1)
\cref{fig:setup}        % Figure 1
\cref{tab:data}         % Table 1
\cref{eq:maxwell,fig:setup} % Equation (1) and Figure 1

% Customize reference names
\crefname{equation}{Eq.}{Eqs.}
\Crefname{equation}{Equation}{Equations}
```

## Troubleshooting Common Issues

### Package Conflicts and Solutions
```latex
% Hyperref conflicts - load hyperref late
\usepackage{amsmath}
% ... other packages
\usepackage{hyperref}    % Load near end
\usepackage{cleveref}    % Load after hyperref

% Graphics path issues
\graphicspath{{figures/}{images/}{./}}

% Font encoding issues
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}

% Math font issues
\usepackage{lmodern}     % Latin Modern fonts
\usepackage{amsfonts}    % AMS fonts
```

### Compilation Errors and Fixes
```latex
% Missing $ errors - check math mode
Inline math: $x = y$
Display math: \[x = y\]

% Undefined control sequence
% Solution: Check package loading and spelling

% Missing number treated as zero
% Solution: Check for missing arguments in commands

% Package option clash
% Solution: Load packages with same options or use:
\PassOptionsToPackage{option}{package}
\usepackage{package}
```

### Performance Optimization
```latex
% For large documents
\includeonly{chapter1,chapter3}  % Compile only specific chapters
\input{chapter1}                 % Use \input for sub-files
\include{chapter2}               % Use \include for chapters

% For many figures
\usepackage[final]{graphicx}     % Always include graphics
\usepackage[draft]{graphicx}     % Show boxes instead

% For complex math
\usepackage{breqn}               % Automatic equation breaking
```

## Document Class Options

### Article Class Customization
```latex
% Font sizes: 10pt, 11pt, 12pt
\documentclass[12pt]{article}

% Paper sizes: a4paper, letterpaper, legalpaper
\documentclass[a4paper]{article}

% Layout: onecolumn, twocolumn
\documentclass[twocolumn]{article}

% Equation numbering: leqno (left), fleqn (flush left)
\documentclass[leqno,fleqn]{article}

% Title page: titlepage, notitlepage
\documentclass[titlepage]{article}
```

### Specialized Document Classes
```latex
% AMS article class
\documentclass{amsart}

% IEEE conference papers
\documentclass[conference]{IEEEtran}

% Springer journals
\documentclass{svjour3}

% ACM papers
\documentclass{acmart}

% Book class
\documentclass[11pt,oneside]{book}

% Report class
\documentclass[12pt,twoside]{report}

% Presentation class
\documentclass{beamer}
```

## Version Control Integration

### Git Integration Best Practices
```bash
# .gitignore for LaTeX projects
*.aux
*.bbl
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.synctex.gz
*.toc
*.lot
*.lof
*.nav
*.snm
*.vrb
*.pdf    # Optional: exclude compiled PDFs

# Track source files
*.tex
*.bib
*.cls
*.sty
figures/
```

### Collaborative Writing
```latex
% Use latexdiff for version comparison
latexdiff old_version.tex new_version.tex > diff.tex

% Modular structure for collaboration
\input{sections/introduction}
\input{sections/methodology}
\input{sections/results}
\input{sections/conclusion}

% Use TODO notes for review
\usepackage{todonotes}
\todo{Review this section}
\missingfigure{Add experimental setup diagram}
```

## Quality Assurance

### Document Validation
- **Mathematical accuracy**: Verify all equations and derivations
- **Citation completeness**: Ensure all references are properly cited
- **Figure quality**: Use vector graphics (PDF/EPS) for scalability
- **Table formatting**: Follow journal-specific guidelines
- **Grammar and style**: Use consistent scientific writing style
- **Cross-references**: Verify all labels and references work correctly

### Publication Standards
- **Journal requirements**: Follow specific formatting guidelines
- **Accessibility**: Ensure proper alt-text for figures
- **Reproducibility**: Include sufficient detail for replication
- **Copyright**: Verify permissions for all included materials
- **Data availability**: Provide access to supporting data

### Final Checklist
- [ ] All equations properly numbered and referenced
- [ ] Figures and tables have descriptive captions
- [ ] Bibliography complete and properly formatted
- [ ] Cross-references working correctly
- [ ] Document compiles without errors or warnings
- [ ] PDF bookmarks and hyperlinks functional
- [ ] Mathematical notation consistent throughout
- [ ] SI units used correctly
- [ ] Abstract within word limits
- [ ] Acknowledgments and funding sources included

This comprehensive guide provides everything needed to create professional mathematical and scientific documents with LaTeX, from basic templates to advanced customization, ensuring publication-quality output for academic and research applications.