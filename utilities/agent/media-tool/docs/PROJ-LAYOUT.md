# Project Layout

```
media-tools/
├── src/                            # Rust source → [layout/src.md](layout/src.md)
│   ├── main.rs                     #   CLI entry point (clap, pipeline orchestration)
│   ├── schema.rs                   #   YAML prompt parsing and normalization
│   ├── pipeline.rs                 #   Generation pipeline (dry-run, execute, parallelism)
│   ├── dag.rs                      #   Dependency DAG resolution (Kahn's algorithm)
│   ├── attachments.rs              #   File attachment loading and base64 encoding
│   ├── output.rs                   #   Output file naming, format handling
│   ├── eval.rs                     #   Evaluation criteria and vision-based scoring
│   ├── refine.rs                   #   Interactive refinement loop
│   ├── ui.rs                       #   TUI (ratatui) and progress indicators
│   ├── providers/                  #   Generation provider implementations
│   │   ├── mod.rs                  #     MediaProvider trait, dispatch registry
│   │   ├── gemini.rs               #     Google Imagen (image)
│   │   ├── gemini_chat.rs          #     Gemini chat completions (text/code output)
│   │   ├── anthropic.rs            #     Anthropic Claude (text/code output)
│   │   ├── openai_chat.rs          #     OpenAI chat completions (text/code output)
│   │   ├── zai.rs                  #     ZAI image generation
│   │   ├── suno.rs                 #     Suno music generation (async polling)
│   │   ├── openai_tts.rs           #     OpenAI TTS (audio)
│   │   ├── elevenlabs.rs           #     ElevenLabs TTS (audio)
│   │   ├── qwen_tts.rs             #     Alibaba Qwen TTS (audio)
│   │   ├── grok_video.rs           #     xAI Grok video (async polling)
│   │   └── veo.rs                  #     Google Veo video (async polling)
│   └── renderers/                  #   Markup → visual output renderers
│       ├── mod.rs                  #     Renderer trait, registry
│       ├── mermaid.rs              #     Mermaid diagram rendering (mmdc/Puppeteer)
│       ├── plantuml.rs             #     PlantUML diagram rendering
│       ├── graphviz.rs             #     Graphviz DOT rendering
│       └── puppeteer.rs            #     Puppeteer screenshot capture
├── bin/                            # Legacy entry points
│   └── generate-media-prompt       #   Bash wrapper (k8-lib, Python engine dispatch)
├── lib/                            # Legacy Python engine
│   └── media-prompt-engine.py      #   Single-file Python engine (stdlib + pyyaml)
├── demos/                          # Working .media.prompt examples by asset type
│   ├── image/                      #   Hero images, logos (Gemini Imagen)
│   ├── svg/                        #   SVG illustrations (chat + render)
│   ├── diagram/                    #   Mermaid, PlantUML diagrams
│   ├── html/                       #   HTML pages, React components
│   ├── video/                      #   Veo, Grok video clips
│   ├── music/                      #   Lo-fi beat (Suno)
│   ├── voice/                      #   OpenAI TTS, ElevenLabs, Qwen TTS
│   └── game/                       #   HTML5 game (Breakout clone)
├── skill/                          # Claude Code skill definitions
│   └── content-media-engine/       #   Content media engine skill
│       ├── SKILL.md                #     Skill entry point and triggers
│       ├── assets/                 #     Templates, trackers, example prompts
│       ├── references/             #     FIM library (120+ visualization tools), guides
│       └── scripts/                #     Skill utility scripts
├── project-management/             # Product management artifacts
│   ├── personas/                   #   8 user personas with index.yaml
│   └── user-stories/               #   100 user stories with index.yaml
├── docs/                           # Documentation
│   ├── PROJ-ARCH.md                #   Architecture and system design
│   ├── PROJ-LAYOUT.md              #   This file
│   ├── PROJ-LAYOUT.summary.md      #   Quick-reference tree
│   └── providers.md                #   Provider implementation guide
├── .gitignore                      #   Rust target/, Python __pycache__/, IDE files
├── Cargo.toml                      #   Rust package definition (bin + deps)
├── Cargo.lock                      #   Locked dependency versions
├── Makefile                        #   build, test, install, clean targets
├── HOW-TO.md                       #   Quick reference for writing .media.prompt files
├── LICENSE                         #   License file
└── README.md                       #   Full user documentation (schema, CLI, providers)
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| API keys | Set `GEMINI_API_KEY`, `SUNO_API_KEY`, `OPENAI_API_KEY`, etc. in `.envrc` or environment |
| `make install` | Builds Rust binary and installs to `~/.local/bin/generate-media-prompt` |

## Generation Details

- **demos/.genai.\*** directories contain cached generation outputs (timestamped); these are working artifacts, not source
- **demo \*.media.prompt files** are the actual prompt definitions — run any with `generate-media-prompt <path>`
