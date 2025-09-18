# abcjs - ABC Music Notation JavaScript Library

## Overview
abcjs is a comprehensive JavaScript library for parsing, rendering, and playing ABC music notation. It transforms simple text-based ABC notation into beautiful SVG musical scores with full MIDI playback capabilities. The library is widely used for educational applications, folk music collections, and interactive music notation platforms.

**Current Version**: 6.4.0+ (actively maintained)
**License**: MIT License (free for commercial and personal use)
**Bundle Size**: ~400KB minified, ~120KB gzipped
**Browser Support**: All modern browsers (Chrome 60+, Firefox 55+, Safari 12+, Edge 79+)

## Official Resources & Documentation

### Primary Documentation
- **Official Website**: https://abcjs.net/
- **GitHub Repository**: https://github.com/paulrosen/abcjs
- **npm Package**: https://www.npmjs.com/package/abcjs
- **API Documentation**: https://abcjs.net/docs/
- **Live Examples**: https://abcjs.net/examples/

### Community Resources
- **ABC Notation Standard**: https://abcnotation.com/
- **ABC Tutorial**: https://abcnotation.com/learn
- **Community Forum**: https://groups.google.com/g/abcusers
- **Example Collections**: https://abcnotation.com/examples
- **Tune Collections**: https://thesession.org/, https://tunearch.org/

### Learning Resources
- **ABC Notation Primer**: https://abcnotation.com/wiki/abc:standard
- **Music Theory for ABC**: https://abcnotation.com/wiki/abc:tutorial
- **Advanced ABC Features**: https://abcnotation.com/wiki/abc:advanced

## Installation & Setup

### Package Manager Installation
```bash
# npm
npm install abcjs

# yarn
yarn add abcjs

# pnpm
pnpm add abcjs
```

### CDN Installation
```html
<!-- Full version with MIDI support -->
<script src="https://cdn.jsdelivr.net/npm/abcjs@6/dist/abcjs-basic-min.js"></script>

<!-- Audio plugin for advanced playback -->
<script src="https://cdn.jsdelivr.net/npm/abcjs@6/dist/abcjs-audio-min.js"></script>

<!-- Complete bundle -->
<script src="https://unpkg.com/abcjs@latest/dist/abcjs-basic-min.js"></script>
```

### ES Module Import
```javascript
// Full import
import abcjs from 'abcjs';

// Selective imports for smaller bundles
import { renderAbc, renderMidi } from 'abcjs/midi';
import { Editor } from 'abcjs/editor';
```

### CommonJS Require
```javascript
const abcjs = require('abcjs');
const { renderAbc, renderMidi } = require('abcjs');
```

## Core API Reference

### Primary Rendering Methods

#### abcjs.renderAbc()
Main method for rendering ABC notation to SVG.

```javascript
abcjs.renderAbc(elementId, abcString, options);
```

**Parameters:**
- `elementId` (string|Element): Target DOM element or ID
- `abcString` (string): ABC notation text
- `options` (object): Rendering configuration options

**Returns:** Array of rendered tune objects

#### abcjs.renderMidi()
Generates MIDI data and optional playback controls.

```javascript
abcjs.renderMidi(elementId, abcString, options);
```

**Parameters:**
- `elementId` (string|Element): Target DOM element for MIDI controls
- `abcString` (string): ABC notation text
- `options` (object): MIDI generation options

**Returns:** MIDI data object

### Comprehensive Configuration Options

#### Visual Rendering Options
```javascript
const visualOptions = {
  // Layout and sizing
  scale: 1.0,                    // Overall scale factor (0.5-3.0)
  staffwidth: 740,               // Staff width in pixels
  paddingtop: 15,                // Top padding
  paddingbottom: 30,             // Bottom padding
  paddingleft: 15,               // Left padding
  paddingright: 50,              // Right padding

  // Typography
  titlefont: "serif 20",         // Title font specification
  subtitlefont: "serif 16",      // Subtitle font
  composerfont: "serif 14",      // Composer font
  vocalfont: "serif 13",         // Vocal/lyrics font
  annotationfont: "serif 12",    // Annotation font
  gchordfont: "serif 12",        // Guitar chord font

  // Colors and styling
  foregroundColor: "#000000",    // Primary color
  backgroundColor: "#ffffff",    // Background color
  selectionColor: "#0066cc",     // Selection highlight color

  // Responsive behavior
  responsive: "resize",          // Responsive mode: "resize" | "scale" | "stretch"

  // Advanced layout
  wrap: { minSpacing: 1.8, maxSpacing: 2.7, preferredMeasuresPerLine: 4 },
  tablature: [{ instrument: 'violin', label: 'Violin' }],

  // Print formatting
  pageheight: 27.94,            // Page height in cm
  pagewidth: 21.59,             // Page width in cm
  topmargin: 2,                 // Top margin in cm
  bottommargin: 2,              // Bottom margin
  leftmargin: 1.8,              // Left margin
  rightmargin: 1.8,             // Right margin

  // Interaction
  clickListener: function(abcElem, tuneNumber, classes, analysis, drag) {
    // Handle click events on notation elements
  },

  // Performance
  add_classes: true,            // Add CSS classes to SVG elements
  viewBox: true,                // Use SVG viewBox for scaling
};
```

