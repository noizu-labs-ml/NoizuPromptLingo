# US-021: Pressure-Sensitive Brush Strokes (Tablet)

**As a** digital illustrator using a drawing tablet,
**I want to** have brush size, opacity, and flow respond to stylus pressure,
**So that** my strokes feel natural and expressive, matching the physical feedback of traditional media.

## Personas
- **Primary:** P1 Maya Chen — relies on pressure variation for watercolor edge control and wash gradients
- **Also relevant:** P2 David Okafor, P7 Priya Sharma

## Acceptance Criteria
- [ ] Stylus pressure (0.0–1.0 normalized) maps to configurable brush parameters: size, opacity, flow, or any combination
- [ ] Pressure curve is user-adjustable (linear, logarithmic, S-curve) via a curve editor
- [ ] Minimum and maximum pressure thresholds are configurable per brush preset
- [ ] Pressure data is sampled at the OS event rate (≥ 120 Hz on Apple Pencil / Wacom) and passed to the GPU stroke pipeline without decimation
- [ ] A pressure graph overlay (toggleable) displays live pressure values during a stroke for calibration

## Notes
Pressure input arrives via NSEvent or Apple Pencil touch events; the Metal stroke pipeline must consume normalized pressure per sample point before Catmull-Rom interpolation (US-023). Pressure must not be conflated with tilt — tilt is a separate future story.
