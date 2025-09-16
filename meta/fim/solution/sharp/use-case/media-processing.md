# Sharp Media Processing Use Case

## High-Performance Image Processing
Process images for engineering documentation and visualization workflows.

## Implementation Pattern
```javascript
const sharp = require('sharp');

// Resize and optimize diagrams
await sharp('circuit-diagram.png')
  .resize(1200, 800, { fit: 'inside' })
  .png({ quality: 90 })
  .toFile('circuit-optimized.png');

// Generate thumbnails for documentation
await sharp('oscilloscope-capture.jpg')
  .resize(300, 200)
  .jpeg({ quality: 85 })
  .toFile('thumb-scope.jpg');

// Convert formats for web display
await sharp('schematic.tiff')
  .png()
  .toFile('schematic-web.png');
```

## Engineering Applications
- Optimize oscilloscope captures
- Resize PCB layout images
- Convert CAD exports for documentation
- Generate web-friendly diagram formats
- Process measurement screenshots

## Processing Operations
- Format conversion (TIFF/BMP → PNG/JPEG)
- Resolution optimization for print/web
- Batch processing of test results
- Watermarking for IP protection
- Metadata extraction and preservation

## NPL-FIM Context
Critical for preparing engineering images and measurements for documentation systems requiring specific formats and sizes.