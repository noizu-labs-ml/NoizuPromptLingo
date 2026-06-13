# US-046: Oil Impasto Depth Buildup

**As a** traditional oil painter,
**I want to** build up thick ridges and peaks of paint through repeated loaded strokes,
**So that** I can create tactile impasto texture with genuine three-dimensional depth that catches simulated light, matching the sculptural quality of real impasto technique.

## Personas
- **Primary:** P2 David Okafor — impasto is his signature technique; depth accumulation and lighting are central to his work
- **Also relevant:** P3 Lena Vasquez, P6 Alex Kirchner

## Acceptance Criteria
- [ ] Each paint deposit adds to a height field stored in the VolumeLayer; multiple deposits accumulate rather than replace
- [ ] Height values exceeding a threshold produce visible surface relief in the render via normal map derivation from the height field
- [ ] Simulated directional light interacts with the height normal to produce highlights on ridges and shadows in valleys
- [ ] A palette knife tool mode displaces and sculpts accumulated paint height rather than adding new pigment
- [ ] Maximum height accumulation is capped at a physically plausible limit (e.g., equivalent to several millimeters of paint) to prevent artifacts

## Notes
Height accumulation is stored in a dedicated channel of the 8-layer VolumeLayer per pixel. Normal map derivation for impasto lighting runs in the Render stage, not the physics pipeline, to avoid feedback loops. Palette knife displacement uses the existing SPH particle system to push paint mass laterally.