#### MIDI Playback Options
```javascript
const midiOptions = {
  // Playback controls
  generateDownload: true,        // Generate download link
  generateInline: true,          // Generate inline player

  // MIDI configuration
  program: 0,                   // MIDI program/instrument (0-127)
  midiTranspose: 0,             // Transpose semitones

  // Timing and tempo
  qpm: 120,                     // Quarter notes per minute
  chordsOff: false,             // Turn off chord accompaniment

  // Audio synthesis
  soundFont: "https://paulrosen.github.io/midi-js-soundfonts/MusyngKite/",

  // Playback behavior
  drum: "",                     // Drum pattern
  drumBars: 1,                  // Bars per drum pattern
  drumIntro: 0,                 // Drum intro bars

  // Visual feedback during playback
  animate: {
    target: "svg-container",    // Target element for animation
    qpm: 120,                   // Animation speed
  }
};
```

## Advanced Usage Examples

### Interactive Music Editor
```javascript
// Complete interactive editor setup
class MusicEditor {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.setupEditor();
  }

  setupEditor() {
    // Create textarea for ABC input
    const textarea = document.createElement('textarea');
    textarea.id = 'abc-input';
    textarea.rows = 15;
    textarea.cols = 80;
    textarea.value = this.getDefaultABC();

    // Create output containers
    const scoreDiv = document.createElement('div');
    scoreDiv.id = 'abc-score';

    const midiDiv = document.createElement('div');
    midiDiv.id = 'abc-midi';

    const warningsDiv = document.createElement('div');
    warningsDiv.id = 'abc-warnings';

    // Append to container
    this.container.appendChild(textarea);
    this.container.appendChild(scoreDiv);
    this.container.appendChild(midiDiv);
    this.container.appendChild(warningsDiv);

    // Initialize editor
    this.editor = new abcjs.Editor('abc-input', {
      canvas_id: 'abc-score',
      warnings_id: 'abc-warnings',
      midi_id: 'abc-midi',
      abcjsParams: {
        responsive: 'resize',
        scale: 1.2,
        add_classes: true,
        clickListener: this.handleNoteClick.bind(this)
      }
    });
  }

  handleNoteClick(abcElem, tuneNumber, classes, analysis, drag) {
    console.log('Note clicked:', abcElem, classes);
    // Implement note selection/editing logic
  }

  getDefaultABC() {
    return `X:1
T:Sample Tune
M:4/4
L:1/8
K:G
|:G2AB c2BA | G2AB c2BA | G2AB c2de | d2cB A4 :|
|:g2fg e2ed | c2Bc A2AB | c2Bc A2AB | G4 G4 :|`;
  }
}

// Initialize editor
const editor = new MusicEditor('music-editor-container');
```

### Multi-Voice Arrangements
```javascript
// Complex multi-voice ABC notation
const complexScore = `
X:1
T:Four-Part Harmony Example
C:Traditional
M:4/4
L:1/4
K:C
V:1 name="Soprano" clef=treble
V:2 name="Alto" clef=treble
V:3 name="Tenor" clef=treble-8
V:4 name="Bass" clef=bass
V:1
c2 d2 | e2 f2 | g4 | f2 e2 | d2 c2 |
V:2
G2 A2 | B2 c2 | d4 | c2 B2 | A2 G2 |
V:3
E2 F2 | G2 A2 | B4 | A2 G2 | F2 E2 |
V:4
C,2 D,2 | E,2 F,2 | G,4 | F,2 E,2 | D,2 C,2 |
`;

// Render with specific voice styling
abcjs.renderAbc('multivoice-score', complexScore, {
  scale: 1.3,
  staffwidth: 800,
  voiceScale: 1.0,
  wrap: { minSpacing: 2.0, maxSpacing: 3.0 }
});
```

