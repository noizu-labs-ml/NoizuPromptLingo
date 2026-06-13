# Architecture Planning Notes — Interactive PDF Reader

> **Status:** Pre-implementation planning. Stack assumptions are documented as decisions to make, not final choices.

---

## Open Architecture Decisions

| Decision | Options | Recommendation | Why |
|----------|---------|----------------|-----|
| App shell | Swift/SwiftUI, Electron, Tauri | **Swift/SwiftUI** | Native macOS integration (Speech, AVFoundation, PDFKit), privacy-better (no Chromium), best VoiceOver support |
| PDF rendering | PDFKit native, PDFKit → HTML/canvas, WebView | **PDFKit + HTML overlay** | PDFKit handles PDF faithfully; HTML overlay enables sentence highlight with precise positioning |
| TTS primary | OpenAI TTS, ElevenLabs, macOS AVSpeechSynthesizer | **OpenAI TTS + AVSpeech fallback** | OpenAI quality is significantly better; AVSpeech for offline/privacy mode |
| ASR | Apple Speech framework, Whisper local, OpenAI Whisper API | **Apple Speech (on-device)** | On-device, no cloud, low latency, macOS 13+ integrated |
| LLM for Q&A | QWEN via Ollama, OpenAI GPT-4o, Anthropic Claude | **Ollama local + configurable cloud** | Privacy-first; power users can upgrade to cloud |
| Embeddings | sentence-transformers (local Python), OpenAI embeddings API, MLX native | **MLX native or OpenAI API** | MLX runs on Apple Silicon natively; OpenAI API as fallback |
| Vector DB | Weaviate (local Docker), Chroma, LanceDB, SQLite-vec | **LanceDB or SQLite-vec** | Weaviate requires Docker (heavy); LanceDB/SQLite-vec are embeddable, zero-infra |
| Python bridge | None (pure Swift), Swift + Python subprocess, Swift + embedded Python | **Swift + Python subprocess for indexing** | Indexing pipeline benefits from Python ecosystem (pypdf, sentence-transformers); UI stays native Swift |

---

## Subsystem Architecture

### 1. PDF Ingestion Pipeline

```
PDF File
  → PDFKit text extraction (per page, per paragraph)
  → Sentence segmentation (NLP tokenizer)
  → Structured JSON per page:
      { page_num, paragraphs: [{ id, text, sentences: [{ id, text, char_offset }] }] }
  → Saved to: {doc-id}/pages/page-NNN.json
```

**Edge cases to handle:**
- Multi-column layouts (extract column order correctly)
- Tables (flatten to text or skip)
- Mathematical formulas (replace with "[formula]" for TTS)
- Scanned PDFs (needs OCR — out of scope for MVP, detect and warn user)
- Headers/footers/page numbers (detect and strip from TTS stream)

---

### 2. Background Indexing Agent Pipeline

Runs after text extraction; stages run sequentially (each depends on prior):

```
Stage 1: Embedding
  For each sentence → embedding vector → stored in vector DB
  Batch size: 64 sentences; ~2-5 min for 300-page doc on M-series Mac

Stage 2: Page Summaries
  For each page → LLM prompt: "Summarize this page in 2-3 sentences"
  Model: QWEN-7B via Ollama (local) or GPT-4o-mini (cloud)
  Output: {doc-id}/pages/page-NNN.json (adds summary field)

Stage 3: Section/Chapter Summaries
  Roll up page summaries by detected chapter → section summary
  Roll up section summaries → chapter summary
  Output: {doc-id}/summaries/structure.json

Stage 4: Concept Extraction
  For each page → LLM prompt: "List key terms and their definitions from this page"
  Deduplicate and merge across pages
  Output: {doc-id}/concepts/{concept-slug}.md (markdown with cross-refs)

Stage 5: Defined Terms (domain-specific)
  Pattern matching for formal definition patterns ("X means...", "X shall mean...")
  Output: Added to {doc-id}/concepts/ with is_defined_term flag
```

---

### 3. TTS Engine

```
Playback State Machine:
  IDLE → PLAYING → PAUSED → PLAYING (resume)
                          → QUESTION (user asked something)
                          → ANSWERING (TTS reads Q&A response)
                          → PLAYING (resumes after answer)

Sentence Queue:
  Pre-fetch next 3 sentences of audio from TTS API
  On sentence end: advance highlight, dequeue next
  Buffer prevents gaps between sentences

TTS API call:
  POST /v1/audio/speech
  model: tts-1-hd, voice: alloy (configurable)
  input: sentence text (with formula/header stripping applied)
  response_format: aac (low latency streaming)

Highlight sync:
  TTS returns audio duration per sentence
  Schedule highlight advance via timer (sentence_start + sentence_duration)
  Adjust for network jitter with ±50ms tolerance
```

---

### 4. Voice Command System

```
Mic Input
  → Apple Speech Recognition (continuous, on-device)
  → Raw transcript
  → Intent Classifier (QWEN local, few-shot prompted):
      - COMMAND: pause, play, go back, next chapter, jump to [section]
      - QUESTION: any question about document content
      - EXPLAIN: "explain that", "what does X mean", "simplify that"
      - NAVIGATE: "find all mentions of X", "go to page N"
  → Dispatch to appropriate handler
```

