# node-canvas

Canvas API implementation for Node.js enabling server-side image generation and manipulation.

GitHub: https://github.com/Automattic/node-canvas

## Installation

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# Install node-canvas
npm install canvas
```

## Server-Side Canvas Example

```javascript
const { createCanvas, loadImage } = require('canvas');
const fs = require('fs');

// Create 800x600 canvas
const canvas = createCanvas(800, 600);
const ctx = canvas.getContext('2d');

// Draw gradient background
const gradient = ctx.createLinearGradient(0, 0, 800, 600);
gradient.addColorStop(0, '#FF6B6B');
gradient.addColorStop(1, '#4ECDC4');
ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 800, 600);

// Add text
ctx.font = 'bold 48px Arial';
ctx.fillStyle = 'white';
ctx.fillText('Server-Side Canvas', 200, 300);

// Save to file
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('./output.png', buffer);
```

## Strengths
- Full Canvas API compatibility with browser implementations
- Supports PNG, JPEG, PDF, SVG output formats
- Hardware-accelerated Cairo backend
- Image loading and manipulation capabilities
- Text rendering with custom fonts

## Limitations
- Requires native Cairo dependencies
- Platform-specific build requirements
- No WebGL context support
- Memory intensive for large images
- Complex deployment in containerized environments

## Best For
- Server-side image generation pipelines
- Dynamic chart and graph rendering
- Automated thumbnail generation
- PDF report creation with graphics
- Batch image processing workflows

## NPL-FIM Integration
- **Rendering Layer**: Direct Canvas API implementation
- **Processing**: Synchronous server-side operations
- **Output**: Buffer-based image generation
- **Performance**: Native Cairo acceleration
- **Compatibility**: Drop-in replacement for browser Canvas API