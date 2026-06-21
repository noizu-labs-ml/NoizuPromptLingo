# VexFlow - Music Notation Rendering

## Overview
JavaScript library for rendering standard music notation and guitar tablature in SVG/Canvas.

## Installation
```bash
npm install vexflow
# or
<script src="https://cdn.jsdelivr.net/npm/vexflow@4/build/cjs/vexflow.js"></script>
```

## Minimal Example
```javascript
import { Renderer, Stave, StaveNote, Voice, Formatter } from 'vexflow';

// Create renderer
const div = document.getElementById('output');
const renderer = new Renderer(div, Renderer.Backends.SVG);
renderer.resize(500, 200);
const context = renderer.getContext();

// Create stave
const stave = new Stave(10, 40, 400);
stave.addClef('treble').addTimeSignature('4/4');
stave.setContext(context).draw();

// Create notes
const notes = [
  new StaveNote({ keys: ['c/4'], duration: 'q' }),
  new StaveNote({ keys: ['d/4'], duration: 'q' }),
  new StaveNote({ keys: ['e/4'], duration: 'q' }),
  new StaveNote({ keys: ['f/4'], duration: 'q' })
];

// Create voice and format
const voice = new Voice({ num_beats: 4, beat_value: 4 });
voice.addTickables(notes);
new Formatter().joinVoices([voice]).format([voice], 350);
voice.draw(context, stave);
```

## Strengths
- Pure JavaScript, no external dependencies
- Excellent for dynamic notation generation
- Supports tabs, percussion, articulations
- Client-side rendering without server requirements

## Limitations
- Manual positioning for complex layouts
- No built-in playback
- Learning curve for complex scores

## Best Use Cases
- Interactive music education apps
- Dynamic score generation
- Real-time notation editors
- Guitar tablature applications