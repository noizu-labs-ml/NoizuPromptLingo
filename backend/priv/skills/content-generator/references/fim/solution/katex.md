# KaTeX Fast Math Rendering

## Setup
```html
<!-- KaTeX CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css">

<!-- KaTeX JS -->
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"></script>
```

## Auto-Render Setup
```javascript
document.addEventListener("DOMContentLoaded", function() {
  renderMathInElement(document.body, {
    delimiters: [
      {left: '$$', right: '$$', display: true},
      {left: '$', right: '$', display: false},
      {left: '\\(', right: '\\)', display: false},
      {left: '\\[', right: '\\]', display: true}
    ],
    throwOnError: false
  });
});
```

## Direct API Usage
```javascript
// Render to string
const html = katex.renderToString("c = \\pm\\sqrt{a^2 + b^2}", {
  throwOnError: false
});

// Render to DOM element
katex.render("E = mc^2", document.getElementById('equation'), {
  displayMode: true
});
```

## NPL-FIM Integration
```javascript
// Fast render NPL expressions
const nplExpr = "∫[0→π] sin(x) dx";
const texExpr = nplToTeX(nplExpr);
katex.render(texExpr, element, {
  macros: {
    "\\RR": "\\mathbb{R}",
    "\\NN": "\\mathbb{N}"
  }
});
```

## Performance Features
- No dependencies
- Server-side rendering support
- Smaller than MathJax
- Synchronous rendering
- CSS-based layout