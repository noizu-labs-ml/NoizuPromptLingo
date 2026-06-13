# Project Layout — Summary

```
therobotpaints/
├── Sources/TheRobotPaints/
│   ├── Extensions/          # Media type protocol + 5 built-in media
│   ├── FileIO/              # .trp save/load, PNG export
│   ├── Input/               # BrushEngine, InputRouter, PressureSource, ViewportController
│   ├── Models/              # BrushTypes, SPHParticle, ViewParams, VolumeLayer
│   ├── Rendering/           # MetalEngine, MetalView, Renderer, ShaderRender
│   ├── Shaders/             # 9 shader files (13 GPU kernels)
│   ├── Simulation/          # SimulationPipeline (SPH + fluid + drying)
│   ├── State/               # ColorEngine, LayerManager, PaintUndoManager, PreferencesStore
│   ├── UI/                  # CanvasView, LayerPanel, StatusBar, Toolbar
│   └── App.swift            # Entry point
├── Tests/TheRobotPaintsTests/
├── docs/
│   ├── arch/                # Architecture detail + proposed docs
│   └── kb/                  # Knowledge base articles
├── projects/
│   ├── personas/            # 7 user personas
│   └── user-stories/        # 100 user stories
├── .gemini/                 # Gemini Code Assist config
├── .envrc
├── CLAUDE.md
├── build-app.sh
├── Makefile
├── Package.swift
├── README.md
├── run.sh
└── TODO.md
```
