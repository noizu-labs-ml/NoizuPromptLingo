# Project Architecture -- Summary

Native macOS Metal paint simulator. Hybrid particle-in-cell: Eulerian grid (8-layer per-pixel volume) + Lagrangian SPH particles for fluid dynamics. 5 media types, 13 GPU compute kernels, 60 FPS.

## Stack

Swift 6 + MSL, SPM build, macOS 14+, SwiftUI + MTKView, absorption color model (Beer-Lambert).

## Modules (10)

- **Input/** -- BrushEngine (Catmull-Rom), InputRouter (tool dispatch: brush/eraser/water/pan/zoom/eyedropper), PressureSource, ViewportController (Retina drawable-pixel coords)
- **Simulation/** -- SimulationPipeline (SPH + grid fluid + drying orchestration)
- **Rendering/** -- MetalEngine, Renderer (frame orchestration), MetalView, ShaderRender
- **State/** -- LayerManager, ColorEngine, PaintUndoManager, PreferencesStore
- **Extensions/** -- MediaTypeProtocol, 5 BuiltInMedia (watercolor, oil, acrylic, charcoal, pastel)
- **FileIO/** -- PaintingFileFormat (.trp), ExportEngine (PNG)
- **Models/** -- VolumeLayer (32B: pigment RGB, water height, depth, wetness, pressure, velocity), BrushPoint (32B), BrushParams (64B: +isEraser, +isWaterOnly), SPHParticle (48B)
- **Shaders/** -- 9 files, 13 GPU kernels
- **UI/** -- CanvasView, ToolbarView (+color picker, +zoom slider), LayerPanelView, StatusBarView (+sim speed slider)

## GPU Kernels (13)

canvasInit, volumeInit, deposit, depositWithParticles, sphBuildHash, sphComputeForces, particleToVolume, gridFluid, drying, instantDry, render, debugWetness, debugDepth

## Key Decisions

- Struct buffer over texture-per-property
- MSL as Swift strings (SPM can't compile .metal)
- Compute-only rendering
- Layer-major buffer layout
- Stroke-granularity undo (region snapshots, ~10 MB/stroke)
- Protocol-based media types (extensible)
- 5x5 cross-media rejection matrix
- Speed-based mouse pressure (1500 px/s max, gamma 1.5)
- Beer-Lambert render compositor (round-trip absorption, exponent ×2)
- Drawable-pixel coordinate pipeline (Retina-correct via viewToDrawablePixel)

## Memory

1080p: ~710 MB GPU (volume + particles + hash + textures). 4K: ~2.8 GB.
