# OSMD (OpenSheetMusicDisplay) - MusicXML Display

## Overview
TypeScript/JavaScript library for rendering MusicXML scores in browsers using VexFlow. OSMD provides a high-level API for displaying musical notation with automatic layout, formatting, and comprehensive MusicXML support.

**Official Resources:**
- [GitHub Repository](https://github.com/opensheetmusicdisplay/opensheetmusicdisplay)
- [Official Documentation](https://opensheetmusicdisplay.github.io/demo/)
- [API Documentation](https://opensheetmusicdisplay.github.io/opensheetmusicdisplay/)
- [Live Demo](https://opensheetmusicdisplay.github.io/demo/)
- [Example Gallery](https://github.com/opensheetmusicdisplay/opensheetmusicdisplay/tree/develop/demo)

## License & Pricing
- **License**: BSD 3-Clause License (Open Source)
- **Commercial Use**: Free for commercial and non-commercial projects
- **Attribution**: Required (retain copyright notice)
- **Source Code**: Available on GitHub under permissive license

## Browser Compatibility
**Supported Browsers:**
- Chrome 60+ (recommended)
- Firefox 55+
- Safari 11+
- Edge 79+
- Mobile Safari (iOS 11+)
- Chrome Android 60+

**Requirements:**
- ES6/ES2015 support
- SVG rendering capabilities
- Web Audio API (for cursor/playback features)
- Minimum 2GB RAM for large scores
- Hardware acceleration recommended

## Installation

### NPM Package
```bash
npm install opensheetmusicdisplay
# TypeScript definitions included
```

### CDN
```html
<script src="https://cdn.jsdelivr.net/npm/opensheetmusicdisplay/build/opensheetmusicdisplay.min.js"></script>
```

### Webpack/Bundle Configuration
```javascript
// webpack.config.js
module.exports = {
  resolve: {
    fallback: {
      "fs": false,
      "path": false
    }
  }
};
```

## Configuration Examples

### Basic Setup
```javascript
import { OpenSheetMusicDisplay } from 'opensheetmusicdisplay';

// Initialize OSMD
const osmd = new OpenSheetMusicDisplay('score-container', {
  backend: 'svg',
  drawTitle: true,
  drawComposer: true
});

// Load MusicXML
async function loadScore() {
  await osmd.load('path/to/score.musicxml');
  await osmd.render();
}
```

### Advanced Configuration
```javascript
const osmd = new OpenSheetMusicDisplay('score-container', {
  // Rendering options
  backend: 'svg',                    // 'svg' or 'canvas'
  autoResize: true,                  // Auto-resize to container
  pageBreaks: true,                  // Enable page breaks
  pageFormat: 'A4_P',               // Page format

  // Display options
  drawTitle: true,
  drawComposer: true,
  drawLyricist: false,
  drawCredits: true,
  drawPartNames: true,
  drawPartAbbreviations: true,
  drawMeasureNumbers: true,
  drawMeasureNumbersOnlyAtSystemStart: false,

  // Layout options
  compactMode: false,                // Compact spacing
  defaultColorMusic: '#000000',      // Default music color
  defaultColorTitle: '#000000',      // Title color
  defaultFontFamily: 'Times New Roman',
  defaultFontSize: 12,

  // Performance options
  drawHiddenNotes: false,           // Skip hidden notes
  drawingParameters: 'default',     // Drawing quality
  renderSingleHorizontalStaffline: false
});
```

### Interactive Features
```javascript
// Cursor control for playback visualization
osmd.cursor.show();
osmd.cursor.next();                // Move to next note
osmd.cursor.previous();            // Move to previous note
osmd.cursor.reset();               // Reset to beginning

// Zoom and view control
osmd.zoom = 0.8;                   // Set zoom level
osmd.setLogLevel('warn');          // Set logging level

// Event handling
osmd.cursor.CursorPositionChanged = (cursor) => {
  console.log('Cursor moved to:', cursor.Iterator.CurrentMeasure);
};
```

### Loading Different Sources
```javascript
// Load from URL
async function loadFromURL(url) {
  await osmd.load(url);
  await osmd.render();
}

// Load from XML string
async function loadFromString(xmlString) {
  await osmd.load(xmlString);
  osmd.zoom = 0.8;
  await osmd.render();
}

// Load from File input
async function loadFromFile(file) {
  const text = await file.text();
  await osmd.load(text);
  await osmd.render();
}

// Load with error handling
async function safeLoad(source) {
  try {
    await osmd.load(source);
    await osmd.render();
    console.log('Score loaded successfully');
  } catch (error) {
    console.error('Failed to load score:', error);
  }
}
```

### Responsive Design
```javascript
// Auto-resize handling
function setupResponsive() {
  const container = document.getElementById('score-container');
  const resizeObserver = new ResizeObserver(() => {
    osmd.render();
  });
  resizeObserver.observe(container);
}

// Manual resize
function resizeScore() {
  const container = document.getElementById('score-container');
  osmd.setLogLevel('warn');
  osmd.render();
}
```

## Performance Considerations

### Bundle Size Optimization
```javascript
// Tree-shaking support - import only needed modules
import { OpenSheetMusicDisplay } from 'opensheetmusicdisplay/build/dist/src/OpenSheetMusicDisplay';

// Lazy loading for large applications
const loadOSMD = () => import('opensheetmusicdisplay');
```

### Memory Management
```javascript
// Dispose of instances when no longer needed
function cleanupOSMD() {
  if (osmd) {
    osmd.clear();  // Clear rendered content
    osmd = null;   // Release reference
  }
}

// For large scores, consider pagination
const osmd = new OpenSheetMusicDisplay('container', {
  drawingParameters: 'compact',  // Reduce memory usage
  pageBreaks: true,             // Enable pagination
  drawHiddenNotes: false        // Skip unnecessary elements
});
```

### Rendering Performance
```javascript
// Optimize rendering for large scores
const osmd = new OpenSheetMusicDisplay('container', {
  backend: 'svg',               // SVG generally faster than canvas
  autoResize: false,           // Disable if manual control preferred
  drawingParameters: 'compact' // Faster rendering
});

// Batch operations
async function loadAndRenderOptimized(xmlString) {
  osmd.setLogLevel('error');    // Reduce console output
  await osmd.load(xmlString);
  await osmd.render();
  osmd.setLogLevel('warn');     // Restore normal logging
}
```

## Troubleshooting

### Common Issues and Solutions

**1. Bundle Size Too Large**
```javascript
// Problem: Large bundle size affecting load times
// Solution: Use dynamic imports and tree-shaking
const loadOSMD = async () => {
  const { OpenSheetMusicDisplay } = await import('opensheetmusicdisplay');
  return OpenSheetMusicDisplay;
};
```

**2. MusicXML Loading Failures**
```javascript
// Problem: Scores fail to load or render incorrectly
// Solution: Validate XML and handle errors gracefully
async function validateAndLoad(xmlString) {
  try {
    // Basic XML validation
    const parser = new DOMParser();
    const doc = parser.parseFromString(xmlString, 'application/xml');
    const errorNode = doc.querySelector('parsererror');

    if (errorNode) {
      throw new Error('Invalid XML format');
    }

    await osmd.load(xmlString);
    await osmd.render();
  } catch (error) {
    console.error('Loading failed:', error.message);
    // Display user-friendly error message
    displayError('Unable to load music score. Please check the file format.');
  }
}
```

**3. Rendering Performance Issues**
```javascript
// Problem: Slow rendering of large scores
// Solution: Optimize settings and implement virtual scrolling
const osmd = new OpenSheetMusicDisplay('container', {
  drawingParameters: 'compact',
  drawHiddenNotes: false,
  pageBreaks: true,
  autoResize: false
});

// Implement lazy loading for multi-page scores
function loadPageByPage(xmlString, pageSize = 20) {
  // Split score into smaller chunks for rendering
  // Implementation depends on score structure
}
```

**4. Mobile Compatibility Issues**
```javascript
// Problem: Touch events and mobile rendering
// Solution: Mobile-specific configuration
function setupMobileSupport() {
  const isMobile = /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

  if (isMobile) {
    const osmd = new OpenSheetMusicDisplay('container', {
      autoResize: true,
      defaultFontSize: 14,        // Larger font for mobile
      compactMode: true,          // Better for small screens
      drawMeasureNumbers: false   // Reduce clutter
    });
  }
}
```

**5. CORS Issues with Remote Files**
```javascript
// Problem: Cannot load MusicXML from external URLs
// Solution: Proxy through your server or use proper CORS headers
async function loadWithProxy(url) {
  try {
    // Option 1: Server-side proxy
    const response = await fetch(`/api/proxy?url=${encodeURIComponent(url)}`);
    const xmlString = await response.text();
    await osmd.load(xmlString);

    // Option 2: Direct with proper headers (if server supports CORS)
    const directResponse = await fetch(url, {
      mode: 'cors',
      headers: {
        'Accept': 'application/xml, text/xml'
      }
    });

    if (!directResponse.ok) throw new Error('Network error');
    const xml = await directResponse.text();
    await osmd.load(xml);
  } catch (error) {
    console.error('CORS or network error:', error);
  }
}
```

### Debug Mode Configuration
```javascript
// Enable detailed logging for troubleshooting
const osmd = new OpenSheetMusicDisplay('container', {
  // ... other options
});

osmd.setLogLevel('debug');  // Verbose logging
// Other levels: 'trace', 'debug', 'info', 'warn', 'error'

// Access internal state for debugging
console.log('OSMD Version:', osmd.Version);
console.log('Graphic Sheet:', osmd.graphic);
console.log('Current Sheet:', osmd.sheet);
```

## Strengths
- **Comprehensive MusicXML Support**: Handles complex musical notation including dynamics, articulations, and advanced features
- **Automatic Layout Engine**: Intelligent spacing, alignment, and formatting without manual intervention
- **High-Level API**: Built on VexFlow but provides simpler, more intuitive interface
- **TypeScript Support**: Full type definitions included for enhanced development experience
- **Cross-Platform**: Works consistently across all modern browsers and mobile devices
- **Active Development**: Regular updates and community support
- **Extensible**: Plugin architecture allows for custom extensions

## Limitations
- **Bundle Size**: Larger footprint (2-3MB) compared to lightweight alternatives
- **Customization Constraints**: Less granular control than direct VexFlow usage
- **No Audio Playback**: Requires integration with separate audio libraries
- **Memory Usage**: Can be intensive with very large orchestral scores
- **Limited Animation**: Basic cursor support, complex animations require custom implementation
- **Print Support**: Web printing may not always match screen rendering exactly

## Best Use Cases
- **Digital Sheet Music Platforms**: Library systems, score sharing websites
- **Music Education Software**: Interactive learning applications with score display
- **Practice Applications**: Apps requiring visual score following and cursor tracking
- **Music Analysis Tools**: Academic software for score analysis and annotation
- **Composition Software**: Displaying exported scores from notation programs
- **Publishing Workflows**: Converting MusicXML to web-displayable format
- **Mobile Music Apps**: Score readers and practice companions
- **Archive Digitization**: Converting legacy scores to modern web format

## Integration Examples

### With Audio Playback Libraries
```javascript
// Integrate with Tone.js for audio
import * as Tone from 'tone';

class ScorePlayer {
  constructor(containerId) {
    this.osmd = new OpenSheetMusicDisplay(containerId);
    this.synth = new Tone.Synth().toDestination();
  }

  async playCurrentNote() {
    const note = this.osmd.cursor.Iterator.CurrentNote;
    if (note) {
      this.synth.triggerAttackRelease(note.Pitch.ToString(), '4n');
      this.osmd.cursor.next();
    }
  }
}
```

### React Component
```jsx
import React, { useEffect, useRef } from 'react';
import { OpenSheetMusicDisplay } from 'opensheetmusicdisplay';

function ScoreViewer({ musicXML, options = {} }) {
  const containerRef = useRef(null);
  const osmdRef = useRef(null);

  useEffect(() => {
    if (containerRef.current && !osmdRef.current) {
      osmdRef.current = new OpenSheetMusicDisplay(containerRef.current, {
        autoResize: true,
        backend: 'svg',
        ...options
      });
    }
  }, [options]);

  useEffect(() => {
    if (osmdRef.current && musicXML) {
      osmdRef.current.load(musicXML)
        .then(() => osmdRef.current.render())
        .catch(console.error);
    }
  }, [musicXML]);

  return <div ref={containerRef} style={{ width: '100%', height: '600px' }} />;
}
```