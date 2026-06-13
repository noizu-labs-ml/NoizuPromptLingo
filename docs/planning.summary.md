# The Robot Paints — Planning Summary

> Condensed from `planning.md` (1499 lines). Read the full doc for code examples, UI mockups, and phase details.

## What It Is

Native macOS Metal paint simulator. 2D canvas with per-pixel layer stacks, GPU-computed physics, 60 FPS target. Metal-first, WebGPU migration later.

## Architecture at a Glance

| Aspect | Choice |
|--------|--------|
| Platform | macOS 14+, Apple Silicon primary |
| Language | Swift 6 + Metal Shading Language |
| Build | SPM (not Xcode project) |
| Shader source | Swift string literals, runtime-compiled |
| Concurrency | `@unchecked Sendable` classes (no actors for Metal objects) |
| UI | SwiftUI + MTKView wrapper |
| Color model | Absorption (Beer-Lambert), not RGB |

## Key Data Structures

| Struct | Size | Purpose |
|--------|------|---------|
| `VolumeLayer` | 32 bytes (FP16) | Per-layer per-pixel paint state |
| `SPHParticle` | 48 bytes | Particle for smudge/flow dynamics |
| `PixelVolume` | 272 bytes | 8 layers + header per pixel |

## Rendering

**Not raymarching** — 2D layer-stack compositing. Per-pixel back-to-front (painter's algorithm). Impasto lighting via depth-derived normal maps (central differences). Per-medium specular (oil gloss, acrylic sheen). Absorption color model: `visibleColor = canvasColor * exp(-absorption * concentration)`.

## Memory

| Resolution | Estimate |
|------------|----------|
| 1080p | ~630 MB |
| 4K | ~2.5 GB |

## Simulation Pipeline

1. **Brush Deposition** — Catmull-Rom interpolation → GPU deposit → SPH particle generation
2. **SPH Physics** — Spatial hash neighbor search, pressure/viscosity/surface tension forces
3. **Particle → Volume Integration** — Kernel interpolation back to grid
4. **Grid Fluid Dynamics** — Semi-Lagrangian advection, Jacobi diffusion, mass conservation
5. **Drying Kinetics** — Medium-specific rates (watercolor fast, oil slow, acrylic two-phase)
6. **Rendering** — Layer-stack composite with impasto lighting → MTKView

## Media

Watercolor (flow, granulation, backrun), Oil (thixotropic, impasto, slow oxidation), Acrylic (fast polymerization, water-resist), Charcoal (particulate, smudge, fixative), Pastel (powder, layer mixing).

## Implementation Timeline

| Phase | Weeks | Focus |
|-------|-------|-------|
| 1 | 1-2 | Core Metal framework |
| 2 | 3-4 | Watercolor physics |
| 3 | 5-6 | Multi-layer volume |
| 4 | 7-9 | Oil, acrylic, charcoal |
| 5 | 10-12 | Advanced simulation |
| 6 | 13-14 | Performance optimization |
| 7 | 15-16 | UX & polish |
| 8 | 17+ | Web migration |

## File Structure (SPM)

```
Sources/TheRobotPaints/
├── App.swift, Models/, Views/
├── Rendering/        (MetalEngine, Renderer, MetalView)
├── Simulation/       (MPMSimulator, BrushDeposition, SPHSystem)
├── Shaders/          (ShaderHeader.swift + per-kernel .swift files)
├── Protocols/        (MetalShaderCompiler, MetalTextureFactory)
├── State/, FileIO/, Utils/
Tests/TheRobotPaintsTests/
├── MetalShaderCompilationTests.swift
├── TestMetalHelper.swift
```

## Proven Patterns (from kopigajj)

- Runtime MSL compilation via `MTLDevice.makeLibrary(source:)`
- `MetalShaderCompiler` + `MetalTextureFactory` protocols
- Double-buffered ping-pong textures for simulation steps
- `BrushPoint` struct: all flat floats, CPU↔GPU byte-for-byte match
- GPU→CPU readback: blit → `.managed` staging → `CGImage` → `NSImage`
- Threadgroup 16×16, ceiling-div, boundary check in shader
- Synchronous sim dispatch (`waitUntilCompleted`), async render (`present(drawable)`)
- `MetalShaderCompilationTests` — compile every kernel at test time

## References

- `docs/kb/metal-reference.md` — 10 proven Metal patterns with full code
- `docs/voxel-architecture.md` — detailed simulation architecture
- `docs/voxel-quick-reference.md` — diagrams and quick lookup
- `../kopigajj/` — working paint sim (sister project)
