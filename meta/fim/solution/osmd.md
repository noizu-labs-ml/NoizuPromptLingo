# OSMD (OpenSheetMusicDisplay) - MusicXML Display

## Overview
TypeScript/JavaScript library for rendering MusicXML scores in browsers using VexFlow.

## Installation
```bash
npm install opensheetmusicdisplay
# or
<script src="https://cdn.jsdelivr.net/npm/opensheetmusicdisplay/build/opensheetmusicdisplay.min.js"></script>
```

## Minimal Example
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

// Load from string
async function loadFromString(xmlString) {
  await osmd.load(xmlString);
  osmd.zoom = 0.8;
  await osmd.render();
}

// Handle cursor for playback
osmd.cursor.show();
osmd.cursor.next(); // Move to next note
```

## Strengths
- Excellent MusicXML support
- Automatic layout and formatting
- Built on VexFlow with higher-level API
- Supports most MusicXML features

## Limitations
- Larger bundle size than VexFlow alone
- Limited customization compared to raw VexFlow
- No built-in audio playback

## Best Use Cases
- MusicXML file viewers
- Digital sheet music libraries
- Score sharing platforms
- Music analysis tools
- Integration with notation software exports