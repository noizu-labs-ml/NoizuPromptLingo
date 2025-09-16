# MathJax Math Rendering

## Setup
```html
<!-- MathJax 3 -->
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
```

## Configuration
```javascript
window.MathJax = {
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']],
    displayMath: [['$$', '$$'], ['\\[', '\\]']],
    processEscapes: true
  },
  svg: {
    fontCache: 'global'
  }
};
```

## Basic Usage
```html
<p>Inline: $x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$</p>
<p>Display: $$\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}$$</p>
```

## Dynamic Rendering
```javascript
// Typeset new content
MathJax.typesetPromise([document.getElementById('math-content')])
  .then(() => console.log('Math rendered'));

// Queue new math
MathJax.startup.document.clear();
MathJax.startup.document.updateDocument();
```

## NPL-FIM Integration
```javascript
// Render NPL math expressions
const expr = nplFim.parse("∑[n=1→∞] 1/n²");
const mathml = expr.toMathML();
MathJax.mathml2chtml(mathml);
```

## Accessibility
- Automatic MathML generation
- Screen reader support
- Keyboard navigation
- Explorer menu for complex expressions