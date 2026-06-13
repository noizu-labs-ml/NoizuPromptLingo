# src/ — Application Source Code

```
src/
├── Package.swift                          # Swift Package Manager manifest
├── Sources/
    └── KopiGajj/                          # Main application module
        ├── Rendering/                     # Canvas render engine (40 files)
        │   ├── Shaders/                   #   Legacy .metal files (SPM-excluded)
        │   │   ├── BristleEdge.metal
        │   │   ├── CanvasOverlay.metal
        │   │   ├── Desaturate.metal
        │   │   └── Kuwahara.metal
        │   ├── PaintShaderHeader.swift        # Shared Metal structs, constants, noise
        │   ├── PaintShaderCanvasInit.swift     # canvasInit kernel — procedural canvas
        │   ├── PaintShaderBrushStroke.swift    # brushStroke kernel — paint deposit
        │   ├── PaintShaderFlowDry.swift        # flowStep + dryStep kernels
        │   ├── PaintShaderRender.swift         # paintRender kernel — compositing
        │   ├── PaintShaderFilters.swift        # 8 image filter kernels + filterHeader
        │   ├── PaintSimulator.swift            # GPU pipeline orchestration (5 kernels)
        │   ├── PaintField.swift                # BrushPoint, BrushMode, PaintField textures
        │   ├── PaintMath.swift                 # Math utilities for paint simulation
        │   ├── PaintCanvasNSView.swift         # NSView: mouse events → GPU dispatch
        │   ├── PaintCanvasView.swift           # NSViewRepresentable wrapper
        │   ├── PaintCanvasState.swift          # Observable brush/sim state
        │   ├── PaintCanvasControls.swift       # Brush controls UI (color, radius, pressure)
        │   ├── MediaTooltips.swift             # Per-media tooltip descriptions
        │   ├── ColorPanelCoordinator.swift     # NSColorPanel integration
        │   ├── MetalShaderCompiler.swift       # Protocol: compile MSL source strings
        │   ├── MetalTextureFactory.swift       # Protocol: create MTLTexture
        │   ├── CanvasMetalRenderer.swift       # 8 image filter pipelines (singleton)
        │   ├── CanvasBackground.swift          # Procedural canvas texture generation
        │   ├── CanvasConfig.swift              # Codable config (~30 params, flat JSON)
        │   ├── CanvasConfigManager.swift       # Theme picker + persistence
        │   ├── CanvasTheme.swift               # Color palette definitions
        │   ├── CanvasTuningView.swift          # Main split-view layout coordinator
        │   ├── CanvasTuningSliders.swift       # Right-pane slider panel
        │   ├── CanvasFilterSection.swift       # Filter type + params sliders
        │   ├── CanvasPaintSimSection.swift     # Sim parameter sliders
        │   ├── CanvasTuningState.swift         # ObservableObject wrapping CanvasConfig
        │   ├── CanvasPreviewPane.swift         # Left-pane canvas preview
        │   ├── CanvasPaintSimPane.swift        # Interactive paint mode pane
        │   ├── CanvasPopupView.swift           # Canvas popup container
        │   ├── ProceduralStrokes.swift         # Procedural stroke generation
        │   ├── StrokeCard.swift                # Painterly clipboard item card
        │   └── TunableSlider.swift             # Reusable slider + InfoButton
        ├── AppDelegate.swift              # Application delegate & lifecycle
        ├── HotkeyManager.swift            # Global hotkey registration (Cmd+Shift+T)
        ├── MenuBarManager.swift           # Status bar icon & dropdown menu
        ├── PopupWindowManager.swift       # Floating popup window management
        ├── RenderingBootstrap.swift       # Pre-warm Metal pipeline at launch
        ├── Version.swift                  # App version constants
        └── main.swift                     # Entry point
└── Tests/
    └── KopiGajjTests/                    # Test suite (10 test files)
        ├── Helpers/                       #   Test support
        │   ├── TestFixtures.swift         #   Shared test data + config builders
        │   └── TestMetalHelper.swift      #   Metal device setup for GPU tests
        ├── BrushPointCodableTests.swift   #   BrushPoint encode/decode roundtrip
        ├── CanvasConfigCodableTests.swift #   CanvasConfig JSON serialization
        ├── EnumContractTests.swift        #   Enum case stability contracts
        ├── MathTests.swift                #   PaintMath utility tests
        ├── MetalShaderCompilationTests.swift # Shader compilation validation
        ├── PaintCanvasStateTests.swift    #   Observable state behavior
        ├── PaintFieldTests.swift          #   Texture allocation + flip tests
        ├── PaintPipelineTests.swift       #   End-to-end GPU pipeline tests
        ├── RegressionTests.swift          #   Bug regression guards
        └── StructLayoutTests.swift        #   BrushPoint 56-byte layout assertion
```

## Key Components

| Component | File(s) | Purpose |
|-----------|---------|---------|
| Entry point | `main.swift` | App bootstrap |
| App lifecycle | `AppDelegate.swift` | NSApplication delegate |
| Global hotkey | `HotkeyManager.swift` | Cmd+Shift+T registration |
| Menu bar | `MenuBarManager.swift` | Status bar icon & dropdown menu |
| Popup window | `PopupWindowManager.swift` | Floating panel management |
| Render bootstrap | `RenderingBootstrap.swift` | Pre-warm textures + Metal pipeline |
| Version | `Version.swift` | App version constants |
| GPU shaders | `PaintShader*.swift` (6 files) | Runtime-compiled Metal compute kernels |
| Paint simulation | `PaintSimulator.swift` + `PaintField.swift` | 5-kernel GPU paint pipeline |
| Metal protocols | `MetalShaderCompiler.swift` + `MetalTextureFactory.swift` | Shared Metal boilerplate |
| Image filters | `CanvasMetalRenderer.swift` | 8 artistic post-processing filters |
| Paint UI | `PaintCanvas*.swift` + `MediaTooltips.swift` | Interactive painting controls |
| Tuning UI | `CanvasTuning*.swift` + `Canvas*Section.swift` | Parameter slider panels |
| Config | `CanvasConfig.swift` + `CanvasConfigManager.swift` | JSON theme persistence |
