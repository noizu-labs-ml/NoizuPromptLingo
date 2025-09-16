# Sharp - High-Performance Node.js Image Processing

## Description
[Sharp](https://sharp.pixelplumbing.com) is a high-performance Node.js module for resizing, converting, and manipulating images. Built on the blazingly fast libvips image processing library.

## Installation and Setup
```bash
npm install sharp
```

```javascript
const sharp = require('sharp');
```

## Basic Example - Resize and Format Conversion
```javascript
sharp('input.jpg')
  .resize(300, 200)
  .toFormat('webp')
  .toFile('output.webp')
  .then(info => console.log(info))
  .catch(err => console.error(err));

// Pipeline with multiple operations
sharp('large.png')
  .resize({ width: 800 })
  .jpeg({ quality: 80 })
  .blur(2)
  .toBuffer()
  .then(data => { /* Process buffer */ });
```

## Strengths
- **Performance**: Fastest Node.js image processing library
- **libvips Backend**: Leverages high-performance C library with low memory footprint
- **Stream Support**: Efficient streaming and buffer operations
- **Format Support**: JPEG, PNG, WebP, AVIF, TIFF, GIF, SVG
- **Operations**: Resize, rotate, extract, composite, color manipulation

## Limitations
- **Node.js Only**: Requires server-side environment
- **Binary Dependencies**: Needs platform-specific binaries
- **No Browser Support**: Cannot run client-side
- **Limited Vector Support**: SVG rasterization only

## Best For
- Server-side image processing pipelines
- Batch image optimization
- Real-time image transformation APIs
- Thumbnail generation services
- Image format conversion at scale

## NPL-FIM Integration
```npl
⟪image-processor:sharp⟫
  .capability: "server-side image manipulation"
  .performance: "high-throughput with libvips"
  .pipeline: [resize → format → optimize → output]
  .use-cases: ["thumbnails", "responsive-images", "optimization"]
⟪/⟫
```

References: [API Documentation](https://sharp.pixelplumbing.com/api-constructor) | [libvips](https://www.libvips.org/)