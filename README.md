# Interactive PDF Reader (iPDF)

An macOS application for intelligent, voice-driven PDF reading.

## Concept

Read PDFs like an audiobook — with sentence-level highlighting, voice Q&A, and AI-generated concept maps. Import a PDF; the app builds a local knowledge index (embeddings, summaries, concepts) and then lets you listen, navigate, and converse with the document by voice.

## Core Features

- **TTS Playback** — OpenAI TTS reads the document aloud; current sentence highlighted on screen
- **Voice Commands** — "pause", "go back", "jump to Section 4", "next chapter"
- **Voice Q&A** — "What does X mean?", "What are the payment terms?" — answered with page citations
- **Concept Extraction** — Auto-generated glossary, defined terms, concept cross-references
- **Supplemental Materials** — Attach related PDFs; query across all of them together
- **Privacy-first** — All processing local by default; cloud LLM/TTS optional

## AI Stack

| Component | Default | Alternative |
|-----------|---------|-------------|
| TTS | OpenAI TTS API | macOS AVSpeechSynthesizer (offline) |
| ASR | Apple Speech Recognition (on-device) | — |
| LLM (Q&A) | QWEN via Ollama (local) | OpenAI GPT-4o / Anthropic Claude |
| Embeddings | sentence-transformers (MiniLM) | OpenAI embeddings API |
| Vector DB | LanceDB (embedded, no Docker) | SQLite-vec |

## Document Index Structure

```
~/Library/Application Support/iPDF/
└── documents/{doc-hash}/
    ├── pages/           # per-page text + sentence segmentation + summaries
    ├── summaries/       # chapter/section roll-up summaries
    ├── concepts/        # extracted concepts, defined terms, cross-refs
    ├── supplemental/    # attached related PDFs (same structure)
    ├── qa-history.json  # conversation history per document
    └── bookmarks.json
```

## Build Phases

| Phase | Goal | Key Features |
|-------|------|-------------|
| v0.1 MVP | Audiobook mode | Import → TTS → highlight → remember position |
| v0.2 | Voice navigation | Hands-free pause/resume/navigate |
| v0.3 | Q&A | RAG pipeline, Ollama, page citations |
| v0.4 | Intelligence | Summaries, concepts, supplementals |
| v0.5 | Polish | Accessibility, export, distribution |

## Planning Artifacts

- [`project-management/personas/`](project-management/personas/) — 6 user personas
- [`project-management/user-stories/`](project-management/user-stories/) — 54 user stories across 7 domains
- [`project-management/screens/`](project-management/screens/) — Screen inventory (9 screens + component list)
- [`project-management/architecture-notes.md`](project-management/architecture-notes.md) — Stack decisions, subsystem design, risk register

## Target Platform

macOS 14+ Sonoma. Swift/SwiftUI native app (not Electron). Apple Silicon primary target.

> **Status:** Pre-implementation, planning phase.
