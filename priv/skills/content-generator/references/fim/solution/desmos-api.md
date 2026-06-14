# Desmos API Graphing Calculator

## Setup
```html
<script src="https://www.desmos.com/api/v1.8/calculator.js?apiKey=YOUR_KEY"></script>
<div id="calculator" style="width: 600px; height: 400px;"></div>
```

## Initialize Calculator
```javascript
const elt = document.getElementById('calculator');
const calculator = Desmos.GraphingCalculator(elt, {
  keypad: true,
  expressions: true,
  settingsMenu: true,
  zoomButtons: true,
  expressionsTopbar: true
});

// Set viewport
calculator.setMathBounds({
  left: -10,
  right: 10,
  bottom: -10,
  top: 10
});
```

## Expression Management
```javascript
// Add expressions
calculator.setExpression({
  id: 'graph1',
  latex: 'y = x^2 + 2x - 3',
  color: Desmos.Colors.BLUE
});

// Parametric
calculator.setExpression({
  id: 'parametric',
  latex: '(t\\cos(t), t\\sin(t))',
  color: Desmos.Colors.RED
});

// Point with label
calculator.setExpression({
  id: 'point1',
  latex: 'P = (3, 4)',
  showLabel: true
});

// Slider
calculator.setExpression({
  id: 'slider_a',
  latex: 'a = 1',
  sliderBounds: { min: -5, max: 5, step: 0.1 }
});
```

## Interactive Features
```javascript
// Get/set state
const state = calculator.getState();
localStorage.setItem('graph', JSON.stringify(state));

// Restore state
const saved = JSON.parse(localStorage.getItem('graph'));
calculator.setState(saved);

// Screenshot
calculator.screenshot({
  width: 500,
  height: 300,
  targetPixelRatio: 2
}, function(dataUri) {
  const img = document.createElement('img');
  img.src = dataUri;
});

// Observe changes
calculator.observeEvent('change', function() {
  console.log('Graph updated');
});
```

## NPL-FIM Integration
```javascript
// Convert NPL to Desmos
const nplExpr = "f(x) = x² - 4; zeros: f(x) = 0";
const desmos = nplToDesmos(nplExpr);
desmos.forEach(expr => calculator.setExpression(expr));
```