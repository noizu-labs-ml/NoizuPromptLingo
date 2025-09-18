# MathBox 3D Math Visualization

## Setup
```html
<!-- Three.js required -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<!-- MathBox -->
<script src="https://cdn.jsdelivr.net/npm/mathbox@2.3.1/build/mathbox-bundle.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/mathbox@2.3.1/build/mathbox.css">
```

## Basic 3D Plot
```javascript
// Initialize
const mathbox = MathBox.mathBox({
  plugins: ['core', 'controls', 'cursor'],
  controls: {
    klass: THREE.OrbitControls
  }
});

// Camera setup
const camera = mathbox.camera({
  proxy: true,
  position: [2, 1, 2]
});

// 3D cartesian space
const view = mathbox.cartesian({
  range: [[-2, 2], [-2, 2], [-2, 2]],
  scale: [2, 2, 2]
});

// Axes
view.axis({ axis: 1, color: 'red' });
view.axis({ axis: 2, color: 'green' });
view.axis({ axis: 3, color: 'blue' });

// Grid
view.grid({ axes: [1, 3], divideX: 10, divideY: 10 });
```

## Surface Plot
```javascript
// Data for z = sin(x) * cos(y)
view.area({
  axes: [1, 3],
  width: 64,
  height: 64,
  expr: function(emit, x, y) {
    emit(x, Math.sin(x) * Math.cos(y), y);
  }
}).surface({
  shaded: true,
  color: '#4080FF'
});
```

## Animated Parametric
```javascript
// Time-varying parameter
const time = mathbox.clock();

// Animated helix
view.interval({
  width: 256,
  expr: function(emit, x, i, t) {
    const theta = x * 4 * Math.PI;
    emit(Math.cos(theta), x * 2 - 1, Math.sin(theta));
  }
}).line({
  color: '#FF4080',
  width: 3
});
```

## NPL-FIM Integration
```javascript
// Render NPL 3D expression
const expr = npl.parse3D("z = x² + y²");
const mathboxConfig = expr.toMathBox();
view.area(mathboxConfig).surface();
```