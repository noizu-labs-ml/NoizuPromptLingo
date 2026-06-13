# US-055: SPH Particle-Driven Fluid Dynamics for Wet Paint

**As a** technical artist building custom media types,
**I want to** wet paint to be driven by SPH (Smoothed Particle Hydrodynamics) particles that respond to gravity, viscosity, and surface tension forces,
**So that** paint flows, pools, and interacts with canvas geometry in a physically grounded way that Eulerian-only grid simulation cannot capture at the stroke level.

## Personas
- **Primary:** P6 Alex Kirchner — he needs the SPH layer to be accessible and parameterizable so custom media can define their own fluid properties
- **Also relevant:** P2 David Okafor, P1 Maya Chen

## Acceptance Criteria
- [ ] Wet paint strokes spawn Lagrangian SPH particles at the brush contact zone with velocity, mass, and medium-specific properties
- [ ] SPH particles apply pressure, viscosity, and surface-tension forces to neighboring particles per the SPH kernel formulation
- [ ] Particle state is projected onto the Eulerian VolumeLayer grid at each simulation tick (Particle-to-Volume step) for rendering and grid-fluid interaction
- [ ] Gravity projected onto the canvas plane causes paint to flow downhill on a tilted canvas, pooling at low points
- [ ] Per-medium SPH parameters (rest density, viscosity coefficient, surface tension coefficient) are defined in the media type spec and loaded at runtime

## Notes
SPH particles are 48 bytes each as noted in the architecture. The hybrid particle-in-cell approach means SPH handles fine-scale fluid behavior while the Eulerian grid handles diffusion and drying. Performance budget must allow thousands of active particles at 60 fps on M1 Pro; particle count limits per stroke may be needed.
