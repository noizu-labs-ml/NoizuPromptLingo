# Project Layout

```
therobotpaints/
├── Sources/
│   └── TheRobotPaints/
│       ├── Extensions/                 # Media type system
│       │   ├── BuiltInMedia.swift      #   5 media conformances (watercolor, oil, acrylic, charcoal, pastel)
│       │   └── MediaTypeProtocol.swift #   MediaTypeDefinition protocol
│       ├── FileIO/                     # Persistence and export
│       │   ├── ExportEngine.swift      #   PNG/TIFF export via offscreen render
│       │   └── PaintingFileFormat.swift #  .trp native binary save/load
│       ├── Input/                      # Event handling and brush system
│       │   ├── BrushEngine.swift       #   Catmull-Rom interpolation, stroke lifecycle
│       │   ├── InputRouter.swift       #   Event dispatch by active tool
│       │   ├── PressureSource.swift    #   Tablet/mouse/trackpad pressure mapping
│       │   └── ViewportController.swift #  Zoom, pan, rotate, screen-to-canvas transform
│       ├── Models/                     # GPU-shared data structures
│       │   ├── BrushTypes.swift        #   BrushPoint (32B), BrushParams (64B), enums
│       │   ├── SPHParticle.swift       #   SPHParticle (48B), SpatialHashCell, sim params
│       │   ├── ViewParams.swift        #   Camera/viewport parameters (40B)
│       │   └── VolumeLayer.swift       #   32-byte FP16 voxel layer struct
│       ├── Rendering/                  # Metal rendering pipeline
│       │   ├── MetalEngine.swift       #   MTLDevice, command queue, pipeline compiler
│       │   ├── MetalView.swift         #   NSViewRepresentable + CanvasMTKView
│       │   ├── Renderer.swift          #   MTKViewDelegate, frame orchestration
│       │   └── ShaderRender.swift      #   8-layer back-to-front compositor kernel
│       ├── Shaders/                    # MSL shader source (Swift string literals)
│       │   ├── ShaderCanvasInit.swift   #   Procedural canvas weave texture
│       │   ├── ShaderDebugViz.swift     #   Wetness heatmap + depth heightmap overlays
│       │   ├── ShaderDeposit.swift      #   Brush deposit + particle spawning + cross-media rejection
│       │   ├── ShaderDrying.swift       #   Wetness decay + edge darkening + instant dry
│       │   ├── ShaderGridFluid.swift    #   Semi-Lagrangian advection + Jacobi diffusion
│       │   ├── ShaderHeader.swift       #   Shared MSL types, utility functions
│       │   ├── ShaderParticleToVolume.swift # SPH particle-to-grid splat
│       │   ├── ShaderSPH.swift          #   Spatial hash build + Poly6/Spiky force computation
│       │   └── ShaderVolumeInit.swift   #   Zero-fill volume buffer
│       ├── Simulation/                 # Physics simulation pipeline
│       │   └── SimulationPipeline.swift #  Orchestrates SPH + fluid + drying dispatch
│       ├── State/                      # Application state management
│       │   ├── ColorEngine.swift       #   Beer-Lambert absorption color picker
│       │   ├── LayerManager.swift      #   8-layer visibility, active selection, metadata
│       │   ├── PaintUndoManager.swift  #   Stroke-granularity region snapshots
│       │   └── PreferencesStore.swift  #   @AppStorage settings
│       ├── UI/                         # SwiftUI views
│       │   ├── CanvasView.swift        #   Main layout (toolbar + panels + canvas)
│       │   ├── LayerPanelView.swift    #   8-layer list with state badges
│       │   ├── StatusBarView.swift     #   Zoom %, dimensions, layer info
│       │   └── ToolbarView.swift       #   Tool buttons, media selector, sliders
│       └── App.swift                   # SwiftUI app entry point
├── Tests/
│   └── TheRobotPaintsTests/
│       ├── BrushEngineTests.swift       # Catmull-Rom interpolation tests
│       ├── ShaderCompilationTests.swift # Compile-check every Metal kernel (13)
│       ├── StructLayoutTests.swift      # Verify Swift/MSL struct size parity
│       └── TestMetalHelper.swift        # Metal device setup + XCTSkip fallback
├── docs/                               # Documentation
│   ├── arch/                           #   Architecture detail docs
│   │   ├── data-model.md              #     Current struct layouts + memory
│   │   ├── decisions.md               #     Current ADRs
│   │   ├── proposed-*.md              #     Target architecture detail docs (6 files)
│   │   └── rendering.md              #     Current render pipeline details
│   ├── kb/                             #   Knowledge base
│   │   ├── metal-reference.md          #     Proven Metal patterns
│   │   └── web-gpu.md                  #     WebGPU notes
│   ├── PROJ-ARCH.md                    #   Current architecture overview
│   ├── PROJ-ARCH.summary.md            #   Architecture quick reference
│   ├── PROJ-LAYOUT.md                  #   This file
│   ├── PROJ-LAYOUT.summary.md          #   Layout quick reference
│   ├── PROPOSED-ARCH.md                #   Target architecture overview
│   ├── PROPOSED-ARCH.summary.md        #   Target architecture quick reference
│   ├── planning.md                     #   Detailed implementation plan
│   ├── planning.summary.md            #   Plan overview
│   ├── voxel-architecture.md          #   MPM decision, structs, pipeline
│   ├── voxel-architecture.summary.md  #   Architecture summary
│   ├── voxel-quick-reference.md       #   Numbers, equations, diagrams
│   └── voxel-quick-reference.summary.md # Quick reference summary
├── projects/                           # Project management
│   ├── personas/                       #   7 user personas (README + 7 files)
│   └── user-stories/                   #   100 user stories (README + 100 files)
├── .gemini/                            # Gemini Code Assist config
│   ├── config.yaml                     #   Review behavior settings
│   └── styleguide.md                   #   Project style guide for Gemini
├── .envrc                              # direnv — loads environment + secrets
├── .gitignore                          # Excludes .build/, Xcode artifacts, .DS_Store
├── CLAUDE.md                           # Claude Code project instructions
├── build-app.sh                        # Package as macOS .app bundle
├── Makefile                            # Build, run, test, clean, xcode targets
├── Package.swift                       # SPM manifest (Swift 6.0, macOS 14+)
├── README.md                           # Project overview and getting started
├── run.sh                              # Quick-run script
└── TODO.md                             # Milestone-based implementation checklist
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.envrc` | Run `direnv allow` after cloning |

## Build Commands

| Command | Purpose |
|---------|---------|
| `make build` | Build debug via SPM |
| `make run` | Build and run executable |
| `make app` | Package as macOS .app bundle |
| `make open` | Build .app and open it |
| `make test` | Run Swift tests (36 tests) |
| `make xcode` | Open in Xcode (`xed .`) |
| `make clean` | Remove build artifacts |