**Intent classifier prompt strategy:**
- System prompt includes: document title, current section, last 3 sentences read
- Classification must be < 200ms to feel responsive
- Fallback: if confidence < 0.7, ask user to confirm ("Did you mean to jump to Section 4?")

---

### 5. RAG Q&A Pipeline

```
User question (text or voice)
  → Embed question
  → Vector search: top-K sentences from doc (K=10)
  → Rerank by relevance (optional, MLX CrossEncoder)
  → Build context:
      - Retrieved passages with page citations
      - Conversation history (last 5 turns)
      - Current reading position context
  → LLM generation (QWEN local / GPT-4o)
  → Response with inline citations: [p.47, §4.2]
  → Render in chat panel + speak aloud
```

**Citation format:**
- Every claim must cite source: page number + section if available
- If no relevant content found: "This document doesn't address that directly. [offer general answer toggle]"

---

### 6. File System Layout

```
~/Library/Application Support/iPDF/
├── documents/
│   └── {sha256-of-source-pdf}/
│       ├── metadata.json          # title, author, page_count, import_date, index_status
│       ├── source.pdf             # copy of original (or symlink)
│       ├── pages/
│       │   ├── page-001.json      # { text, sentences, summary, embedding_ids }
│       │   └── ...
│       ├── summaries/
│       │   └── structure.json     # { chapters: [{ title, pages, summary }] }
│       ├── concepts/
│       │   ├── index.json         # concept list with page refs
│       │   └── {slug}.md          # per-concept: definition, appearances, related
│       ├── qa-history.json        # Q&A conversation log
│       ├── bookmarks.json         # named bookmarks with positions
│       └── supplemental/
│           └── {supp-hash}/       # same structure as parent doc
├── vectordb/                      # LanceDB or SQLite-vec store (all docs)
└── settings.json                  # app-wide preferences
```

---

### 7. Tech Stack Summary

| Layer | Technology | Notes |
|-------|-----------|-------|
| App Shell | Swift 5.9 + SwiftUI + AppKit | macOS 14+ Sonoma minimum |
| PDF Rendering | PDFKit + WKWebView overlay | PDFView for display; custom overlay for highlight |
| TTS | OpenAI TTS API + AVSpeechSynthesizer fallback | AVSpeech for offline mode |
| ASR | Apple Speech Recognition framework | On-device, macOS 13+ |
| Indexing pipeline | Python 3.12 subprocess (pypdf, sentence-transformers) | Spawned from Swift at import time |
| LLM | Ollama (local QWEN/Llama) + optional cloud | Settings-configurable |
| Embeddings | all-MiniLM-L6-v2 via sentence-transformers | Fast, accurate, runs on CPU/MPS |
| Vector DB | LanceDB (embedded, no Docker) | Serverless, Rust core, good macOS support |
| IPC | Unix domain socket between Swift app and Python indexer | Low latency, local only |
| Storage | JSON files + LanceDB | No SQLite initially; simple, debuggable |

---

## Build Phases / MVP Ladder

### Phase 1: MVP (v0.1) — The Audiobook
**Goal:** Import PDF → TTS plays → sentence highlighted  
**Scope:**
- Import PDF, extract text via PDFKit
- TTS via AVSpeechSynthesizer (no API key required)
- Highlight current sentence on screen
- Pause/resume, speed control
- Remember last position

**Not included:** Q&A, voice commands, indexing, concepts

---

### Phase 2: v0.2 — Voice Navigation
**Goal:** Add hands-free navigation  
**Adds:**
- Apple Speech Recognition integration
- Command intents: pause, resume, go back, next/prev chapter, jump to section
- Chapter outline panel

---

### Phase 3: v0.3 — Q&A Pipeline
**Goal:** Ask questions about document content  
**Adds:**
- Python indexing subprocess (sentence embeddings)
- LanceDB integration
- Ollama local LLM integration (QWEN)
- Basic RAG Q&A with page citations
- OpenAI TTS upgrade (better voice quality)

---

### Phase 4: v0.4 — Intelligence Layer
**Goal:** Concept extraction, summaries, glossary  
**Adds:**
- Page/chapter summaries via LLM
- Concept extraction + defined terms
- Concept browser side panel
- Supplemental materials support

---

### Phase 5: v0.5 — Polish + Distribution
**Goal:** Production quality, accessibility, App Store consideration  
**Adds:**
- VoiceOver compliance pass
- Keyboard navigation completion
- Settings screen (LLM provider, voice, storage)
- Per-document Q&A history export
- Potential Mac App Store submission (review sandbox/privacy implications)

---

## Key Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| PDF text extraction quality (scanned PDFs) | High | High | Detect scanned pages, warn user, offer OCR instruction |
| TTS highlight sync drift | Medium | Medium | Re-sync on page turn; tolerance ±100ms acceptable |
| Indexing too slow for large PDFs | Medium | Medium | Stream "ready" status per stage; playback doesn't block |
| Ollama/QWEN response latency > 3s | Medium | Medium | Show typing indicator; cache common question types |
| Apple Speech accuracy on technical vocabulary | Medium | Low | Vocabulary hint list per document; fallback to text input |
| LanceDB macOS Swift FFI stability | Low | High | Evaluate; Chroma or SQLite-vec as backup |
| App Store rejection (Ollama subprocess) | High | Medium | Distribute outside App Store (direct download) initially |
