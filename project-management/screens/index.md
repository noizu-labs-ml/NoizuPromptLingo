# Screen Inventory — Interactive PDF Reader

## Primary Screens

### SCR-001: Library / Home
**Purpose:** Document collection entry point  
**Primary Persona:** All  
**Triggered by:** App launch  

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  [Search]                          [Sort ▾] [Grid/List] │
│                                                          │
│  Recently Opened                                         │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐               │
│  │Cover │  │Cover │  │Cover │  │Cover │                 │
│  │Title │  │Title │  │Title │  │ + Add│                 │
│  │p.47  │  │ 100% │  │p.12  │  │      │                 │
│  └──────┘  └──────┘  └──────┘  └──────┘               │
│                                                          │
│  Collections                                             │
│  > Research Papers (5)                                   │
│  > Work Documents (3)                                    │
└─────────────────────────────────────────────────────────┘
```
**Key Components:** Document grid, Progress indicator per doc, Collection grouping, Import dropzone  
**User Stories:** US-ING-001, US-ING-005, US-ING-006, US-ING-003

---

### SCR-002: Import & Processing
**Purpose:** Onboard a new document; show indexing progress  
**Primary Persona:** All  
**Triggered by:** Drag-drop or "+" button on SCR-001  

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  Importing: "Contract_v3_final.pdf"           [Cancel]  │
│                                                          │
│  ████████████████░░░░░░░░░░░░  Stage 2 of 4             │
│                                                          │
│  ✓ Text extraction complete (312 pages)                 │
│  ⟳ Building embeddings...  (~2 min remaining)           │
│  ○ Generating summaries                                  │
│  ○ Extracting concepts                                   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  You can start reading now. Q&A available        │   │
│  │  when indexing completes.      [Start Reading →] │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```
**Key Components:** Stage progress, "Start reading now" CTA, Estimated time  
**User Stories:** US-ING-001, US-ING-002

---

### SCR-003: Reader View (Main)
**Purpose:** Core reading and listening experience  
**Primary Persona:** All  
**Triggered by:** Open document from library  

**Layout:**
```
┌──────────────┬───────────────────────────────┬──────────┐
│  Outline     │                               │  Chat /  │
│  ──────────  │   PDF PAGE CONTENT            │  Q&A     │
│  Ch.1  p.1   │                               │          │
│  > Ch.2 p.14 │  Para 1 text here...          │  [Ask    │
│    §2.1 p.17 │  ┌───────────────────────┐    │   a      │
│    §2.2 p.23 │  │ highlighted sentence  │    │   ques-  │
│  Ch.3  p.41  │  └───────────────────────┘    │   tion]  │
│  ──────────  │  Para 3 continues here...     │          │
│  [Concepts]  │                               │          │
│  [Bookmarks] │                               │  ───     │
│              │                               │  Q: What │
│              │                               │  A: ...  │
│              ├───────────────────────────────┤          │
│              │ ◁  ◉  ▷  ─────●──────  1.0x  │          │
│              │  Pause   Page 23 / 312  🎤    │          │
└──────────────┴───────────────────────────────┴──────────┘
```
**Key Components:** PDF display, Sentence highlight overlay, Playback controls, Chapter outline, Q&A panel, Mic button  
**User Stories:** US-PLY-001–009, US-VOI-001–008, US-QA-001–008

---

### SCR-004: Chapter Outline Panel (Side Panel)
**Purpose:** Structural navigation; section summaries  
**Primary Persona:** Alex, Sarah, Maya  
**Triggered by:** Outline tab in reader view  

**Key Components:**
- Hierarchical tree: Part > Chapter > Section > Subsection
- Current position indicator
- 2-sentence AI summary per chapter (hover/expand)
- Click to jump; keyboard-navigable

**User Stories:** US-VOI-003, US-VOI-006, US-CON-006

---

### SCR-005: Concept Browser Panel (Side Panel)
**Purpose:** Explore extracted concepts, defined terms, glossary  
**Primary Persona:** Maya, Sarah, Alex  
**Triggered by:** Concepts tab in reader view  

**Key Components:**
- Concept list (name, definition snippet, page count)
- Search within concepts
- Click concept → see all pages where it appears
- "Defined terms" filter (legal/formal definitions vs general mentions)
- Export button

**User Stories:** US-CON-001–008

---

### SCR-006: Search Results Overlay
**Purpose:** Semantic + full-text search across document  
**Primary Persona:** All  
**Triggered by:** Cmd+F or voice "find..."  

**Key Components:**
- Query input (text + voice)
- Results list: context snippet, page, relevance indicator
- Toggle: Literal match / Semantic match / Both
- "Jump to result" action; results persist as a list while reading

**User Stories:** US-VOI-008, US-QA-001–008

---

### SCR-007: Supplemental Materials Manager
**Purpose:** Attach and manage related documents  
**Primary Persona:** Maya, Sarah, Alex  
**Triggered by:** Document settings > Supplementals  

**Key Components:**
- List of attached supplementals (name, page count, indexing status)
- "Add supplemental" drag-drop zone
- Remove supplemental action
- External references list (detected DOIs, RFC numbers, URLs)

**User Stories:** US-SUP-001–006

---

### SCR-008: Settings
**Purpose:** App-wide and per-document configuration  
**Primary Persona:** All (different sections)  
**Triggered by:** Menu bar → Preferences, or gear icon  

**Sections:**
- **Playback:** Default voice, speed, highlight color
- **AI / LLM:** Provider (Local/OpenAI/Anthropic), model, API key
- **Privacy:** Mic permissions, cloud feature toggles, data retention
- **Storage:** Index location, disk usage per document
- **Accessibility:** Font size, contrast mode, keyboard shortcuts reference
- **Advanced:** Weaviate config, Ollama endpoint

**User Stories:** US-SET-001–007

---

### SCR-009: Onboarding (First Run)
**Purpose:** Configure permissions and defaults on first launch  
**Primary Persona:** All  
**Triggered by:** First app launch  

**Steps:**
1. Welcome + value proposition (30 seconds)
2. Microphone permission request (with explanation)
3. TTS provider selection: Local (free, offline) vs OpenAI (better quality, API key required)
4. LLM selection: Local QWEN via Ollama vs Cloud
5. Storage location confirmation
6. Import your first PDF (guided dropzone)

**User Stories:** US-ING-007, US-SET-001, US-SET-002

---

## Reusable Components

| Component | Used In | Description |
|-----------|---------|-------------|
| PlaybackControls | SCR-003 | Play/pause/speed/volume/mic button |
| SentenceHighlighter | SCR-003 | Overlay on PDF canvas, sentence-synced |
| ChatInterface | SCR-003 (panel) | Q&A thread with voice input |
| ConceptPopover | SCR-003 | Click-word definition overlay |
| BookmarkBar | SCR-003 (panel) | Named bookmarks list |
| ProgressBadge | SCR-001, SCR-002 | Indexing status indicator |
| VoiceInputButton | SCR-003, SCR-006 | Mic with visual state (idle/listening/processing) |
| CitationLink | SCR-003, chat | Page reference that navigates on click |
