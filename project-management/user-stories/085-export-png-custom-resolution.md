# US-085: Export as PNG at Custom Resolution (2x, 4x for Print)

**As a** digital illustrator preparing print-ready assets,
**I want to** export my painting as a PNG at 2x or 4x the canvas resolution,
**So that** I can deliver high-DPI files suitable for large-format print without painting at prohibitively large canvas sizes.

## Personas
- **Primary:** P1 Maya Chen — routinely delivers print assets; needs upscaled export without re-doing work at larger canvas
- **Also relevant:** P3 Lena Vasquez

## Acceptance Criteria
- [ ] File > Export > PNG offers scale options: 1x, 2x, 4x, and a custom DPI entry field
- [ ] Upscaling uses high-quality bicubic or Metal-accelerated super-sampling; no nearest-neighbor artifacts
- [ ] The export dialog shows the resulting pixel dimensions and estimated file size before confirming
- [ ] Custom DPI field accepts values from 72 to 1200 and computes output dimensions accordingly
- [ ] Exported file name defaults to `{canvas-name}@{scale}x.png` (e.g., `sunrise@2x.png`)
- [ ] Export does not alter the working canvas or its resolution

## Notes
4x export of a 4096×4096 canvas produces a 16384×16384 PNG (~768 MB uncompressed); the system must warn users of large output sizes and allow cancellation mid-export. Metal's texture scaling capabilities should be preferred over CPU-side resizing.
