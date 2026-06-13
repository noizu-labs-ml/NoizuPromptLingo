# PDFKit

## Description
JavaScript PDF generation library for Node and browsers that provides a programmatic API for creating PDF documents.
- **Documentation**: https://pdfkit.org
- **GitHub**: https://github.com/foliojs/pdfkit
- **Type**: Document generation library

## Installation
```bash
npm install pdfkit
```

## Basic Setup
```javascript
const PDFDocument = require('pdfkit');
const fs = require('fs');

// Create a document
const doc = new PDFDocument();

// Pipe to file
doc.pipe(fs.createWriteStream('output.pdf'));

// Add content
doc.fontSize(25)
   .text('Sample PDF', 100, 100);

// Add image
doc.image('path/to/image.png', {
  fit: [250, 300],
  align: 'center',
  valign: 'center'
});

// Add page
doc.addPage()
   .fontSize(20)
   .text('Page 2', 100, 100);

// Finalize
doc.end();
```

## Browser Usage
```javascript
// Create blob and download
const stream = doc.pipe(blobStream());
stream.on('finish', () => {
  const blob = stream.toBlob('application/pdf');
  const url = stream.toBlobURL('application/pdf');
  window.open(url);
});
```

## Strengths
- Pure JavaScript implementation
- Works in Node.js and browsers
- Vector graphics support
- Font embedding and subsetting
- Image embedding (JPEG/PNG)
- Annotations and forms support

## Limitations
- Complex layouts require manual positioning
- No HTML/CSS to PDF conversion
- Table creation requires custom code
- Limited text flow control

## Best For
- Programmatic PDF generation
- Reports with dynamic data
- Invoices and documents
- Server-side PDF creation
- Client-side PDF generation

## NPL-FIM Integration
```yaml
format: pdfkit
capabilities: [document, vector, image, form]
platform: [node, browser]
output: pdf
```