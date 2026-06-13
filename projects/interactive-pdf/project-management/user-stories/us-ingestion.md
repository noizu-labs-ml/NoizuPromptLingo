# User Stories: Document Ingestion & Management

## US-ING-001
**As** Bob (self-learner),  
**I want to** drag a PDF onto the app and have it start playing within 60 seconds,  
**so that** I don't have to configure anything before listening.

**Acceptance Criteria:**
- Basic TTS playback begins within 60s of import (before full indexing)
- Indexing for Q&A continues in background with a status indicator
- No required configuration on first import

---

## US-ING-002
**As** Maya (researcher),  
**I want to** see indexing progress broken down by stage (text extraction → embedding → summaries → concepts),  
**so that** I know which features are available and when.

**Acceptance Criteria:**
- Progress indicator shows: Parsing → Embedding → Summarizing → Complete
- Q&A badge shows "Indexing..." until ready, then becomes active
- Estimated time remaining shown

---

## US-ING-003
**As** Sarah (lawyer),  
**I want to** import multiple related PDFs and group them as a single "matter" or collection,  
**so that** I can query across all of them at once.

**Acceptance Criteria:**
- Create a named collection; drag multiple PDFs into it
- Q&A can be scoped to "this document" or "this collection"
- Collection appears as a single entry in library with expandable sub-docs

---

## US-ING-004
**As** Alex (tech reviewer),  
**I want to** reimport an updated version of a document,  
**so that** the index reflects the latest content without losing my notes.

**Acceptance Criteria:**
- "Update document" option replaces source PDF and triggers re-index
- Existing Q&A history and bookmarks are preserved where possible
- Diff indicator shows what changed (page count, structural changes)

---

## US-ING-005
**As** Bob,  
**I want to** have the app remember all my documents between sessions,  
**so that** my library is waiting for me every time I open the app.

**Acceptance Criteria:**
- All imported documents persist in library across app restarts
- Last-read position is saved per document
- No manual "save" required

---

## US-ING-006
**As** Maya,  
**I want to** see document metadata (title, author, page count, file size) in the library,  
**so that** I can identify documents at a glance.

**Acceptance Criteria:**
- Library shows: cover thumbnail (first page), title, author (from PDF metadata or filename), page count
- Sort by: date added, title, last opened, length

---

## US-ING-007
**As** all users,  
**I want** my documents processed entirely on-device by default,  
**so that** confidential documents never leave my machine.

**Acceptance Criteria:**
- No data sent to any server unless user explicitly opts in (TTS API toggle)
- Local TTS fallback available (macOS AVSpeechSynthesizer)
- Privacy policy visible at import time
- Cloud features clearly labeled as such

---

## US-ING-008
**As** Sarah,  
**I want to** delete a document and all its indexed data with one action,  
**so that** I can manage storage and comply with data retention requirements.

**Acceptance Criteria:**
- "Remove document" deletes source copy, all embeddings, summaries, and concept data
- Confirmation dialog warns about permanent deletion
- Option to "remove from library but keep file" (removes index only)
