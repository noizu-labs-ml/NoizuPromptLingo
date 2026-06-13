# US-039: Sub-16ms Input-to-Pixel Latency

**As a** plein air sketcher painting fast gestural strokes,
**I want to** see paint appear on the canvas within 16ms of my stylus or mouse movement,
**So that** the stroke feels physically connected to my hand and I can work at full speed without the stroke lagging behind my input.

## Personas
- **Primary:** P7 Priya Sharma — sub-16ms latency is an explicit requirement for her gestural plein air workflow
- **Also relevant:** P1 Maya Chen, P2 David Okafor, P3 Lena Vasquez

## Acceptance Criteria
- [ ] End-to-end latency from OS input event to pixels committed to the MTKView drawable is ≤ 16ms at 60Hz and ≤ 8ms at 120Hz on supported hardware
- [ ] Latency is measured and reported in a developer diagnostics overlay (Cmd+Opt+L) showing a per-frame histogram
- [ ] The stroke rendering pipeline executes entirely on the GPU (no CPU readback in the hot path)
- [ ] Apple Pencil Pro low-latency prediction (predicted touches API) is used to pre-render stroke positions for frames where real input has not yet arrived
- [ ] Predicted stroke positions are corrected when actual input arrives (no visible ghost artifacts after correction)
- [ ] Latency target is met on the minimum supported hardware (Apple Silicon M1) at 4K canvas resolution
- [ ] Latency regression tests run as part of CI using a synthetic input playback harness

## Notes
This is a non-functional performance requirement that constrains every story in this domain. Architectural decisions (GPU-only pipeline, no synchronous CPU dispatch, Metal event-driven rendering) must be validated against this requirement before the brush system is considered shippable.
