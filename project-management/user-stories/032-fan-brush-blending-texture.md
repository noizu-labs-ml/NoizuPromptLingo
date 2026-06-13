# US-032: Fan Brush for Blending and Texture

**As a** painter who uses fan brushes to blend transitions and create foliage and hair textures,
**I want to** paint with a fan brush that deposits multiple separated bristle clusters in a spread arc,
**So that** I can achieve the distinctive streaked blending and organic texture marks of a physical fan brush.

## Personas
- **Primary:** P2 David Okafor — uses fan brush for sky blending and final surface texture passes in oil work
- **Also relevant:** P3 Lena Vasquez, P6 Alex Kirchner

## Acceptance Criteria
- [ ] The fan brush dab consists of N configurable bristle clusters (default: 9) arranged in a semicircular arc
- [ ] The arc spread angle is configurable (default: 120°) and the arc rotates to align with stroke direction
- [ ] Each bristle cluster deposits paint independently, producing visible separation between marks
- [ ] When dragged slowly over wet paint, the fan brush blends colors laterally across the bristle spread without depositing new pigment at low flow settings
- [ ] Pressure controls the width of the bristle cluster spread: high pressure fans out wider, low pressure compresses the arc
- [ ] Fan brush supports dry brush mode (US-029) for foliage and hair texture generation

## Notes
Bristle cluster positions within the arc should be dithered slightly with spatial noise (same deterministic approach as US-029) to avoid mechanical regularity. The blending behavior at low flow requires reading existing VolumeLayer data in the MSL kernel before writing, which implies a read-modify-write pass.
