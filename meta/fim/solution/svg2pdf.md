# svg2pdf.js - SVG to PDF Conversion Solution

## Description
JavaScript library for converting SVG elements directly to PDF format while preserving vector graphics.
- GitHub: https://github.com/eKoopmans/svg2pdf.js
- License: MIT
- Dependencies: jsPDF

## Installation
```bash
npm install svg2pdf.js jspdf
```

## Basic Setup
```javascript
import { jsPDF } from 'jspdf';
import 'svg2pdf.js';

const doc = new jsPDF();
const svgElement = document.getElementById('my-svg');

// Convert SVG to PDF
doc.svg(svgElement, {
  x: 10,
  y: 10,
  width: 180,
  height: 160
}).then(() => {
  doc.save('output.pdf');
});
```

## Advanced Usage
```javascript
// With custom options
doc.svg(svgElement, {
  x: 10,
  y: 10,
  width: 180,
  height: 160,
  preserveAspectRatio: 'xMidYMid meet',
  loadExternalStyleSheets: true
});
```

## Strengths
- Preserves vector graphics (scalable, no pixelation)
- Maintains text as selectable PDF text
- Supports CSS styling and transformations
- Direct SVG to PDF without intermediate formats
- Small file sizes for vector graphics

## Limitations
- Complex gradients and filters may not render perfectly
- Some SVG features have limited support
- Requires jsPDF as dependency
- Performance issues with very complex SVGs

## Best For
- Charts and graphs export
- Technical diagrams
- Vector illustrations
- Reports with embedded graphics
- Print-ready documents from web visualizations

## NPL-FIM Integration
```yaml
solution_type: svg-to-pdf
vector_preservation: true
text_selectable: true
browser_compatible: true
server_compatible: false
```