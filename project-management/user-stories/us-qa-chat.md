# User Stories: Q&A and Conversational Interface

## US-QA-001
**As** Maya (researcher),  
**I want to** ask "what does [term] mean?" and get an answer sourced from the document itself,  
**so that** I understand the author's specific usage, not a generic definition.

**Acceptance Criteria:**
- RAG retrieval prioritizes in-document definition over general knowledge
- Answer includes direct quote + page/paragraph citation
- If no in-document definition exists, app clearly says so before offering general knowledge

---

## US-QA-002
**As** Sarah (lawyer),  
**I want to** ask "what are the termination conditions?" and get a structured, quoted answer,  
**so that** I can rely on it without verifying manually.

**Acceptance Criteria:**
- Answer surfaces verbatim quotes from relevant sections
- Each quote includes section number + page citation
- If multiple sections are relevant, all are included

---

## US-QA-003
**As** Bob (self-learner),  
**I want** my Q&A history to persist for a document,  
**so that** I can review what I asked and what the app answered in a later session.

**Acceptance Criteria:**
- Q&A history saved per document
- Viewable in chat panel in reading order + session order
- Export as markdown or plain text

---

## US-QA-004
**As** Maya,  
**I want to** ask a follow-up question that builds on the previous answer,  
**so that** I can have a real conversation about the content.

**Acceptance Criteria:**
- Conversational context maintained for the session (last 5–10 exchanges)
- "What else does it say about this?" uses prior context
- Context window clearly resets on new document or explicit "new conversation" command

---

## US-QA-005
**As** Yuki (language learner),  
**I want to** ask "what does [acronym] stand for?" and get the full form as defined in the document,  
**so that** I build my technical vocabulary from the document's own definitions.

**Acceptance Criteria:**
- Acronym expansion uses document content first (where acronym is first spelled out)
- Results include the page where it was first defined
- Acronym index available as a browseable list

---

## US-QA-006
**As** Alex (tech reviewer),  
**I want to** ask "does the example in Section 7 match the definition in Section 2?",  
**so that** I can catch specification inconsistencies without manual cross-checking.

**Acceptance Criteria:**
- App retrieves both passages and presents them side-by-side
- LLM provides a consistency assessment with reasoning
- Result exportable as a review note

---

## US-QA-007
**As** Bob,  
**I want** Q&A answers spoken aloud as well as shown in text,  
**so that** I don't have to look at the screen to get an answer.

**Acceptance Criteria:**
- Answers read aloud by TTS after a question is asked (voice or text)
- Spoken answer truncated intelligently (citations read as "page forty-seven" not the full quote)
- Option to disable spoken answers if user prefers text-only

---

## US-QA-008
**As** Sarah,  
**I want to** ask "summarize the key obligations for each party",  
**so that** I can quickly build a mental model of a contract's structure.

**Acceptance Criteria:**
- App identifies parties from document (by name or "Party A/B")
- Returns structured summary: Party → Obligations list with citations
- Summary clearly scoped to "based on this document" with date caveat if relevant
