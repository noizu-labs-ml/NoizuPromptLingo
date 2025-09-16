# Asymptote Vector Graphics

## Setup
```bash
# Installation
apt-get install asymptote
# macOS
brew install asymptote

# Compile .asy file
asy filename.asy
# Output formats: pdf, eps, svg, png
asy -f svg filename.asy
```

## 2D Graphics
```asymptote
size(200);
import graph;

// Function plot
real f(real x) { return sin(x); }
draw(graph(f, 0, 2pi), red);

// Axes
xaxis("$x$", Arrow);
yaxis("$y$", Arrow);

// Geometric shapes
draw(circle((0,0), 1));
fill(box((-0.5,-0.5), (0.5,0.5)), blue+opacity(0.3));

// Labels
label("$\sin(x)$", (pi,0), N);
```

## 3D Graphics
```asymptote
import three;
size(200);
currentprojection = perspective(5,4,3);

// 3D surface
triple f(pair z) {
  real x = z.x, y = z.y;
  return (x, y, sin(x)*cos(y));
}

surface s = surface(f, (-pi,-pi), (pi,pi), 50, 50);
draw(s, lightblue);

// Axes
axes3("$x$", "$y$", "$z$", Arrow3);
```

## Parametric Curves
```asymptote
size(150);
pair spiral(real t) {
  return (t*cos(t), t*sin(t));
}
path p = graph(spiral, 0, 4pi, 200);
draw(p, blue+linewidth(1));
```

## NPL-FIM Integration
```javascript
// Export NPL diagram to Asymptote
const diagram = npl.parse3D("sphere(r=1) ∩ cylinder(h=2)");
const asy = diagram.toAsymptote();
// Generates Asymptote code for intersection
```