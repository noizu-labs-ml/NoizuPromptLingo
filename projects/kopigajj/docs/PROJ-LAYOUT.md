# Project Layout

KopiGajj — macOS GPU-accelerated paint simulation and canvas render engine.

```
kopigajj/
├── src/                              # Application source → [layout/src.md](layout/src.md)
│   ├── Sources/KopiGajj/            #   Main module (Swift + SwiftUI)
│   │   ├── Rendering/               #   Metal canvas render engine (37 files)
│   │   └── *.swift                   #   App delegate, hotkey, popup, main
│   ├── Tests/KopiGajjTests/         #   Test suite (10 tests + 2 helpers)
│   │   └── Helpers/                  #   Test fixtures & Metal helper
│   └── Package.swift                 #   SPM manifest
├── spec/                             # Specifications → [layout/spec.md](layout/spec.md)
│   ├── api-reference/                #   macOS API research (4 docs)
│   ├── personas/                     #   Target user archetypes (2)
│   ├── solution-analysis/            #   Technical solutions (10 docs)
│   ├── style-guide/                  #   Visual design + mockups
│   ├── user-stories/                 #   BDD stories (US-001 … US-158)
│   ├── 00–15 feature specs           #   Feature specifications
│   └── CONSTANTS.yaml                #   Shared constants
├── docs/                             # Documentation
│   ├── PROJ-ARCH.md                  #   Architecture overview
│   ├── PROJ-ARCH.summary.md          #   Architecture summary (companion)
│   ├── PROJ-LAYOUT.md                #   This file
│   ├── PROJ-LAYOUT.summary.md        #   Layout summary (companion)
│   ├── arch/                         #   Architecture deep-dives
│   │   ├── render-pipeline.md        #     Render layer stack + perf budget
│   │   └── data-flow.md              #     Current + planned data flow
│   ├── layout/                       #   Detailed directory breakdowns
│   │   ├── src.md                    #     Source code breakdown
│   │   └── spec.md                   #     Specification breakdown
│   ├── 05-metal-shaders-swiftui.md   #   Metal + SwiftUI integration guide
│   ├── 11-canvas-render-engine.md    #   Canvas render engine design
│   └── medium-behaviour.md           #   Medium paint behaviour notes
├── bin/                              # Scripts
│   ├── extract-stories               #   Extract stories from spec
│   └── generate-stories-yaml         #   Generate stories.yaml index
├── .claude/                          # Claude Code configuration
│   ├── agents/                       #   Custom agent definitions
│   ├── commands/commands/            #   Slash command definitions
│   ├── memory/                       #   Persistent memory files
│   ├── skills -> ../../skills        #   Symlink to incubator skills
│   └── settings.local.json           #   Local settings
├── .gemini/                          # Gemini Code Assist configuration
│   ├── config.yaml                   #   Gemini config
│   └── styleguide.md                 #   Style guide for Gemini
├── .envrc.claudecode.example         # Example env for Claude Code
├── .gitignore                        # Git ignore rules
├── build-app.sh                      # App bundle build script
├── Makefile                          # Build automation
├── CLAUDE.md                         # Claude Code project instructions
├── README.md                         # Project README
├── VISION.md                         # Product vision document
├── product-spec.md                   # Full product specification
├── product-spec.docx                 # Product spec (Word format)
└── LICENSE                           # License file
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.claude/settings.local.json` | Claude Code local overrides (auto-generated) |
| `.envrc.claudecode.example` | Copy to `.envrc` and configure for Claude Code |
| `src/Package.swift` | SPM dependencies — run `swift build` to resolve |

## Build & Run

| Command | Purpose |
|---------|---------|
| `cd src && swift build` | Build the Swift package |
| `cd src && swift test` | Run test suite (10 tests) |
| `./build-app.sh` | Build macOS .app bundle → `build/KopiGajj.app` |
| `make` | Build via Makefile |
