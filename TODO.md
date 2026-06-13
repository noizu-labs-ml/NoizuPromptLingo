# The Robot Paints — Implementation TODO

> Voxel-first build. All code written fresh (kopigajj docs as reference only).
> Milestone plan — each produces a running, testable app.

## Milestone 1: Voxel Canvas (Week 1)

**Goal**: See the canvas. Metal renders a lit, textured voxel grid.

- [ ] `Package.swift` — swift-tools-version: 6.0, macOS 14+, executable + test target
- [ ] `MetalEngine.swift` — `@unchecked Sendable` class: MTLDevice, MTLCommandQueue, pipeline cache, compilePipeline(), makeTexture()
- [ ] `ShaderHeader.swift` — `enum ShaderSource` with `static let header` MSL string: VolumeLayer (32B FP16), PixelVolume (272B), SimParams, RenderParams, LightParams, hash(), noise2d()
- [ ] `ShaderCanvasInit.swift` — kernel: procedural canvas weave texture (rgba16Float: absorbency, roughness, porosity, sizing)
- [ ] `ShaderVolumeInit.swift` — kernel: zero all 8 VolumeLayer buffers
- [ ] `ShaderRender.swift` — kernel: 8-layer back-to-front compositor, normal from depth gradient (central differences), diffuse + specular, over-operator, Reinhard + gamma
- [ ] `Renderer.swift` — `@unchecked Sendable, MTKViewDelegate`, 60fps render loop, canvas init once, render every frame
- [ ] `MetalView.swift` — `NSViewRepresentable` wrapping MTKView
- [ ] `App.swift` — SwiftUI WindowGroup with MetalView + light direction slider
- [ ] `Tests/ShaderCompilationTests.swift` — compile every kernel
- [ ] `Tests/StructLayoutTests.swift` — verify VolumeLayer 32 bytes Swift/MSL match
- [ ] `Tests/TestMetalHelper.swift` — Metal device + XCTSkip fallback

**Deliverable**: Running app shows lit canvas surface with procedural texture. Full voxel buffer infrastructure allocated and rendering.

---

## Milestone 2: Water on Voxels (Week 2-3)

**Goal**: Deposit water, watch it flow and spread across the voxel grid.

- [ ] `BrushPoint.swift` — flat-float struct (position, pressure, radius, absorption RGB, concentration, viscosity, wetness, direction)
- [ ] `CanvasInput.swift` — NSViewRepresentable mouse overlay: tracking → raw points → Catmull-Rom interpolation → .storageModeShared buffer
- [ ] `ShaderDeposition.swift` — kernel: Gaussian bell deposit into VolumeLayer, canvasPropsTex modulation, cross-media rejection stub
- [ ] `ShaderFlow.swift` — kernel: Semi-Lagrangian advection, Jacobi diffusion, height gradient flow, surface tension (Laplacian), mass conservation, double-buffered (read A / write B / flip phase)
- [ ] `ShaderDrying.swift` — kernel: watercolor exponential wetness decay, edge darkening at wet/dry boundaries, hardness/viscosity increase, canvas absorbency modulation, dry flag
- [ ] `VolumeField.swift` — texture/buffer storage: VolumeLayer structured buffer (8 layers × canvas), canvasPropsTex, double-buffered flow textures, phase counter + flip()
- [ ] `MPMSimulator.swift` — per-frame orchestration: deposit(stroke) → flow(N steps) → dry(1 step) → render. Sync sim, async render via buf.present(drawable)
- [ ] `Math.swift` — Beer-Lambert absorption↔reflectance, Catmull-Rom 4-point interpolation
- [ ] `SimulationConfig.swift` — tunable physics params (dt, flow strength, diffusion rate, dry rate, edge darkening)
- [ ] `Tests/SimulationTests.swift` — end-to-end: deposit → flow → dry → render
- [ ] UI: color picker (absorption mode via -log(reflectance)), brush size slider, flow strength slider

**Deliverable**: Paint watercolor on voxel canvas. Fluid dynamics: pooling, spreading, drying, edge darkening. Impasto lighting shows water height.

---

## Milestone 3: Multiple Media on Voxels (Week 4-5)

**Goal**: Oil, acrylic, charcoal each behave differently on the same voxel grid.

- [ ] Extend `ShaderDeposition` per-medium paths: watercolor (transparent absorption), oil (opaque, high viscosity, impasto depth), acrylic (opaque, fast film), charcoal (particulate, adhesion probability)
- [ ] Extend `ShaderDrying` per-medium kinetics: watercolor (base rate), oil (0.5x oxidation), acrylic (8x evaporation+polymerization), charcoal (instant)
- [ ] Cross-media rejection in deposition: watercolor on dried oil/acrylic → crossMediaReject = hardness × (1 - wetness), reject if > 0.7
- [ ] Multi-layer rendering: paint different media on different layers, layer selector UI, layer opacity, back-to-front compositing with per-layer normal maps
- [ ] Medium picker UI + per-medium brush control presets
- [ ] `SimulationConfig.swift` extended with per-medium drying rate multipliers

**Deliverable**: 4 distinct media with physically different behavior. Cross-media interactions. Multi-layer painting.

