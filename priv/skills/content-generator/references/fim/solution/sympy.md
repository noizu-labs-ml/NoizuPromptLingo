# SymPy Symbolic Mathematics

## Setup
```bash
pip install sympy
# For plotting
pip install matplotlib
# For LaTeX output
pip install IPython
```

## Basic Symbolic Math
```python
from sympy import *

# Define symbols
x, y, z = symbols('x y z')
a, b, c = symbols('a b c', real=True)
n = symbols('n', integer=True)

# Expressions
expr = x**2 + 2*x + 1
factored = factor(expr)  # (x + 1)**2
expanded = expand((x + y)**3)  # x**3 + 3*x**2*y + 3*x*y**2 + y**3

# Substitution
result = expr.subs(x, 2)  # 9
```

## Calculus
```python
# Derivatives
f = sin(x) * exp(x)
df = diff(f, x)  # exp(x)*sin(x) + exp(x)*cos(x)
df2 = diff(f, x, 2)  # Second derivative

# Integrals
integral = integrate(x**2 * cos(x), x)
definite = integrate(exp(-x**2), (x, -oo, oo))  # sqrt(pi)

# Limits
lim = limit(sin(x)/x, x, 0)  # 1
lim_inf = limit(1/x, x, oo)  # 0

# Series
series_exp = exp(x).series(x, 0, 5)  # 1 + x + x**2/2 + x**3/6 + x**4/24
```

## Equation Solving
```python
# Single equation
solutions = solve(x**2 - 4, x)  # [-2, 2]

# System of equations
eq1 = Eq(x + y, 5)
eq2 = Eq(x - y, 1)
solution = solve([eq1, eq2], [x, y])  # {x: 3, y: 2}

# Differential equations
f = Function('f')
dif_eq = Eq(f(x).diff(x, 2) - f(x), 0)
general = dsolve(dif_eq, f(x))
```

## Matrix Operations
```python
# Define matrix
M = Matrix([[1, 2], [3, 4]])
det = M.det()  # -2
inv = M.inv()  # Matrix([[-2, 1], [3/2, -1/2]])
eigenvals = M.eigenvals()  # {-0.372: 1, 5.372: 1}
```

## NPL-FIM Integration
```python
# Parse NPL expression
from npl_fim import parse_math
npl_expr = "∂²f/∂x² + ∂²f/∂y² = 0"
sympy_eq = parse_math(npl_expr).to_sympy()
solution = solve(sympy_eq)
```