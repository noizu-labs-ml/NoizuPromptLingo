# US-022: Mouse/Trackpad Painting with Speed-Based Pressure Simulation

**As a** hobbyist painter without a drawing tablet,
**I want to** paint with a mouse or trackpad and have stroke speed simulate pressure variation,
**So that** I can still produce strokes with natural-feeling weight and dynamics without specialized hardware.

## Personas
- **Primary:** P5 Suki Tanaka — primary input device is mouse or trackpad; no tablet
- **Also relevant:** P4 James Whitfield

## Acceptance Criteria
- [ ] When no tablet is detected, the app automatically activates speed-based pressure simulation
- [ ] Slow cursor movement maps to high simulated pressure (larger, more opaque strokes); fast movement maps to low pressure (thinner, more transparent)
- [ ] The speed-to-pressure mapping curve is user-adjustable in Brush Settings
- [ ] Simulation can be manually toggled on/off regardless of input device
- [ ] Trackpad Force Touch (where available) supplements speed simulation with physical pressure data
- [ ] A visual indicator in the HUD shows the current simulated pressure value during a stroke

## Notes
Speed is computed from delta-position between consecutive NSEvent samples; a smoothing window (e.g., 5-sample rolling average) prevents jitter from dominating the pressure signal. This story does not require tablet hardware to test.