### Dynamic Score Generation
```javascript
// Generate scores programmatically
class ScoreGenerator {
  constructor() {
    this.scales = {
      major: [0, 2, 4, 5, 7, 9, 11],
      minor: [0, 2, 3, 5, 7, 8, 10],
      dorian: [0, 2, 3, 5, 7, 9, 10]
    };

    this.keys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
  }

  generateScale(key, mode, octaves = 1) {
    const notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    const keyIndex = notes.indexOf(key);
    const intervals = this.scales[mode];

    let abcNotes = [];

    for (let octave = 0; octave < octaves; octave++) {
      intervals.forEach(interval => {
        const noteIndex = (keyIndex + Math.floor(interval / 12)) % 7;
        const noteName = notes[noteIndex];

        // Add octave markers for ABC notation
        if (octave > 0) {
          abcNotes.push(noteName.toLowerCase());
        } else {
          abcNotes.push(noteName);
        }
      });
    }

    return this.createABCScore(key, mode, abcNotes);
  }

  createABCScore(key, mode, notes) {
    return `X:1
T:${key} ${mode.charAt(0).toUpperCase() + mode.slice(1)} Scale
M:4/4
L:1/8
K:${key}
${notes.join(' ')} |`;
  }

  renderGeneratedScale(containerId, key, mode) {
    const abc = this.generateScale(key, mode);
    abcjs.renderAbc(containerId, abc, {
      scale: 1.5,
      responsive: 'resize'
    });
  }
}

// Usage
const generator = new ScoreGenerator();
generator.renderGeneratedScale('generated-scale', 'G', 'major');
```

## Framework Integration Patterns

### React Integration
```javascript
import React, { useEffect, useRef } from 'react';
import abcjs from 'abcjs';

const ABCScore = ({ notation, options = {} }) => {
  const scoreRef = useRef(null);
  const renderRef = useRef(null);

  useEffect(() => {
    if (scoreRef.current && notation) {
      renderRef.current = abcjs.renderAbc(scoreRef.current, notation, {
        responsive: 'resize',
        scale: 1.2,
        ...options
      });
    }

    return () => {
      // Cleanup if needed
      if (renderRef.current) {
        renderRef.current = null;
      }
    };
  }, [notation, options]);

  return <div ref={scoreRef} className="abc-score" />;
};

// Usage in React component
const MusicApp = () => {
  const [abcNotation, setAbcNotation] = useState(`
X:1
T:React Example
M:4/4
L:1/4
K:C
C D E F | G A B c |
  `);

  return (
    <div>
      <textarea
        value={abcNotation}
        onChange={(e) => setAbcNotation(e.target.value)}
        rows={10}
        cols={50}
      />
      <ABCScore notation={abcNotation} />
    </div>
  );
};
```

### Vue.js Integration
```javascript
// Vue component for ABC notation
<template>
  <div>
    <textarea
      v-model="abcNotation"
      @input="renderScore"
      rows="10"
      cols="50"
    ></textarea>
    <div ref="scoreContainer" class="abc-score"></div>
    <div ref="midiContainer" class="abc-midi"></div>
  </div>
</template>

<script>
import abcjs from 'abcjs';

export default {
  name: 'ABCNotation',
  props: {
    initialNotation: {
      type: String,
      default: ''
    },
    renderOptions: {
      type: Object,
      default: () => ({})
    }
  },
  data() {
    return {
      abcNotation: this.initialNotation
    };
  },
  mounted() {
    this.renderScore();
  },
  methods: {
    renderScore() {
      if (this.abcNotation && this.$refs.scoreContainer) {
        abcjs.renderAbc(this.$refs.scoreContainer, this.abcNotation, {
          responsive: 'resize',
          scale: 1.2,
          ...this.renderOptions
        });

        if (this.$refs.midiContainer) {
          abcjs.renderMidi(this.$refs.midiContainer, this.abcNotation, {
            generateInline: true,
            generateDownload: true
          });
        }
      }
    }
  },
  watch: {
    initialNotation(newVal) {
      this.abcNotation = newVal;
      this.renderScore();
    }
  }
};
</script>
```

