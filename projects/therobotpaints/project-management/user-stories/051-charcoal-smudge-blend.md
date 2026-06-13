# US-051: Charcoal Smudge and Blend with Finger/Tool

**As a** plein air sketch artist,
**I want to** smudge deposited charcoal with a finger or blending stump tool,
**So that** I can soften edges, create tonal gradients, and blend areas of charcoal in the same gestural way I work on real paper.

## Personas
- **Primary:** P7 Priya Sharma — smudging is essential for building tonal structure in her charcoal underdrawings before washes
- **Also relevant:** P4 James Whitfield, P5 Suki Tanaka

## Acceptance Criteria
- [ ] A dedicated smudge/blend tool mode is available when charcoal medium is active
- [ ] Applying the smudge tool over charcoal particles displaces them laterally in the direction of the stroke, softening the mark boundary
- [ ] Smudge intensity scales with stylus pressure; light pressure blurs slightly, heavy pressure moves particles significantly further
- [ ] Smudging does not add or remove total charcoal mass from the canvas; it redistributes existing particles within the affected radius
- [ ] Repeated smudging in the same area approaches a smooth tonal gradient with no visible particle grain at normal zoom levels

## Notes
Smudge displacement is implemented as a velocity field impulse applied to charcoal particles in the SPH layer, with a friction-damped settling step to prevent indefinite spreading. The tool cursor shows the smudge radius to help artists judge coverage. Smudge behavior on partially fixed charcoal (post-fixative, US-053) should have no effect.
