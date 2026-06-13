# US-086: Export as TIFF for Print Production

**As a** professional digital illustrator delivering to print vendors,
**I want to** export my painting as a TIFF file with lossless compression,
**So that** I can hand off production-quality files that meet industry print standards without quality degradation.

## Personas
- **Primary:** P1 Maya Chen — print vendors require TIFF; lossy PNG is not acceptable for final deliverables
- **Also relevant:** P3 Lena Vasquez

## Acceptance Criteria
- [ ] File > Export > TIFF presents a save panel with `.tiff` extension and compression options (None, LZW, ZIP)
- [ ] Exported TIFF preserves full bit depth (16-bit per channel if canvas is rendering at float precision)
- [ ] TIFF export supports optional embedded ICC color profile (sRGB by default; P3 if display is P3)
- [ ] Resolution metadata (DPI) is embedded in the TIFF header, configurable in the export dialog (default 300 DPI)
- [ ] Export dialog shows resulting dimensions in both pixels and inches at the selected DPI
- [ ] Export completes without UI blocking; cancellation is supported

## Notes
macOS `CGImageDestination` supports TIFF natively; use it for format compliance rather than a custom encoder. 16-bit TIFF export requires the Metal pipeline to render to a half-float texture and read it back accurately.
