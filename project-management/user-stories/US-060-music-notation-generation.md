---
id: US-060
title: "Generate music notation (ABC, LilyPond)"
slug: music-notation-generation
personas: [P-004]
epic: "Diagram & Text Formats"
priority: could-have
complexity: medium
tags: [music, abc, lilypond, notation]
---

# US-060: Generate music notation (ABC, LilyPond)

## User Story

**As a** game developer composing music
**I want to** generate music notation from text descriptions
**So that** I can produce lead sheets and full scores for game soundtracks

## Acceptance Criteria

- **Given** a `.media.prompt` with `text_format: abc`
  **When** generation runs
  **Then** a `.abc` file is produced with valid ABC notation

- **Given** `text_format: lilypond`
  **When** generation runs
  **Then** a `.ly` file is produced with valid LilyPond markup

## Notes
ABC is simpler for folk tunes. LilyPond handles full scores and parts.
