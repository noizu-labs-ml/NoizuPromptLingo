# US-009: 60 FPS Rendering on Apple Silicon

**As a** plein air sketch artist,
**I want to** experience smooth, uninterrupted canvas rendering at all times,
**So that** stroke feedback feels immediate and I can work at speed without perceptible lag breaking my gestural flow.

## Personas
- **Primary:** Priya Sharma — fast gestural work is broken by any frame drop; the canvas must respond as instantly as physical media
- **Also relevant:** Lena Vasquez, Suki Tanaka

## Acceptance Criteria
- [ ] The Metal render pipeline sustains 60 FPS at 2K canvas resolution on M1 or later Apple Silicon
- [ ] Frame time budget is 16.6 ms end-to-end: compute dispatch, compositor, and blit to drawable
- [ ] Frame rate is measured via `CADisplayLink` and the rolling 5-frame average is surfaced in the debug HUD
- [ ] A performance regression is flagged if average frame time exceeds 20 ms during CI profiling runs
- [ ] The render loop uses `preferredFramesPerSecond = 60` and respects ProMotion (120 Hz) when available on supported hardware
- [ ] No GPU pipeline stalls occur due to triple-buffering; at least 3 frames of in-flight command buffers are maintained

## Notes
Apple Silicon's unified memory architecture means no PCIe transfer cost for texture data; the pipeline should leverage this by keeping all VolumeLayer textures in GPU-addressable shared memory. The CI performance gate should use `xctrace` or a lightweight frame-time assertion in the test target.