### Angular Integration
```typescript
import { Component, ElementRef, Input, OnChanges, ViewChild } from '@angular/core';
import * as abcjs from 'abcjs';

@Component({
  selector: 'app-abc-score',
  template: `
    <div #scoreContainer class="abc-score"></div>
    <div #midiContainer class="abc-midi"></div>
  `
})
export class ABCScoreComponent implements OnChanges {
  @Input() notation: string = '';
  @Input() options: any = {};

  @ViewChild('scoreContainer', { static: true }) scoreContainer!: ElementRef;
  @ViewChild('midiContainer', { static: true }) midiContainer!: ElementRef;

  ngOnChanges() {
    this.renderScore();
  }

  ngAfterViewInit() {
    this.renderScore();
  }

  private renderScore() {
    if (this.notation && this.scoreContainer) {
      abcjs.renderAbc(
        this.scoreContainer.nativeElement,
        this.notation,
        {
          responsive: 'resize',
          scale: 1.2,
          ...this.options
        }
      );

      if (this.midiContainer) {
        abcjs.renderMidi(
          this.midiContainer.nativeElement,
          this.notation,
          {
            generateInline: true,
            generateDownload: true
          }
        );
      }
    }
  }
}
```

### Node.js Server-Side Rendering
```javascript
// Server-side ABC processing with Node.js
const abcjs = require('abcjs');
const fs = require('fs');

class ServerABCProcessor {
  constructor() {
    this.defaultOptions = {
      scale: 1.0,
      staffwidth: 740,
      paddingtop: 15,
      paddingbottom: 30
    };
  }

  // Process ABC file and generate SVG
  async processABCFile(inputPath, outputPath, options = {}) {
    try {
      const abcContent = fs.readFileSync(inputPath, 'utf8');
      const renderOptions = { ...this.defaultOptions, ...options };

      // Render to SVG string (server-side)
      const result = abcjs.renderAbc('*', abcContent, renderOptions);

      if (result && result[0] && result[0].svg) {
        fs.writeFileSync(outputPath, result[0].svg);
        return { success: true, svgPath: outputPath };
      } else {
        throw new Error('Failed to generate SVG');
      }
    } catch (error) {
      return { success: false, error: error.message };
    }
  }

  // Batch process multiple ABC files
  async batchProcess(inputDir, outputDir, options = {}) {
    const files = fs.readdirSync(inputDir).filter(f => f.endsWith('.abc'));
    const results = [];

    for (const file of files) {
      const inputPath = `${inputDir}/${file}`;
      const outputPath = `${outputDir}/${file.replace('.abc', '.svg')}`;

      const result = await this.processABCFile(inputPath, outputPath, options);
      results.push({ file, ...result });
    }

    return results;
  }

  // Validate ABC notation
  validateABC(abcContent) {
    try {
      const result = abcjs.renderAbc('*', abcContent, { add_classes: true });
      return {
        valid: true,
        warnings: result.warnings || [],
        tunes: result.length
      };
    } catch (error) {
      return {
        valid: false,
        error: error.message,
        tunes: 0
      };
    }
  }
}

// Usage
const processor = new ServerABCProcessor();

// Process single file
processor.processABCFile('./input.abc', './output.svg', { scale: 1.5 })
  .then(result => console.log('Processing result:', result));

// Batch process
processor.batchProcess('./abc-files', './svg-output')
  .then(results => console.log('Batch results:', results));
```

## Performance Optimization

### Bundle Size Optimization
```javascript
// Import only what you need for smaller bundles
import { renderAbc } from 'abcjs/src/api/abc_tunebook_svg';
import { renderMidi } from 'abcjs/src/api/abc_tunebook_midi';

// Custom build excluding unused features
const customABCJS = {
  renderAbc: require('abcjs/src/api/abc_tunebook_svg').renderAbc,
  // Exclude MIDI if not needed
  // Exclude Editor if not needed
};
```

