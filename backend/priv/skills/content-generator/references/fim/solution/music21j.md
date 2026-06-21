# Music21j - JavaScript Music Analysis Toolkit

## Overview
JavaScript port of MIT's music21 Python toolkit for computer-aided musicology, enabling music analysis and visualization in the browser.
- Official Site: https://web.mit.edu/music21/music21j
- GitHub: https://github.com/cuthbertLab/music21j

## Installation
```html
<!-- CDN -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/music21j/0.9.43/music21.min.js"></script>

<!-- Or via npm -->
npm install music21j
```

## Minimal Example
```javascript
// Create and display a note
const n = new music21.note.Note('C4');
n.duration.quarterLength = 2;

// Create a stream (musical container)
const s = new music21.stream.Stream();
s.append(n);
s.append(new music21.note.Note('D4'));
s.append(new music21.note.Note('E4'));

// Display in div element
s.appendNewDOM(document.getElementById('music-container'));

// Analyze key
const key = s.analyze('key');
console.log('Key:', key.toString());

// Parse MusicXML
const xml = await music21.musicxml.parse(xmlString);
xml.renderOptions.events.click = (el) => {
  el.playNote();
};
xml.appendNewDOM(document.body);

// MIDI playback
s.playStream();
```

## Strengths
- Direct port of established Python music21 toolkit
- Strong music theory and analysis capabilities
- MIT academic backing and research foundation
- MusicXML import/export support
- Built-in VexFlow for notation rendering

## Limitations
- Smaller feature set than Python version
- Limited documentation compared to parent library
- Performance constraints in browser environment
- Fewer corpus and analysis tools

## Best Use Cases
- Music education and theory applications
- Basic music analysis in browser
- Interactive music notation with analysis
- Academic musicology tools
- Simple notation editing

## NPL-FIM Integration
```yaml
category: music
subcategory: analysis
rendering: vexflow
audio: web-audio-api
format: [musicxml, midi]
interaction: high
academic: true
```