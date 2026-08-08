# Jimp - Pure JavaScript Image Processing

## Description
JavaScript Image Manipulation Program (Jimp) - A pure JavaScript image processing library with zero native dependencies.
https://github.com/jimp-dev/jimp

## Installation
```bash
# Node.js
npm install jimp

# Browser (via CDN)
<script src="https://unpkg.com/jimp@latest/browser/lib/jimp.js"></script>
```

## Basic Example
```javascript
const Jimp = require('jimp');

// Load and manipulate image
Jimp.read('input.jpg')
  .then(image => {
    return image
      .resize(256, 256)           // Resize
      .quality(60)                // Set JPEG quality
      .greyscale()                // Convert to greyscale
      .blur(5)                    // Apply blur
      .write('output.jpg');       // Save
  })
  .catch(err => console.error(err));

// Browser usage
Jimp.read(imageUrl).then(image => {
  image.getBase64(Jimp.MIME_PNG, (err, src) => {
    document.querySelector('img').src = src;
  });
});
```

## Key Capabilities
- Resize, crop, rotate, flip images
- Apply filters: blur, sharpen, greyscale, sepia
- Adjust brightness, contrast, opacity
- Composite images and add text
- Support for PNG, JPEG, BMP, TIFF, GIF

## Strengths
- **Zero Dependencies**: Pure JavaScript, no native bindings
- **Cross-Platform**: Works in Node.js and browsers
- **Simple API**: Promise-based, chainable methods
- **Plugin System**: Extensible architecture

## Limitations
- **Performance**: Slower than native libraries for large images
- **Memory Usage**: High memory consumption for large images
- **Format Support**: Limited compared to native solutions
- **Advanced Features**: No GPU acceleration

## Best For
- Simple image edits without complex setup
- Cross-platform applications
- Serverless environments
- Quick prototyping
- Browser-based image manipulation

## NPL-FIM Integration
```fim
<fim-image-edit src="image.jpg" processor="jimp">
  resize: 512x512
  filters: [blur(3), greyscale()]
  output: processed.jpg
</fim-image-edit>
```