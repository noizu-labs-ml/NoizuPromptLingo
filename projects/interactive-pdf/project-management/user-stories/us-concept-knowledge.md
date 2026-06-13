# User Stories: Concept Extraction & Knowledge Graph

## US-CON-001
**As** Maya (researcher),  
**I want** the app to automatically extract key concepts and their definitions from a document,  
**so that** I have a concept map without manual annotation.

**Acceptance Criteria:**
- Concepts extracted during background indexing
- Each concept linked to all pages/paragraphs where it appears
- Concept list browseable in side panel; sorted by frequency or first appearance

---

## US-CON-002
**As** Sarah (lawyer),  
**I want to** see a glossary of all defined terms (e.g., "Affiliate" means…) extracted from a contract,  
**so that** I don't have to hunt for definitions while reading.

**Acceptance Criteria:**
- Agent recognizes defined terms patterns: `"[Term]" means...`, `[Term] (as defined in Section X)`
- Glossary shows term, definition snippet, and page citation
- Terms hyperlinked — clicking a term in the reader jumps to its definition

---

## US-CON-003
**As** Maya,  
**I want to** see which concepts appear together most frequently,  
**so that** I can identify the document's central thesis and supporting arguments.

**Acceptance Criteria:**
- Co-occurrence data used to suggest concept relationships
- Visual graph optional (not required for MVP)
- Text list: "Concept A co-appears most with: B (12x), C (8x), D (6x)"

---

## US-CON-004
**As** Alex (tech reviewer),  
**I want** the app to flag when a term is used inconsistently (different capitalization, hyphenation, or meaning),  
**so that** I can catch terminology drift during document review.

**Acceptance Criteria:**
- Detects case variants: "endpoint" vs "Endpoint" vs "End Point"
- Detects possible meaning drift (LLM-assisted: "this usage seems different from definition")
- Results listed in review panel with page citations for each variant

---

## US-CON-005
**As** Bob (self-learner),  
**I want to** tap a highlighted word and see a quick definition sourced from the document,  
**so that** I can clarify a term mid-listening without asking a full question.

**Acceptance Criteria:**
- Click/tap any word → popover shows: in-document usage, brief definition
- Popover dismisses automatically on next playback action
- If no in-document definition, shows a one-sentence general definition

---

## US-CON-006
**As** Maya,  
**I want** AI-generated summaries for each page and chapter available before I read them,  
**so that** I can decide whether to read in full or skim.

**Acceptance Criteria:**
- Page summary: 2–3 sentences, generated during background indexing
- Chapter summary: 1 paragraph, rolls up page summaries
- Summaries shown in chapter outline panel alongside section titles

---

## US-CON-007
**As** Alex,  
**I want to** export the concept list as a structured markdown document,  
**so that** I can include it in my review deliverables.

**Acceptance Criteria:**
- Export: Concept Name | First Defined (page) | Appears On (pages) | Definition snippet
- Formats: Markdown, CSV
- Export includes document title and export timestamp

---

## US-CON-008
**As** Maya,  
**I want** the concept index to link to specific line numbers within pages,  
**so that** I can jump precisely to where a concept is used.

**Acceptance Criteria:**
- "Concept appears on page 12, paragraph 3" navigates to that exact position
- Highlighted in the reader when jumped-to
- Back-navigation returns to concept browser
