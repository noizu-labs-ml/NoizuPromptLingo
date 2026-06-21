# SageMath Mathematical System

## Setup
```bash
# Docker installation (recommended)
docker run -p 8888:8888 sagemath/sagemath:latest

# Native installation
apt-get install sagemath
# Or conda
conda install -c conda-forge sage

# Start notebook
sage -n jupyter
```

## Basic Operations
```python
# Symbolic variables
var('x y z')
f = x^2 + 3*x - 5

# Calculus
derivative(f, x)  # 2*x + 3
integral(f, x)  # x^3/3 + 3*x^2/2 - 5*x
limit(sin(x)/x, x=0)  # 1

# Solve equations
solve(x^2 - 4 == 0, x)  # [x == -2, x == 2]
solve([x + y == 5, x - y == 1], x, y)  # [[x == 3, y == 2]]
```

## Number Theory
```python
# Prime operations
is_prime(17)  # True
next_prime(100)  # 101
factor(120)  # 2^3 * 3 * 5

# Modular arithmetic
mod(17, 5)  # 2
inverse_mod(3, 7)  # 5 (since 3*5 ≡ 1 mod 7)

# Finite fields
F = GF(7)  # Field with 7 elements
a = F(3)
b = F(5)
a * b  # 1 (in GF(7))
```

## Linear Algebra
```python
# Matrices
A = matrix([[1, 2], [3, 4]])
B = matrix([[5, 6], [7, 8]])

A * B  # Matrix multiplication
A.eigenvalues()  # [-0.372..., 5.372...]
A.jordan_form()  # Jordan canonical form

# Vector spaces
V = VectorSpace(QQ, 3)  # 3D rational vector space
v1 = V([1, 2, 3])
v2 = V([4, 5, 6])
v1.cross_product(v2)  # (-3, 6, -3)
```

## Plotting
```python
# 2D plots
plot(sin(x), (x, -2*pi, 2*pi))
parametric_plot((cos(t), sin(t)), (t, 0, 2*pi))

# 3D plots
var('u v')
plot3d(sin(x*y), (x, -2, 2), (y, -2, 2))
parametric_plot3d((cos(u)*sin(v), sin(u)*sin(v), cos(v)),
                  (u, 0, 2*pi), (v, 0, pi))
```

## Group Theory
```python
# Symmetric group
G = SymmetricGroup(4)
G.order()  # 24
G.is_abelian()  # False

# Permutations
p = G("(1,2,3)")
q = G("(2,3,4)")
p * q  # (1,3,2,4)
```

## NPL-FIM Integration
```python
# Import NPL expressions
from sage.all import *
npl_expr = "∮_C z² dz where C: |z|=1"
integral = npl_to_sage(npl_expr)
result = integral.evaluate()  # 0 by Cauchy's theorem
```