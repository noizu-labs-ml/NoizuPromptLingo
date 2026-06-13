# US-059: Surface Tension Effects on Paint Flow

**As a** watercolor illustrator,
**I want to** see surface tension cause paint to resist spreading at low volumes and then flow freely once a critical threshold is exceeded,
**So that** thin washes bead at the brush tip before releasing, and pools of paint hold their form on a flat canvas rather than spreading indefinitely, matching real aqueous paint behavior.

## Personas
- **Primary:** P1 Maya Chen — surface tension governs how loaded brushes release paint and how pools hold shape; it is fundamental to watercolor control
- **Also relevant:** P2 David Okafor, P6 Alex Kirchner

## Acceptance Criteria
- [ ] A surface tension coefficient parameter is defined per media type and applied in the SPH physics stage as a cohesive force between neighboring particles
- [ ] Below the surface tension threshold, small paint deposits resist spreading and maintain a compact form; above the threshold, they flow freely
- [ ] Paint at a canvas edge or a dry/wet boundary forms a stable meniscus-like edge rather than flowing past it indefinitely
- [ ] Surface tension is reduced when surfactant additives (e.g., ox gall) are applied; this increases flow and reduces beading behavior
- [ ] Canvas roughness reduces effective surface tension locally: rough surfaces disrupt the water film and allow paint to spread at lower volumes

## Notes
Surface tension in the SPH model is implemented as a Laplace pressure term proportional to local curvature of the particle distribution. Surfactant effects are a future enhancement; for MVP, surface tension coefficient is a fixed per-media parameter. The interaction between surface tension and canvas texture roughness requires the SPH particles to sample the canvas roughness texture during force computation.
