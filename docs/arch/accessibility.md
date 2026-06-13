# Accessibility Architecture

## Design Principle

Blind-first, sighted-compatible. Every feature works without vision. Visual presentation is additive — it enhances but never gates functionality. If a feature can't be announced by a screen reader, it doesn't exist.

## Target Screen Readers

- NVDA + Firefox
- JAWS + Chrome
- VoiceOver + Safari (macOS/iOS)

## ARIA Live Region Channels

Three dedicated channels, always present in the DOM:

### Narrative Channel
```html
<div role="log" aria-live="polite" aria-atomic="false" aria-relevant="additions" aria-label="Story">
```
Receives: room descriptions, NPC dialogue, quest narrative, action outcomes, physics descriptions, crafting results, discovery/lore text. Append-only — content is never replaced.

### Alert Channel
```html
<div role="alert" aria-live="assertive">
```
Reserved for genuine urgency: damage taken, player death, connection loss. Must represent < 5% of all events.

### Status Channel
```html
<div role="status" aria-live="polite">
```
Passive state: HP changes, buff/debuff application/expiry, time-of-day transitions, economy notifications.

## Write Rules

- One complete thought per write (paragraph or short sequence)
- Never update mid-sentence — screen readers will re-read partial content
- Batch related updates: a combat round is one announcement, not five separate hits
- Complete sentences only — never stream character-by-character
- Assertive reserved for genuine urgency

## Focus Management

The command input (`<input id="command-input">`) is home base. Focus returns here after every resolved action:

| Event | Focus Behavior |
|-------|---------------|
| User types command | Stays on input |
| Game responds | Narrative appends (polite) — focus stays |
| Combat alert | Assertive fires — focus stays |
| Modal dialog | Focus traps in dialog; on dismiss returns to input |
| Page navigation | Auto-focus input after route change |

## Navigation Structure

### Landmarks
- `<main>` — "Game" (narrative, actions, command input)
- `<aside>` — "Character" (stats, equipment, effects)
- `<header>` — Skip links
- `<footer>` — Connection status, settings

### Heading Hierarchy (max h3)
```
h1  [Location Name]
  h2  Story
  h2  Available Actions
  h2  Stats
  h2  Equipment
  h2  Effects
    h3  [Sub-sections as needed]
```

### Skip Links (first focusable elements)
1. "Skip to story" — focuses narrative log (`tabindex="-1"`)
2. "Skip to command input" — focuses input field

## Keyboard Contract

| Key | Context | Action |
|-----|---------|--------|
| Enter | Command input | Submit command |
| Up/Down | Command input | Command history |
| Arrow keys | Choice menu | Navigate options |
| Enter | Choice menu | Select option |
| Escape | Modal/menu | Close, return to input |
| Tab | Global | Move between regions |
| / | Not in input | Focus command input |

## Audio Strategy

Audio is atmospheric, never informational. The game is fully playable with audio muted.

- Ambient soundscapes per location
- Physics event sounds synchronized with text descriptions
- Optional spatial audio for directional cues
