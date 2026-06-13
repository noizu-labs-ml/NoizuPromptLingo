# Mammoth.js

## Description
JavaScript library for converting Word (DOCX) documents to HTML with clean semantic markup.
https://github.com/mwilliamson/mammoth.js

## Installation
```javascript
// Node.js
npm install mammoth

// Browser (include script)
<script src="mammoth.browser.min.js"></script>
```

## Basic Usage
```javascript
// Node.js
const mammoth = require("mammoth");

mammoth.convertToHtml({path: "document.docx"})
    .then(result => {
        const html = result.value; // Generated HTML
        const messages = result.messages; // Warnings
    });

// Browser with file input
mammoth.convertToHtml({arrayBuffer: arrayBuffer})
    .then(displayResult);
```

## Configuration
```javascript
const options = {
    styleMap: [
        "p[style-name='Heading 1'] => h1:fresh",
        "p[style-name='Heading 2'] => h2:fresh"
    ]
};

mammoth.convertToHtml({path: "document.docx"}, options);
```

## Strengths
- Clean, semantic HTML output without proprietary markup
- Preserves document structure (headings, lists, tables)
- Customizable style mapping for consistent formatting
- Works in both Node.js and browsers

## Limitations
- One-way conversion only (DOCX to HTML)
- Limited support for complex Word features (charts, SmartArt)
- No direct PDF support

## Best For
- Document import workflows
- Content migration from Word
- Clean HTML generation from DOCX files
- CMS integration

## NPL-FIM Integration
```typescript
interface MammothConverter extends FIMNode {
    type: 'document-converter';
    input: ArrayBuffer | File;
    output: HTMLContent;
    styleMap?: StyleMapping[];
}
```

## Version Support
- Node.js: 0.10+
- Browser: IE 9+, Chrome, Firefox, Safari