### Lazy Loading Implementation
```javascript
// Lazy load abcjs for better initial page performance
class LazyABCLoader {
  constructor() {
    this.abcjs = null;
    this.loading = false;
    this.loadPromise = null;
  }

  async loadABCJS() {
    if (this.abcjs) return this.abcjs;
    if (this.loading) return this.loadPromise;

    this.loading = true;
    this.loadPromise = import('abcjs').then(module => {
      this.abcjs = module.default || module;
      this.loading = false;
      return this.abcjs;
    });

    return this.loadPromise;
  }

  async renderScore(elementId, abcString, options = {}) {
    const abcjs = await this.loadABCJS();
    return abcjs.renderAbc(elementId, abcString, options);
  }
}

// Usage
const lazyLoader = new LazyABCLoader();

// Only loads abcjs when actually needed
document.getElementById('load-music').addEventListener('click', async () => {
  await lazyLoader.renderScore('score-container', abcNotation);
});
```

### Memory Management
```javascript
// Proper cleanup for single-page applications
class ABCManager {
  constructor() {
    this.renderedScores = new Map();
    this.activeEditors = new Map();
  }

  renderScore(id, notation, options) {
    // Clean up existing render
    this.cleanup(id);

    const result = abcjs.renderAbc(id, notation, options);
    this.renderedScores.set(id, result);

    return result;
  }

  createEditor(id, options) {
    this.cleanup(id);

    const editor = new abcjs.Editor(id, options);
    this.activeEditors.set(id, editor);

    return editor;
  }

  cleanup(id) {
    // Clean up rendered scores
    if (this.renderedScores.has(id)) {
      const element = document.getElementById(id);
      if (element) {
        element.innerHTML = '';
      }
      this.renderedScores.delete(id);
    }

    // Clean up editors
    if (this.activeEditors.has(id)) {
      const editor = this.activeEditors.get(id);
      // Editor cleanup would go here if available
      this.activeEditors.delete(id);
    }
  }

  cleanupAll() {
    this.renderedScores.forEach((_, id) => this.cleanup(id));
    this.activeEditors.forEach((_, id) => this.cleanup(id));
  }
}

// Global cleanup on page unload
window.addEventListener('beforeunload', () => {
  if (window.abcManager) {
    window.abcManager.cleanupAll();
  }
});
```

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. Rendering Problems
**Issue**: Score not rendering or appearing blank
```javascript
// Solution: Check element exists and ABC is valid
function debugRender(elementId, abcString, options) {
  const element = document.getElementById(elementId);

  if (!element) {
    console.error(`Element with ID '${elementId}' not found`);
    return;
  }

  if (!abcString || abcString.trim() === '') {
    console.error('ABC string is empty or undefined');
    return;
  }

  try {
    const result = abcjs.renderAbc(elementId, abcString, options);

    if (!result || result.length === 0) {
      console.error('No tunes rendered - check ABC syntax');
      return;
    }

    console.log('Successfully rendered', result.length, 'tune(s)');
    return result;
  } catch (error) {
    console.error('Rendering error:', error);

    // Check for common ABC syntax errors
    if (abcString.indexOf('X:') === -1) {
      console.error('Missing X: field (tune number)');
    }
    if (abcString.indexOf('K:') === -1) {
      console.error('Missing K: field (key signature)');
    }
  }
}
```

#### 2. MIDI Playback Issues
**Issue**: MIDI not playing or controls not appearing
```javascript
// Solution: Verify audio context and user interaction
function debugMIDI(elementId, abcString, options) {
  // Check if MIDI generation succeeded
  try {
    const midiResult = abcjs.renderMidi(elementId, abcString, options);

    if (!midiResult) {
      console.error('MIDI generation failed');
      return;
    }

    // Check for audio context issues
    if (typeof AudioContext !== 'undefined' || typeof webkitAudioContext !== 'undefined') {
      console.log('Audio context available');
    } else {
      console.error('Audio context not supported in this browser');
    }

    // Check for user interaction requirement
    console.log('MIDI generated. User interaction may be required for playback.');

  } catch (error) {
    console.error('MIDI error:', error);
  }
}

// Enable audio after user interaction
document.addEventListener('click', function enableAudio() {
  const AudioContext = window.AudioContext || window.webkitAudioContext;
  if (AudioContext) {
    const audioContext = new AudioContext();
    if (audioContext.state === 'suspended') {
      audioContext.resume();
    }
  }
  document.removeEventListener('click', enableAudio);
}, { once: true });
```

