# US-087: New Canvas Creation Dialog

**As a** concept artist starting fresh work,
**I want to** configure a new canvas with specific dimensions, paper type, and media before painting,
**So that** the simulation is tuned to my intended output medium from the very first stroke.

## Personas
- **Primary:** P3 Lena Vasquez — batch projects require different canvas specs; needs quick, repeatable setup
- **Also relevant:** P1 Maya Chen, P2 David Okafor, P4 James Whitfield

## Acceptance Criteria
- [ ] File > New (Cmd+N) opens a dialog with fields: width, height (pixels or inches+DPI), paper type (smooth, cold press, hot press, canvas), and media preset (watercolor, oil, acrylic, ink)
- [ ] Preset templates are available (e.g., "A4 Print 300 DPI", "Social Square 1080px", "4K Concept") and user-saveable
- [ ] Changing paper type updates a live thumbnail preview showing texture character
- [ ] Media preset configures default physics parameters (viscosity, absorption, drying rate) documented in a tooltip
- [ ] Clicking Create replaces the current canvas (with unsaved-changes warning) and initializes the simulation with selected parameters
- [ ] Dialog remembers the last-used settings across app launches

## Notes
Paper type drives the normal map and absorption coefficient used in the physics shader; these parameters must be exposed through a structured `CanvasConfiguration` type rather than magic numbers in the dialog. Media preset maps to a named parameter bundle.
