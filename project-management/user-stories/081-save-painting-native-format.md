# US-081: Save Painting to Native File Format

**As a** professional digital illustrator,
**I want to** save my painting to a native file format that preserves all layer and physics state,
**So that** I can close the app and return to exactly where I left off without losing simulation fidelity.

## Personas
- **Primary:** P1 Maya Chen — needs reliable save to protect hours of work and maintain layer/physics state for iteration
- **Also relevant:** P3 Lena Vasquez, P4 James Whitfield

## Acceptance Criteria
- [ ] Cmd+S triggers save; prompts for file location on first save, overwrites on subsequent saves
- [ ] Saved file encodes all layer pixel data, physics simulation state (wetness, pigment concentration, velocity fields), canvas metadata (size, paper type, media type), and app version
- [ ] File extension is `.trp` (TheRobotPaints native format); format is documented internally
- [ ] Save completes without blocking the UI (async write with progress indicator for large canvases)
- [ ] Saved file can be reopened and resumes simulation from the exact saved state

## Notes
No serialization infrastructure exists yet; this requires defining the `.trp` binary or structured format (e.g., MessagePack or custom flatbuffer). Physics state snapshots must capture Metal buffer contents at save time.
