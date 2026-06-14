# AlphaTab - Guitar Tablature Rendering

## Overview
Cross-platform music notation and guitar tablature rendering engine with audio playback.

## Installation
```bash
npm install @coderline/alphatab
# or
<script src="https://cdn.jsdelivr.net/npm/@coderline/alphatab@latest/dist/alphaTab.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@coderline/alphatab@latest/dist/alphaTab.min.css">
```

## Minimal Example
```javascript
// Initialize AlphaTab
const element = document.getElementById('alphatab');
const api = new alphaTab.AlphaTabApi(element, {
  file: 'path/to/song.gp5',
  player: {
    enablePlayer: true,
    enableCursor: true,
    soundFont: 'https://cdn.jsdelivr.net/npm/@coderline/alphatab@latest/dist/soundfont/sonivox.sf2'
  },
  display: {
    layoutMode: 'page',
    staveProfile: 'tab'
  }
});

// Load from Guitar Pro format
api.load(guitarProData);

// Control playback
api.playPause();
api.stop();
api.isPlaying; // Check status

// Load MusicXML or GP files
const response = await fetch('song.musicxml');
const data = await response.arrayBuffer();
api.load(new Uint8Array(data));
```

## Strengths
- Excellent Guitar Pro format support (GP3-GP7)
- Built-in audio synthesis and playback
- Supports both standard notation and tablature
- Cross-platform (Web, .NET, Android)

## Limitations
- Focused on guitar/bass notation
- Large download for soundfonts
- Complex API for simple use cases

## Best Use Cases
- Guitar learning applications
- Guitar Pro file viewers
- Tab sharing platforms
- Music practice tools with playback
- Band notation software