# jsPDF

## Description
Client-side PDF generation library for creating PDFs directly in the browser.
- GitHub: https://github.com/parallax/jsPDF

## Installation
```bash
# NPM
npm install jspdf

# CDN
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
```

## Basic Usage
```javascript
import { jsPDF } from 'jspdf';

const doc = new jsPDF();

// Add text
doc.text('Hello world!', 10, 10);
doc.setFontSize(16);
doc.text('This is a PDF', 10, 30);

// Add pages
doc.addPage();
doc.text('Page 2', 10, 10);

// Add images (base64 or URL)
doc.addImage(imageData, 'PNG', 10, 50, 100, 75);

// Draw shapes
doc.rect(10, 100, 50, 30);
doc.circle(35, 130, 15);

// Save PDF
doc.save('document.pdf');
```

## Strengths
- Pure client-side generation (no server required)
- Lightweight and fast
- Good text and basic shape support
- Plugin ecosystem for tables, autotable, etc.
- Works in all modern browsers

## Limitations
- Limited layout control compared to server-side solutions
- Complex layouts require manual positioning
- Font embedding can increase file size
- No HTML/CSS rendering (use html2canvas plugin)

## Best For
- Simple PDF reports and documents
- Client-side PDF generation requirements
- Basic invoices, receipts, certificates
- When server-side generation isn't an option

## NPL-FIM Integration
```yaml
format: pdf
engine: jspdf
capabilities: [text, shapes, images, pages]
environment: browser
```