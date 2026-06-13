# Project Layout (Summary)

```
media-tools/
├── src/                            # Rust source code
│   ├── main.rs                     # CLI entry point
│   ├── schema.rs                   # YAML prompt parsing
│   ├── pipeline.rs                 # Generation pipeline
│   ├── dag.rs                      # Dependency DAG resolution
│   ├── attachments.rs              # File attachment handling
│   ├── output.rs                   # Output file management
│   ├── eval.rs                     # Evaluation and scoring
│   ├── refine.rs                   # Interactive refinement
│   ├── ui.rs                       # Terminal UI
│   ├── providers/                  # 12 provider implementations
│   └── renderers/                  # 4 renderer implementations
├── bin/                            # Legacy bash wrapper
├── lib/                            # Legacy Python engine
├── demos/                          # Example .media.prompt files (8 asset types)
├── skill/content-media-engine/     # Claude Code skill definition
├── project-management/             # Personas (8) and user stories (100)
├── docs/                           # Architecture, layout, provider docs
├── Cargo.toml                      # Rust package config
├── Makefile                        # Build targets
├── HOW-TO.md                       # Quick-start prompt writing guide
├── LICENSE
└── README.md                       # Full documentation
```
