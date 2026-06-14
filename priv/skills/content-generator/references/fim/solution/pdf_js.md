# PDF.js
Mozilla's JavaScript library for rendering PDF documents in web browsers without plugins. [Docs](https://mozilla.github.io/pdf.js/) | [Examples](https://mozilla.github.io/pdf.js/examples/)

## Install/Setup
```bash
# CDN (stable release)
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf_viewer.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.min.js"></script>

# NPM
npm install pdfjs-dist
```

## Basic Usage
```javascript
// Simple PDF rendering
const pdfjsLib = window['pdfjs-dist/build/pdf'];
pdfjsLib.GlobalWorkerOptions.workerSrc =
  'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.worker.min.js';

// Load and render PDF
pdfjsLib.getDocument('path/to/document.pdf').promise.then(pdf => {
  pdf.getPage(1).then(page => {
    const scale = 1.5;
    const viewport = page.getViewport({scale});

    const canvas = document.getElementById('pdf-canvas');
    const context = canvas.getContext('2d');
    canvas.height = viewport.height;
    canvas.width = viewport.width;

    page.render({
      canvasContext: context,
      viewport: viewport
    });
  });
});
```

## Strengths
- No browser plugins required
- Text extraction and search capabilities
- Accessibility support (screen readers)
- Form filling and annotations
- Cross-browser compatibility

## Limitations
- Large library size (~3MB)
- Performance issues with complex PDFs
- Limited editing capabilities
- Memory intensive for large documents

## Best For
`pdf-viewing`, `text-extraction`, `form-filling`, `document-preview`, `print-preview`

## NPL-FIM Integration
```npl
// PDF.js visualization in NPL-FIM
@fim {
  source: "pdf_js",
  config: {
    file: "document.pdf",
    page: 1,
    scale: 1.5,
    textLayer: true,
    annotationLayer: false
  }
}
```