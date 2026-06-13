# Project Layout Summary

```
kopigajj/
├── src/                          # Swift application source
│   ├── Sources/KopiGajj/        #   Main module
│   │   ├── Rendering/            #   Metal canvas engine (37 files)
│   │   │   ├── Shaders/          #     Legacy .metal files (SPM-excluded)
│   │   │   ├── PaintShader*.swift #    6 shader source files (runtime-compiled)
│   │   │   ├── PaintSimulator.swift #  GPU pipeline orchestration
│   │   │   ├── PaintField.swift  #     BrushPoint, BrushMode, textures
│   │   │   ├── PaintCanvas*.swift #    Interactive painting (NSView, controls, state)
│   │   │   ├── Canvas*.swift     #     Config, tuning UI, background, preview
│   │   │   ├── Metal*.swift      #     Shader compiler + texture factory protocols
│   │   │   └── *.swift           #     Tooltips, color coordinator, sliders, cards
│   │   ├── MenuBarManager.swift  #   Menu bar icon & menu
│   │   ├── RenderingBootstrap.swift # Render pipeline init
│   │   ├── Version.swift         #   App version constants
│   │   └── *.swift               #   App delegate, hotkey, popup, main
│   ├── Tests/KopiGajjTests/     #   Test suite
│   │   ├── Helpers/              #     TestFixtures + TestMetalHelper
│   │   ├── BrushPointCodableTests.swift
│   │   ├── CanvasConfigCodableTests.swift
│   │   ├── EnumContractTests.swift
│   │   ├── MathTests.swift
│   │   ├── MetalShaderCompilationTests.swift
│   │   ├── PaintCanvasStateTests.swift
│   │   ├── PaintFieldTests.swift
│   │   ├── PaintPipelineTests.swift
│   │   ├── RegressionTests.swift
│   │   └── StructLayoutTests.swift
│   └── Package.swift
├── spec/                         # Specifications & design
│   ├── api-reference/            #   macOS API research
│   ├── personas/                 #   User archetypes
│   ├── solution-analysis/        #   Technical solutions
│   ├── style-guide/              #   Visual design
│   ├── user-stories/             #   158 BDD stories
│   └── *.md / *.yaml             #   Feature specs & constants
├── docs/                         # Documentation & layout
│   ├── arch/                     #   Architecture deep-dives
│   ├── layout/                   #   Directory breakdowns (src.md, spec.md)
│   ├── PROJ-ARCH.md              #   Architecture overview
│   ├── PROJ-ARCH.summary.md      #   Architecture summary
│   ├── PROJ-LAYOUT.md            #   Project layout
│   ├── PROJ-LAYOUT.summary.md    #   This file
│   └── medium-behaviour.md       #   Paint medium behaviour reference
├── bin/                          # Utility scripts
├── .claude/                      # Claude Code config
│   ├── agents/                   #   Custom agent definitions
│   ├── commands/commands/        #   Slash command definitions
│   ├── memory/                   #   Persistent memory files
│   └── skills -> ../../skills    #   Symlink to incubator skills
├── .gemini/                      # Gemini Code Assist config
├── .envrc.claudecode.example     # Example env for Claude Code
├── build-app.sh
├── Makefile
├── CLAUDE.md
├── README.md
├── VISION.md
├── product-spec.md
├── product-spec.docx
└── LICENSE
```
