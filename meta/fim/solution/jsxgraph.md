# JSXGraph Interactive Geometry

## Setup
```html
<!-- JSXGraph CSS and JS -->
<link rel="stylesheet" type="text/css"
  href="https://cdn.jsdelivr.net/npm/jsxgraph@1.4.6/distrib/jsxgraph.css" />
<script type="text/javascript"
  src="https://cdn.jsdelivr.net/npm/jsxgraph@1.4.6/distrib/jsxgraphcore.js"></script>

<!-- Container -->
<div id="jxgbox" style="width: 500px; height: 500px;"></div>
```

## Basic Construction
```javascript
// Initialize board
const board = JXG.JSXGraph.initBoard('jxgbox', {
  boundingbox: [-5, 5, 5, -5],
  axis: true,
  grid: true
});

// Interactive points
const p1 = board.create('point', [1, 1], {name: 'A'});
const p2 = board.create('point', [3, 2], {name: 'B'});

// Line through points
const line = board.create('line', [p1, p2], {
  strokeColor: 'blue',
  strokeWidth: 2
});

// Circle
const circle = board.create('circle', [p1, 2], {
  fillColor: 'yellow',
  fillOpacity: 0.3
});
```

## Function Plotting
```javascript
// Plot function
const f = board.create('functiongraph', [
  function(x) { return Math.sin(x) * Math.exp(-x/5); },
  -10, 10
], {strokeWidth: 2, strokeColor: 'red'});

// Derivative
const df = board.create('functiongraph', [
  JXG.Math.Numerics.D(f.Y), -10, 10
], {dash: 2, strokeColor: 'green'});

// Integral area
const integral = board.create('integral', [[-2, 2], f], {
  fillColor: 'blue', fillOpacity: 0.2
});
```

## Interactive Slider
```javascript
// Parameter slider
const slider = board.create('slider', [
  [-3, 4], [3, 4], [0, 1, 10]
], {name: 'a'});

// Parametric curve
board.create('curve', [
  t => slider.Value() * Math.cos(t),
  t => slider.Value() * Math.sin(t),
  0, 2 * Math.PI
], {strokeWidth: 2});
```

## NPL-FIM Integration
```javascript
// Parse NPL geometric construction
const construction = npl.parseGeometry("triangle(A,B,C); circumcircle");
construction.renderToJSXGraph(board);
```