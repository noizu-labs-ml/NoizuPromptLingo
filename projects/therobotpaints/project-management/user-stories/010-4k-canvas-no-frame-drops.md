# US-010: 4K Canvas Support Without Frame Drops

**As a** concept artist producing print-ready artwork,
**I want to** work on a 4096 × 4096 canvas at 60 FPS,
**So that** I can deliver high-resolution deliverables without switching to a lower-resolution proxy during painting sessions.

## Personas
- **Primary:** Lena Vasquez — 4K output is a professional requirement; proxy workflows break her iteration speed and introduce resampling artifacts
- **Also relevant:** David Okafor, Alex Kirchner

## Acceptance Criteria
- [ ] A 4096 × 4096 canvas with 8 VolumeLayer channels (32 bytes FP16 per pixel) can be allocated without exceeding 2 GB GPU memory on M2 or later
- [ ] The compute compositor sustains 60 FPS on a 4K canvas on M2 Pro or better
- [ ] Frame time on M1 base (8 GB) at 4K does not exceed 33 ms (30 FPS floor)
- [ ] Canvas creation dialog allows custom resolution input up to 8192 × 8192
- [ ] Memory allocation failure produces a user-readable error dialog rather than a crash
- [ ] The render pipeline tiles large canvases into compute threadgroups of 16 × 16 for efficient GPU utilization

## Notes
4K × 8 layers × 32 B = ~4 GB raw; FP16 halves this to ~2 GB. Tiled threadgroup dispatch must be validated to avoid out-of-bounds texture writes at canvas edges where canvas dimensions are not multiples of the tile size.
