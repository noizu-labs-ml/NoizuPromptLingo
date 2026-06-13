# David Okafor — Traditional Painter Going Digital

**Type:** Primary  
**Age:** 45 | **Location:** Lagos / London  
**Occupation:** Gallery painter (oils, acrylics), part-time art instructor  
**Platform:** Mac Studio M2 Ultra, considering iPad  

> "Every digital painting app feels like I'm drawing with markers. I want to push paint around."

## Goals

- Translate his impasto oil technique to digital without losing physicality
- Use digital as a sketch/study tool before committing to expensive canvas and paint
- Experiment with color studies faster than mixing physical pigments
- Create demo recordings for his online teaching practice

## Frustrations

- No digital tool simulates paint thickness or how light catches impasto ridges
- Digital color mixing is additive RGB — mixing yellow and blue gives grey, not green
- Can't feel resistance, drag, or the thixotropic behavior of oil paint
- Palette knife and spatula tools in existing apps are just smudge with a shape mask

## Usage Context

- Short study sessions (30-60 min) to plan compositions before going to canvas
- Thick, gestural application — rarely uses thin glazes digitally
- Wants to see how light direction changes the look of built-up paint
- Shares screen recordings with students to demonstrate technique

## Key Features He'd Use

- Oil media with thixotropic viscosity and slow drying
- Impasto depth rendering with directional lighting
- Absorption color model (Beer-Lambert)
- Light direction controls for studying form

## Design Implications

- Light direction sliders are critical (already implemented — good fit)
- Depth visualization must be convincing at normal zoom, not just extreme zoom
- Brush drag/resistance must map to pressure sensitivity
- Undo granularity matters — he wants to scrape back one stroke, not ten