#### 3. Responsive Layout Issues
**Issue**: Score not scaling properly on different screen sizes
```javascript
// Solution: Implement proper responsive handling
function setupResponsiveScore(elementId, abcString) {
  const container = document.getElementById(elementId);

  function renderResponsive() {
    const containerWidth = container.offsetWidth;

    let scale = 1.0;
    let staffwidth = 740;

    if (containerWidth < 500) {
      scale = 0.7;
      staffwidth = containerWidth - 40;
    } else if (containerWidth < 800) {
      scale = 0.9;
      staffwidth = containerWidth - 60;
    } else {
      staffwidth = Math.min(800, containerWidth - 80);
    }

    abcjs.renderAbc(elementId, abcString, {
      scale: scale,
      staffwidth: staffwidth,
      responsive: 'resize',
      paddingtop: 15,
      paddingbottom: 30
    });
  }

  // Initial render
  renderResponsive();

  // Re-render on window resize
  let resizeTimeout;
  window.addEventListener('resize', () => {
    clearTimeout(resizeTimeout);
    resizeTimeout = setTimeout(renderResponsive, 250);
  });
}
```

#### 4. Memory Leaks in SPAs
**Issue**: Memory usage increasing over time in single-page applications
```javascript
// Solution: Implement proper cleanup
class ABCScoreManager {
  constructor() {
    this.observers = new Map();
    this.cleanupFunctions = new Map();
  }

  renderWithCleanup(elementId, abcString, options) {
    // Clean up previous render
    this.cleanup(elementId);

    // Render new score
    const result = abcjs.renderAbc(elementId, abcString, options);

    // Set up cleanup for this render
    const cleanupFn = () => {
      const element = document.getElementById(elementId);
      if (element) {
        element.innerHTML = '';
      }
    };

    this.cleanupFunctions.set(elementId, cleanupFn);

    // Set up intersection observer for automatic cleanup
    const element = document.getElementById(elementId);
    if (element && 'IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) {
            // Element is not visible, could trigger cleanup after delay
          }
        });
      });

      observer.observe(element);
      this.observers.set(elementId, observer);
    }

    return result;
  }

  cleanup(elementId) {
    // Cleanup observers
    if (this.observers.has(elementId)) {
      this.observers.get(elementId).disconnect();
      this.observers.delete(elementId);
    }

    // Run cleanup function
    if (this.cleanupFunctions.has(elementId)) {
      this.cleanupFunctions.get(elementId)();
      this.cleanupFunctions.delete(elementId);
    }
  }

  cleanupAll() {
    this.observers.forEach((observer, id) => {
      observer.disconnect();
    });
    this.cleanupFunctions.forEach((cleanup, id) => {
      cleanup();
    });

    this.observers.clear();
    this.cleanupFunctions.clear();
  }
}
```

## ABC Notation Quick Reference

### Essential ABC Syntax
```abc
X:1              % Tune number (required)
T:Tune Title     % Title
C:Composer       % Composer
M:4/4           % Time signature
L:1/8           % Default note length
K:G             % Key signature (required, must be last header field)

% Notes and rhythms
C D E F         % Quarter notes (using default L:1/8, these are 1/8 notes)
C2              % Half note (twice default length)
C/2             % Eighth note (half default length)
C3/2            % Dotted quarter note

% Bars and repeats
|               % Bar line
||              % Double bar line
|:              % Start repeat
:|              % End repeat
[1              % First ending
[2              % Second ending

% Chords and harmony
[CEG]           % Chord
"C"C            % Guitar chord symbol
"^annotation"C  % Annotation above note

% Ornaments and articulation
~C              % Trill
.C              % Staccato
>C              % Accent

% Multiple voices
V:1             % Voice 1
V:2             % Voice 2
```

### Advanced Features
```abc
% Percussion notation
K:perc
[F,F]           % Bass drum and snare

% Tablature
K:none
%%MIDI program 25  % Nylon guitar
T:G D A E       % String names

% Microtones
^/C             % Quarter-tone sharp
_/C             % Quarter-tone flat

% Tempo markings
Q:1/4=120       % 120 BPM quarter notes
Q:"Allegro"     % Text tempo marking

% Dynamics
%%dynamic ff    % Fortissimo
%%dynamic pp    % Pianissimo

% Custom fields
%%scale 1.5     % Custom scaling
%%bgcolor white % Background color
```

## Version Compatibility & Migration

### Version History & Breaking Changes

#### v6.x (Current)
- **New Features**: Enhanced responsive rendering, improved MIDI synthesis
- **Breaking Changes**: Some API parameter names changed
- **Migration**: Update option names (`staffWidth` → `staffwidth`)

