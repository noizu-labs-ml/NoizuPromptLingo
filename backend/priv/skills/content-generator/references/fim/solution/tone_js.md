# Tone.js - Web Audio Framework

## Overview
Web Audio framework for creating interactive music in the browser with synthesis and effects.

## Installation
```bash
npm install tone
# or
<script src="https://cdn.jsdelivr.net/npm/tone@latest/build/Tone.min.js"></script>
```

## Minimal Example
```javascript
import * as Tone from 'tone';

// Simple synth
const synth = new Tone.Synth().toDestination();

// Play single note
synth.triggerAttackRelease('C4', '8n');

// Play sequence
const sequence = new Tone.Sequence((time, note) => {
  synth.triggerAttackRelease(note, '8n', time);
}, ['C4', 'D4', 'E4', 'F4'], '4n');

// Start transport
await Tone.start();
Tone.Transport.start();
sequence.start(0);

// Load and play samples
const sampler = new Tone.Sampler({
  urls: {
    'C4': 'C4.mp3',
    'D#4': 'Ds4.mp3',
    'F#4': 'Fs4.mp3'
  },
  baseUrl: 'https://tonejs.github.io/audio/salamander/'
}).toDestination();

// Effects chain
const reverb = new Tone.Reverb(2).toDestination();
synth.connect(reverb);
```

## Strengths
- Comprehensive audio synthesis capabilities
- Precise timing and scheduling
- Rich effects and processing options
- Works with any notation library for playback

## Limitations
- No notation rendering (audio only)
- Requires Web Audio API support
- Learning curve for synthesis concepts

## Best Use Cases
- Music playback for notation libraries
- Interactive music applications
- Generative music systems
- Audio effects and processing
- MIDI-like sequencing in browsers