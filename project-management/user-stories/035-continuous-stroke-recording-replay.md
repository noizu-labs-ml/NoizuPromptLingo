# US-035: Continuous Stroke Recording for Replay

**As a** art educator demonstrating painting techniques,
**I want to** record all brush strokes in a session and replay them at variable speed,
**So that** I can show students the exact sequence and technique of a painting from start to finish.

## Personas
- **Primary:** P4 James Whitfield — needs to record and replay demos for classroom and async teaching content
- **Also relevant:** P6 Alex Kirchner, P3 Lena Vasquez

## Acceptance Criteria
- [ ] A "Record" mode captures all input events (position, pressure, tilt, tool, brush parameters, timestamps) in a compact binary format
- [ ] Recorded sessions are saved to disk as `.trp` (TheRobotPaints replay) files
- [ ] Replay can be played back at 0.25×, 0.5×, 1×, 2×, 4× speed with a scrub bar for random access
- [ ] Replay is deterministic: replaying the same `.trp` file produces pixel-identical output every time
- [ ] Determinism requires the spatial noise functions in dry brush (US-029) and fan brush (US-032) to be seeded by canvas position, not by system time or session state
- [ ] Recording adds no measurable overhead to the painting pipeline (< 0.5ms per stroke event)
- [ ] Replay files include metadata: date, canvas dimensions, brush presets used, total duration

## Notes
Deterministic replay is the key technical constraint. Any randomness in the rendering pipeline (bristle jitter, SPH particle initial conditions) must be seeded from reproducible sources. This story has architectural implications for the noise/RNG strategy used throughout the brush system.
