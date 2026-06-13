# US-019: Customizable Background Color Behind Canvas

**As a** digital illustrator,
**I want to** set the background color displayed behind and around the canvas to a neutral grey I choose,
**So that** I can evaluate canvas colors against a perceptually neutral surround that matches my typical print or display viewing conditions.

## Personas
- **Primary:** Maya Chen — color accuracy during painting depends on the surround color; she uses 18% grey (L* ≈ 50) as her standard neutral to match print proofing conditions
- **Also relevant:** David Okafor, Lena Vasquez

## Acceptance Criteria
- [ ] Preferences > Canvas > Background Color opens a color picker for the area outside the canvas bounds
- [ ] Default background color is #404040 (dark neutral grey) matching professional painting application conventions
- [ ] Background color choice persists across sessions and is stored in user preferences (not per-document)
- [ ] Background color updates within one frame of being changed in the picker
- [ ] The checkerboard pattern (US-007) is replaced by the solid background color when a non-default color is active; checkerboard is only shown when the background is set to "Checkerboard" mode
- [ ] A preset list includes: Black, 18% Grey, 50% Grey, White, and Checkerboard
- [ ] Background color is independent of the canvas texture and does not bleed into canvas pixel data

## Notes
The background color is rendered as the clear color of the MTKView drawable before any canvas compositor pass executes. The "Checkerboard" mode is a special case that triggers the procedural checkerboard pass (US-007) instead of a solid clear. These two stories share the same preference key with a mode discriminator.
