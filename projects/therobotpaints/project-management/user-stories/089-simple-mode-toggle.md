# US-089: Simple Mode Toggle (Hide Advanced Parameters)

**As a** hobbyist painter who finds physics sliders overwhelming,
**I want to** toggle a Simple Mode that hides advanced simulation parameters,
**So that** I can focus on painting without being distracted by controls I don't understand.

## Personas
- **Primary:** P5 Suki Tanaka — new to digital painting; exposed simulation parameters create decision paralysis and reduce enjoyment
- **Also relevant:** P2 David Okafor (for student-facing demos), P7 Priya Sharma

## Acceptance Criteria
- [ ] A Simple/Advanced toggle is accessible from the View menu and a persistent button in the toolbar
- [ ] Simple Mode hides: viscosity, absorption coefficient, evaporation rate, pigment granulation, and all debug controls
- [ ] Simple Mode retains: brush size, opacity, color picker, layer visibility, and basic media selector
- [ ] Switching between modes is instant with no canvas or simulation state change
- [ ] The app defaults to Simple Mode on first launch; Advanced Mode is opt-in
- [ ] Simple Mode state persists across launches; switching to Advanced Mode shows a one-time tooltip explaining the new controls

## Notes
The UI should not destroy hidden controls' state — sliders retain their values when hidden. Simple Mode should be implemented via a single `@EnvironmentObject` or `@AppStorage` boolean that gates rendering, not by removing view nodes.