#### v5.x → v6.x Migration
```javascript
// Old v5.x syntax
abcjs.renderAbc('div', abc, {
  staffWidth: 500,        // Old parameter name
  paddingTop: 15,         // Old parameter name
  scale: 1.0
});

// New v6.x syntax
abcjs.renderAbc('div', abc, {
  staffwidth: 500,        // New parameter name (lowercase)
  paddingtop: 15,         // New parameter name (lowercase)
  scale: 1.0              // Unchanged
});
```

#### Browser Compatibility Matrix
| Browser | Minimum Version | SVG Support | MIDI Support | Audio Support |
|---------|----------------|-------------|--------------|---------------|
| Chrome | 60+ | ✅ | ✅ | ✅ |
| Firefox | 55+ | ✅ | ✅ | ✅ |
| Safari | 12+ | ✅ | ✅ | ✅ |
| Edge | 79+ | ✅ | ✅ | ✅ |
| IE | Not Supported | ❌ | ❌ | ❌ |

### Feature Support Matrix
| Feature | Web | Node.js | React Native | Electron |
|---------|-----|---------|--------------|----------|
| SVG Rendering | ✅ | ✅ | Limited | ✅ |
| MIDI Generation | ✅ | ✅ | ❌ | ✅ |
| Audio Playback | ✅ | ❌ | ❌ | ✅ |
| Interactive Editor | ✅ | ❌ | ❌ | ✅ |

## Best Practices & Design Patterns

### Performance Best Practices
1. **Lazy Loading**: Load abcjs only when music notation is needed
2. **Caching**: Cache rendered SVG for repeated displays
3. **Debouncing**: Debounce real-time editing updates
4. **Cleanup**: Properly clean up DOM elements in SPAs
5. **Bundle Optimization**: Import only needed modules

### Accessibility Guidelines
```javascript
// Implement proper ARIA labels and keyboard navigation
function renderAccessibleScore(elementId, abcString, options = {}) {
  const accessibleOptions = {
    ...options,
    add_classes: true,
    clickListener: (abcElem, tuneNumber, classes) => {
      // Announce note information to screen readers
      const noteInfo = `${classes.pitches?.[0]?.name || 'Note'} ${classes.duration || ''}`;
      announceToScreenReader(noteInfo);
    }
  };

  const result = abcjs.renderAbc(elementId, abcString, accessibleOptions);

  // Add ARIA labels to container
  const container = document.getElementById(elementId);
  if (container) {
    container.setAttribute('role', 'img');
    container.setAttribute('aria-label', 'Musical score');
    container.setAttribute('tabindex', '0');
  }

  return result;
}

function announceToScreenReader(message) {
  const announcement = document.createElement('div');
  announcement.setAttribute('aria-live', 'polite');
  announcement.setAttribute('aria-atomic', 'true');
  announcement.className = 'sr-only';
  announcement.textContent = message;

  document.body.appendChild(announcement);
  setTimeout(() => document.body.removeChild(announcement), 1000);
}
```

### Security Considerations
```javascript
// Sanitize user input for ABC notation
function sanitizeABCInput(input) {
  // Remove potentially dangerous content
  const cleaned = input
    .replace(/<script[^>]*>.*?<\/script>/gi, '') // Remove script tags
    .replace(/javascript:/gi, '')                // Remove javascript: URLs
    .replace(/on\w+\s*=/gi, '');                // Remove event handlers

  return cleaned;
}

// Validate ABC before rendering
function validateAndRender(elementId, abcString, options) {
  try {
    const sanitized = sanitizeABCInput(abcString);

    // Basic validation
    if (!sanitized.includes('X:')) {
      throw new Error('Invalid ABC: Missing tune number (X:)');
    }

    if (!sanitized.includes('K:')) {
      throw new Error('Invalid ABC: Missing key signature (K:)');
    }

    return abcjs.renderAbc(elementId, sanitized, options);
  } catch (error) {
    console.error('ABC validation failed:', error);
    return null;
  }
}
```

## Production Deployment Checklist

### Pre-Deployment Verification
- [ ] Bundle size optimized (only include needed modules)
- [ ] Cross-browser testing completed
- [ ] Responsive behavior verified on all target devices
- [ ] Memory leak testing in long-running sessions
- [ ] Accessibility testing with screen readers
- [ ] Performance testing with large scores
- [ ] Error handling implemented for all user inputs