---

## Milestone 4: SPH Particles for Smudge (Week 6-7)

**Goal**: Particles ride on top of voxel grid for natural smudge and flow.

- [ ] `SPHParticle.swift` — 48-byte flat struct (position, velocity, color, radius, mass, density, viscosity, smoothing_length, wetness, life, layer_index, flags)
- [ ] `SpatialHash.swift` — 2D per-layer spatial hash, cell size = 2× smoothing length, rebuild each frame
- [ ] `ShaderSPHPhysics.swift` — kernels: sphFindNeighbors (spatial hash lookup, density sum), sphForces (Tait pressure + viscosity + surface tension), sphUpdate (velocity/position integration, canvas clamp)
- [ ] `ShaderSplat.swift` — kernel: dispatch 1 thread per particle, Gaussian splat within kernel radius, write color/depth/wetness to affected pixels
- [ ] `SPHSystem.swift` — particle pool: allocate during brush (if smudgable), retire when life expires or wetness < threshold, pool recycling
- [ ] Smudge tool: brush stroke pulls nearby particles in stroke direction
- [ ] Debug overlay: visualize active particles as colored dots
- [ ] StructLayoutTests extended: verify SPHParticle 48 bytes Swift/MSL match

**Deliverable**: Particle-enhanced simulation. Natural smudge behavior. Debug view confirms dynamics.

---

## Milestone 5: Production Quality (Week 8-9)

**Goal**: Fast, stable, exportable.

- [ ] Dirty region tracking: only simulate active tiles, skip dry/empty regions
- [ ] Adaptive resolution: wet=full, damp=half, dry=quarter
- [ ] Indirect dispatch for GPU-driven work culling
- [ ] Threadgroup 16×16 with barrier for all kernels (ceiling-div threadgroups, boundary check)
- [ ] Undo/Redo: hybrid snapshot (every 10 strokes) + command pattern for inter-snapshot
- [ ] `CanvasSerializer.swift` — binary save/load: header + VolumeLayer buffer + SPH particles + canvas props
- [ ] `ImageExporter.swift` — PNG/TIFF via GPU→CPU readback (blit to .managed staging → CGContext → file)
- [ ] Canvas material properties UI: absorbency, roughness, porosity sliders, paper presets (watercolor, canvas panel, smooth board)
- [ ] Filters (if time): Kuwahara, anisotropic diffusion, pointillize as compute kernels
- [ ] App icon, About panel, keyboard shortcuts

**Deliverable**: Production-quality macOS paint app. App Store-ready.

---

## Key Numbers (Reference)

| What | Value |
|------|-------|
| VolumeLayer | 32 bytes (FP16) |
| SPHParticle | 48 bytes |
| Layers per pixel | 8 max |
| PixelVolume | 272 bytes |
| 1080p total memory | ~630 MB |
| 4K total memory | ~2.5 GB |
| Threadgroup size | 16×16 |
| Canvas props texture | rgba16Float (~17 MB) |

## Architecture Reference

- `docs/planning.summary.md` — project overview, tech stack, phases
- `docs/voxel-architecture.summary.md` — MPM decision, structs, pipeline details
- `docs/voxel-quick-reference.summary.md` — numbers, equations, diagrams
- `docs/kb/metal-reference.md` — proven Metal patterns (reference only, don't copy)

## File Structure (Grows With Milestones)

```
Sources/TheRobotPaints/
├── App.swift                          [M1]
├── Models/
│   ├── VolumeLayer.swift              [M1]
│   ├── SPHParticle.swift              [M4]
│   ├── BrushPoint.swift               [M2]
│   └── SimulationConfig.swift         [M2]
├── Rendering/
│   ├── MetalEngine.swift              [M1]
│   ├── Renderer.swift                 [M1]
│   ├── MetalView.swift                [M1]
│   └── ShaderRender.swift             [M1]
├── Simulation/
│   ├── MPMSimulator.swift             [M2]
│   ├── VolumeField.swift              [M2]
│   ├── BrushDeposition.swift          [M2]
│   ├── SPHSystem.swift                [M4]
│   └── CanvasInput.swift              [M2]
├── Shaders/
│   ├── ShaderHeader.swift             [M1]
│   ├── ShaderCanvasInit.swift         [M1]
│   ├── ShaderVolumeInit.swift         [M1]
│   ├── ShaderDeposition.swift         [M2]
│   ├── ShaderFlow.swift               [M2]
│   ├── ShaderDrying.swift             [M2]
│   ├── ShaderSPHPhysics.swift         [M4]
│   └── ShaderSplat.swift              [M4]
├── UI/
│   ├── CanvasView.swift               [M1]
│   ├── ToolBar.swift                  [M2]
│   └── BrushControls.swift            [M2]
├── FileIO/
│   ├── CanvasSerializer.swift         [M5]
│   └── ImageExporter.swift            [M5]
└── Utils/
    └── Math.swift                     [M2]

Tests/TheRobotPaintsTests/
├── ShaderCompilationTests.swift       [M1]
├── StructLayoutTests.swift            [M1]
├── SimulationTests.swift              [M2]
└── TestMetalHelper.swift              [M1]
```
