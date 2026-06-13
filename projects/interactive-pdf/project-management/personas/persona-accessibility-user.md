# Persona: James Okafor — Accessibility-First Reader

## Profile
- **Age:** 44
- **Role:** Policy Analyst, Government Agency
- **Environment:** Mac Mini with large monitor (low vision), always uses VoiceOver
- **Tech Comfort:** Medium-High — expert with assistive tech, frustrated by non-accessible apps

## Goals
- Read complex policy documents, reports, and legal PDFs without visual strain
- Navigate documents entirely by voice — no mouse required
- Get high-quality, natural TTS (not robotic screen-reader voice)
- Ask questions without losing his place in the document

## Frustrations
- Standard PDF readers are accessibility nightmares — broken tab order, unlabeled figures, garbled extraction
- VoiceOver on PDFs reads column layout as a single stream, destroying comprehension
- No way to ask "what was the budget figure in the introduction?" without scrolling back manually
- TTS voices in screen readers sound terrible and fatigue him over long sessions

## Behaviors
- Keyboard-first always; uses VoiceOver gestures on trackpad
- Memorizes document structure via outline before reading linearly
- Prefers slower, deliberate TTS with clear sentence separation
- Replays passages frequently

## Key Scenarios
1. Navigates chapter outline entirely by keyboard, selects a section, begins playback — never touches mouse
2. Pauses and asks "go back to the recommendation section" — app jumps there and resumes reading
3. Asks "what is the full name of DOGE?" when acronym is first used — app finds the definition in the doc

## Acceptance Criteria
- Full keyboard navigation, VoiceOver-compatible UI
- Voice commands work without push-to-talk (always-listening mode)
- Zero visual-only information (every action has a spoken equivalent)
- WCAG 2.2 AA minimum, AAA preferred
