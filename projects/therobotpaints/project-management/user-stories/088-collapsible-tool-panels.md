# US-088: Collapsible Tool Panels (Brush, Layers, Color)

**As a** plein air sketch artist working on a small screen,
**I want to** collapse tool panels I'm not currently using,
**So that** I can maximize canvas space while keeping the panels accessible without switching modes.

## Personas
- **Primary:** P7 Priya Sharma — MacBook screen space is limited outdoors; needs maximum canvas area during sketching sprints
- **Also relevant:** P5 Suki Tanaka, P1 Maya Chen

## Acceptance Criteria
- [ ] Each major panel (Brush, Layers, Color) has a collapse/expand toggle (chevron icon or panel header click)
- [ ] Collapsed panels show only their header bar; expanded panels show full controls
- [ ] Panel collapse state persists across app launches via UserDefaults
- [ ] Panels can be collapsed individually; collapsing all panels gives near-full-bleed canvas view
- [ ] Keyboard shortcuts (e.g., B for Brush, L for Layers, C for Color panel) toggle collapse state
- [ ] Animation duration for collapse/expand is under 150ms and respects Reduce Motion accessibility setting

## Notes
SwiftUI disclosure groups or custom collapse containers are both viable; prefer a solution that doesn't reflow the entire window layout on toggle. Panel minimum heights when expanded should be clamped to avoid UI breakage on small windows.
