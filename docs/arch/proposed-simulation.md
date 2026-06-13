# Proposed Simulation Pipeline

## Dispatch Architecture

All 5 simulation phases run as compute encoders within a single `MTLCommandBuffer` per frame. The renderer dispatches simulation before compositing. When no wet paint exists (global dirty flag is false), simulation phases are skipped entirely.

```
Renderer.draw(in:)
  |
  +-- BrushEngine.flush() → BrushPoint buffer
  |
  +-- [if brush active or wetPaintExists]
  |     Encoder 1: deposit(brushPoints, volumeLayers, particles)
  |     Encoder 2: sphPhysics(particles, spatialHash)
  |     Encoder 3: particleToVolume(particles, volumeLayers)
  |     Encoder 4: gridFluid(volumeLayers, pingPongTextures)
  |     Encoder 5: drying(volumeLayers, canvasProps, dt)
  |
  +-- [every frame]
        Encoder 6: render(volumeLayers, canvasProps, viewParams) → drawable
```

## Phase Details

### Phase 1: Deposition

**Kernel:** `deposit`
**Dispatch:** Per BrushPoint (1D, up to ~4K points per frame)

Reads `BrushPoint` array and `BrushParams`. For each point:
1. Compute stamp footprint (circle for round, oriented rect for flat)
2. Apply pressure-to-opacity and pressure-to-size curves
3. Write absorption color to active layer's VolumeLayer fields
4. Set wetness, viscosity, depth based on media type
5. Spawn SPH particles at stamp edges (for wet media only)

Cross-media rejection (US-057): if target pixel's top occupied layer has incompatible dried media (e.g., watercolor on dried oil), deposition is rejected (opacity clamped to 0).

### Phase 2: SPH Physics

**Kernel:** `sphPhysics` (two sub-passes)
**Dispatch:** Per particle (1D)

**Sub-pass A: Spatial hash build**
- Hash each particle position to grid cell
- Atomic increment cell count
- Prefix sum for offsets (parallel scan)
- Scatter particles into sorted array

**Sub-pass B: Force computation**
- For each particle, iterate neighbors in 9 surrounding cells
- Compute pressure gradient (Tait's equation)
- Compute viscosity force (Laplacian)
- Compute surface tension force (color field gradient)
- Semi-Lagrangian advection: update velocity, then position

Particles with `life <= 0` or `wetness <= threshold` are retired (moved to free-list).

### Phase 3: Particle → Volume Integration

**Kernel:** `particleToVolume`
**Dispatch:** Per particle (1D)

Each particle splats its state back to the VolumeLayer grid using a smooth SPH kernel:
- Accumulate color (weighted by kernel weight × mass)
- Accumulate wetness
- Write velocity to VolumeLayer velocity_x/y

This is dispatch-per-particle (not per-pixel) because particles are sparse. Uses atomic adds on the VolumeLayer buffer.

### Phase 4: Grid Fluid Dynamics

**Kernel:** `gridFluid` (iterated)
**Dispatch:** Per pixel (2D, 16×16 threadgroups)

Three sub-steps using ping-pong double-buffered textures:
1. **Semi-Lagrangian advection** — trace velocity backward, sample source
2. **Jacobi diffusion** — 4-8 iterations for implicit diffusion
3. **Mass conservation** — enforce total pigment mass per region

Only operates on pixels where `wetness > threshold`. Edge detection at wet/dry boundaries triggers surface tension forces.

### Phase 5: Drying

**Kernel:** `drying`
**Dispatch:** Per pixel (2D, 16×16 threadgroups)

Per-pixel, per-layer:
1. Read canvas absorbency from props texture
2. Compute drying rate: `baserate × mediaMultiplier × absorbency × dt`
3. Reduce wetness; when wetness hits 0, set hardness to 1.0
4. Edge darkening: at wet/dry boundaries, increase color concentration (pigment migration)

Medium-specific rates:

| Medium | Base Rate Multiplier | Notes |
|--------|---------------------|-------|
| Watercolor | 1.0× | Standard reference rate |
| Oil | 0.05× | Very slow (oxidation, not evaporation) |
| Acrylic | 8.0× | Fast polymerization; two-phase (workable → locked) |
| Charcoal | instant | No drying; immediately static |
| Pastel | instant | No drying; immediately static |

### Instant-Dry (US-060)

Keyboard shortcut sets all wet pixels to `wetness = 0, hardness = 1.0` in a single compute pass. Retires all active SPH particles. Skips edge darkening.

## Performance Considerations

- SPH is the most expensive phase — particle count is the primary scaling knob
- Spatial hash rebuild is O(N) but has poor GPU occupancy for small N; batch with other work
- Grid fluid Jacobi iterations are the second bottleneck — 4 iterations sufficient for visual quality
- Drying is cheap (per-pixel multiply) — always runs
- Simulation can run at half rate (30 Hz) while rendering stays at 60 FPS if needed