### CDN and Caching Configuration
```javascript
// Service Worker for offline caching
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open('abcjs-v1').then(cache => {
      return cache.addAll([
        'https://cdn.jsdelivr.net/npm/abcjs@6/dist/abcjs-basic-min.js',
        // Add other abcjs assets
      ]);
    })
  );
});

// Cache-first strategy for abcjs assets
self.addEventListener('fetch', event => {
  if (event.request.url.includes('abcjs')) {
    event.respondWith(
      caches.match(event.request).then(response => {
        return response || fetch(event.request);
      })
    );
  }
});
```

### Monitoring and Analytics
```javascript
// Track abcjs usage and performance
class ABCAnalytics {
  constructor(analyticsEndpoint) {
    this.endpoint = analyticsEndpoint;
    this.startTime = null;
  }

  trackRenderStart(tuneCount, complexity) {
    this.startTime = performance.now();
    this.sendEvent('render_start', {
      tune_count: tuneCount,
      complexity: complexity
    });
  }

  trackRenderComplete(success, errorMessage = null) {
    const duration = performance.now() - this.startTime;

    this.sendEvent('render_complete', {
      success: success,
      duration: Math.round(duration),
      error: errorMessage
    });
  }

  trackMIDIPlayback(duration) {
    this.sendEvent('midi_playback', {
      duration: duration
    });
  }

  sendEvent(eventName, data) {
    if (this.endpoint) {
      fetch(this.endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: eventName,
          timestamp: Date.now(),
          data: data
        })
      }).catch(err => console.warn('Analytics error:', err));
    }
  }
}

// Usage
const analytics = new ABCAnalytics('/api/analytics');

function monitoredRender(elementId, abcString, options) {
  const tuneCount = (abcString.match(/^X:/gm) || []).length;
  const complexity = abcString.length;

  analytics.trackRenderStart(tuneCount, complexity);

  try {
    const result = abcjs.renderAbc(elementId, abcString, options);
    analytics.trackRenderComplete(true);
    return result;
  } catch (error) {
    analytics.trackRenderComplete(false, error.message);
    throw error;
  }
}
```

## Strengths and Limitations

### Strengths
- **Lightweight**: Small bundle size compared to full notation libraries
- **Fast Rendering**: Optimized SVG generation for web display
- **Text-Based Format**: ABC notation is human-readable and version-control friendly
- **Built-in MIDI**: Integrated audio playback without external dependencies
- **Cross-Platform**: Works consistently across all modern browsers
- **Active Community**: Strong ecosystem with extensive documentation
- **Framework Agnostic**: Easy integration with any JavaScript framework
- **Responsive Design**: Built-in support for responsive layouts
- **Accessibility**: SVG output is screen-reader compatible
- **Real-time Editing**: Live preview capabilities for interactive applications

### Limitations
- **ABC Notation Scope**: Limited to what ABC notation can express
- **Complex Scores**: Less suitable for complex classical arrangements
- **Layout Control**: Limited fine-grained layout customization
- **Print Quality**: SVG output may not match dedicated music publishing software
- **Modern Notation**: Some contemporary notation elements not supported
- **Large Scores**: Performance may degrade with very long compositions

### Ideal Use Cases
- **Folk and Traditional Music**: Perfect for simple melodies and arrangements
- **Educational Applications**: Excellent for music theory and learning tools
- **Interactive Websites**: Real-time notation editing and display
- **Music Databases**: Large collections of simple tunes
- **Collaborative Platforms**: Version-controlled music sharing
- **Mobile Applications**: Lightweight notation display
- **Prototyping**: Quick notation mockups and demos
- **Documentation**: Musical examples in technical writing

## Conclusion

abcjs is a powerful, lightweight solution for web-based music notation that excels in scenarios requiring fast, responsive, and interactive musical score display. Its text-based ABC notation format makes it particularly valuable for collaborative music projects, educational applications, and any scenario where human-readable, version-controllable music notation is beneficial.

The library's comprehensive API, excellent browser support, and active development make it an excellent choice for modern web applications requiring music notation capabilities. While it may not replace specialized music engraving software for complex classical scores, it provides an optimal balance of features, performance, and ease of use for the majority of web-based music notation needs.

With proper implementation following the patterns and best practices outlined in this reference, abcjs can power robust, production-ready music notation applications that deliver excellent user experiences across all platforms and devices.