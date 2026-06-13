# Proposed Components

## Module Map

```
Sources/TheRobotPaints/
├── App.swift                          # Entry point (exists)
├── Models/                            # Data structures (exists, extended)
│   ├── VolumeLayer.swift              #   Existing structs
│   ├── BrushTypes.swift               #   BrushPoint, BrushParams, StrokeRecord
│   ├── SPHParticle.swift              #   Particle struct + SpatialHashCell
│   └── CanvasPreset.swift             #   Paper type presets
├── Input/                             # Input handling (new)
│   ├── InputRouter.swift              #   Event dispatch by active tool
│   ├── BrushEngine.swift              #   Stroke interpolation + pressure mapping
│   ├── PressureSource.swift           #   Protocol: tablet, mouse, trackpad variants
│   └── ViewportController.swift       #   Zoom/pan/rotate state (extracted from Renderer)
├── Simulation/                        # Physics pipeline (new)
│   ├── SimulationPipeline.swift       #   Orchestrates 5-phase dispatch
│   ├── DepositKernel.swift            #   Brush → VolumeLayer + SPH particles
│   ├── SPHKernel.swift                #   Spatial hash + particle forces
│   ├── ParticleToVolumeKernel.swift   #   SPH → grid integration
│   ├── GridFluidKernel.swift          #   Advection + diffusion
│   └── DryingKernel.swift             #   Medium-specific drying rates
├── Rendering/                         # Render pipeline (exists, extended)
│   ├── MetalEngine.swift              #   Device, queue, compiler (exists)
│   ├── Renderer.swift                 #   Frame orchestration (exists, refactored)
│   ├── MetalView.swift                #   NSViewRepresentable (exists)
│   ├── CompositorKernel.swift         #   8-layer render (extracted from ShaderRender)
│   └── DebugVizKernel.swift           #   Wetness/velocity/depth overlays
├── Shaders/                           # MSL source (exists, extended)
│   ├── ShaderHeader.swift             #   Shared types (exists, extended)
│   ├── ShaderCanvasInit.swift         #   Canvas weave (exists)
│   ├── ShaderVolumeInit.swift         #   Volume zero-fill (exists)
│   ├── ShaderRender.swift             #   Compositor (exists)
│   ├── ShaderDeposit.swift            #   Brush deposition kernel (new)
│   ├── ShaderSPH.swift               #   SPH physics kernel (new)
│   ├── ShaderParticleToVolume.swift   #   P→V integration kernel (new)
│   ├── ShaderGridFluid.swift          #   Advection/diffusion kernel (new)
│   ├── ShaderDrying.swift             #   Drying kinetics kernel (new)
│   └── ShaderDebugViz.swift           #   Debug overlay kernels (new)
├── State/                             # Application state (new)
│   ├── LayerManager.swift             #   Layer visibility, active, metadata
│   ├── ColorEngine.swift              #   Absorption picker, palette, history
│   ├── UndoManager.swift              #   Stroke-granularity undo stack
│   └── PreferencesStore.swift         #   User settings, shortcuts
├── UI/                                # SwiftUI views (exists, extended)
│   ├── CanvasView.swift               #   Main layout (exists, refactored)
│   ├── ToolbarView.swift              #   Tool + media selector
│   ├── LayerPanelView.swift           #   Layer list with state badges
│   ├── ColorPanelView.swift           #   Picker, palette, history
│   ├── BrushPanelView.swift           #   Size, opacity, flow, presets
│   ├── StatusBarView.swift            #   Dimensions, zoom %, memory
│   ├── NewCanvasDialog.swift          #   Size + paper type picker
│   ├── PreferencesView.swift          #   Settings window
│   └── ExportView.swift               #   Format + resolution picker
├── FileIO/                            # Persistence (new)
│   ├── PaintingFileFormat.swift       #   Native .trp read/write
│   ├── ExportEngine.swift             #   PNG/TIFF export via offscreen render
│   ├── AutosaveManager.swift          #   Timer-based temp file writes
│   └── BrushPresetStore.swift         #   JSON preset serialization
└── Extensions/                        # Plugin system (new)
    ├── MediaTypeProtocol.swift        #   Protocol for custom media
    ├── BuiltInMedia.swift             #   Watercolor, oil, acrylic, charcoal, pastel
    └── ShaderHotReload.swift          #   File watcher + recompile (dev only)
```

## Component Interactions

### BrushEngine

Receives raw `NSEvent` streams from `InputRouter`. Produces `BrushPoint` arrays via Catmull-Rom interpolation at sub-pixel density. Maps pressure from the active `PressureSource` (tablet hardware, mouse speed simulation, or trackpad force). Pushes `BrushPoint` buffer to GPU each frame. Creates `StrokeRecord` on mouse-up for undo stack.

### SimulationPipeline

Called by `Renderer.draw(in:)` after brush input processing. Dispatches 5 compute encoders in sequence within a single command buffer. Skips phases when no wet paint exists (early-out via CPU-side dirty flag). Each phase reads/writes the shared `VolumeLayer` buffer and `SPHParticle` buffer.

### LayerManager

Tracks which of the 8 layers is active (paint target), which are visible (render mask), and per-layer metadata (media type, wet/dry state summary). Communicates with `Renderer` via a `LayerState` struct passed as shader constant.

### ColorEngine

Maintains the current brush color in absorption space. The picker UI shows predicted visible color (canvas × exp(-absorption × concentration)) alongside raw absorption values. Palette stores named absorption colors. Eyedropper reads back from the composited render, then reverse-maps to absorption.

### FileManager

Save: blits `VolumeLayer` buffer and `CanvasProps` texture from GPU to CPU via `.managed` staging resources. Writes header + raw bytes to `.trp` file. Load: reads file, uploads to GPU buffers. Export: dispatches render kernel to offscreen texture at target resolution, reads back as `CGImage`.
