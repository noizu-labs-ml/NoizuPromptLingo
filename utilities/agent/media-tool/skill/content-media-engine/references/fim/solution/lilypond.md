# LilyPond - Music Engraving

## Overview
Professional music engraving program producing publication-quality sheet music via text input.

## Installation
```bash
# macOS
brew install lilypond

# Ubuntu/Debian
sudo apt-get install lilypond

# Windows - Download installer from lilypond.org
```

## Minimal Example
```lilypond
\version "2.24.0"
\header {
  title = "Simple Melody"
  composer = "Example"
}

\relative c' {
  \clef treble
  \time 4/4
  \key c \major

  c4 d e f |
  g4 a b c |
  c2 g |
  c1 \bar "|."
}

% Compile: lilypond example.ly
% Output: example.pdf
```

## Web Integration
```javascript
// Using LilyPond via web service
async function compileLilyPond(code) {
  const response = await fetch('https://www.lilybin.com/compile', {
    method: 'POST',
    body: JSON.stringify({ code }),
    headers: { 'Content-Type': 'application/json' }
  });
  const result = await response.json();
  return result.pdf_url; // Returns PDF URL
}

// Or use ly2video for animated scores
// ly2video --ly score.ly --video-file output.mp4
```

## Strengths
- Publication-quality engraving
- Extremely powerful and flexible
- Excellent for complex classical scores
- Text-based version control friendly

## Limitations
- Steep learning curve
- Server-side processing required for web
- Not suitable for real-time rendering

## Best Use Cases
- Music publishing
- Academic papers with musical examples
- Complex orchestral scores
- Automated score generation from algorithms
- Archival-quality notation