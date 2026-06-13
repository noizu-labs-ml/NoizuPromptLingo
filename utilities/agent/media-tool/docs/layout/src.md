# src/ — Application Source

```
src/
├── main.rs                  # CLI entry point — clap parser, input resolution, pipeline dispatch
├── schema.rs                # YAML .media.prompt parsing — schema v0.1/v0.2/v0.3 normalization
├── pipeline.rs              # Generation pipeline — dry-run preview, execution, tier ordering
├── dag.rs                   # Dependency DAG — cycle detection, topological sort (Kahn's)
├── attachments.rs           # Attachment loading — file reads, MIME detection, base64 encoding
├── output.rs                # Output handling — filename derivation, multi-format, variant numbering
├── eval.rs                  # Evaluation — criteria matching, vision-based scoring via LLM
├── refine.rs                # Refinement loop — feedback collection, prompt rewriting via LLM
├── ui.rs                    # Terminal UI — ratatui TUI, indicatif progress bars, dialoguer prompts
├── providers/               # Generation provider implementations
│   ├── mod.rs               #   MediaProvider trait definition, provider registry/dispatch
│   ├── gemini.rs            #   Google Imagen — image generation (synchronous)
│   ├── gemini_chat.rs       #   Gemini chat — text/code generation for markup assets
│   ├── anthropic.rs         #   Anthropic Claude — text/code generation
│   ├── openai_chat.rs       #   OpenAI chat — text/code generation
│   ├── zai.rs               #   ZAI — image generation
│   ├── suno.rs              #   Suno — music generation (async polling with timeout)
│   ├── openai_tts.rs        #   OpenAI TTS — text-to-speech (synchronous)
│   ├── elevenlabs.rs        #   ElevenLabs — TTS with voice cloning (synchronous)
│   ├── qwen_tts.rs          #   Qwen TTS — Alibaba DashScope TTS (synchronous)
│   ├── grok_video.rs        #   xAI Grok — video generation (async polling)
│   └── veo.rs               #   Google Veo — video generation (async polling)
└── renderers/               # Markup → visual output renderers
    ├── mod.rs               #   Renderer trait, availability detection
    ├── mermaid.rs           #   Mermaid — mmdc CLI or Puppeteer-based rendering
    ├── plantuml.rs          #   PlantUML — server or CLI rendering
    ├── graphviz.rs          #   Graphviz DOT — dot CLI rendering
    └── puppeteer.rs         #   Puppeteer — headless Chrome screenshot capture
```

## Module Dependencies

```
main.rs
  ├── schema.rs        (YAML parsing)
  ├── dag.rs           (dependency resolution)
  ├── pipeline.rs      (orchestration)
  │     ├── providers/*  (generation dispatch)
  │     ├── renderers/*  (markup rendering)
  │     ├── output.rs    (file writing)
  │     └── eval.rs      (quality scoring)
  ├── attachments.rs   (file loading)
  ├── refine.rs        (interactive loop)
  └── ui.rs            (terminal display)
```
