# US-100: Accessibility — Keyboard-Only Painting Workflow

**As a** painter with limited fine motor control or pointer device access,
**I want to** paint and control all primary app functions using only the keyboard,
**So that** the application is usable regardless of my ability to operate a mouse or stylus.

## Personas
- **Primary:** P4 James Whitfield — as an educator he is responsible for ensuring tools are accessible to all students, including those with motor disabilities
- **Also relevant:** P5 Suki Tanaka, P6 Alex Kirchner (keyboard-centric power users)

## Acceptance Criteria
- [ ] All menu items, toolbar buttons, and panel controls are reachable via keyboard navigation (Tab, Shift+Tab, arrow keys, Enter/Space)
- [ ] A keyboard-controlled brush cursor can be moved across the canvas using arrow keys; stroke is applied while holding a designated key (e.g., Space)
- [ ] Brush size and opacity are adjustable via keyboard shortcuts (`[` / `]` for size, Shift+`[` / Shift+`]` for opacity) matching industry convention
- [ ] All dialogs (New Canvas, Export, Preferences) are fully operable without a pointer device
- [ ] Focus indicators are clearly visible on all interactive elements, meeting WCAG 2.1 AA contrast requirements for focus rings
- [ ] VoiceOver labels are provided for all controls, canvas region, and status bar fields
- [ ] The app passes macOS Accessibility Inspector audit with no critical violations

## Notes
Keyboard-driven brush cursor requires injecting synthetic stroke events into the painting pipeline from arrow key handlers — the canvas must not require `NSEvent` drag events exclusively. VoiceOver announcing canvas content is aspirational for v1; at minimum, all chrome controls must be VO-navigable. Test with VoiceOver enabled throughout development, not as a post-hoc audit.
