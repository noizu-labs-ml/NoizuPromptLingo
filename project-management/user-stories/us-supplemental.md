# User Stories: Supplemental Materials & Cross-Document

## US-SUP-001
**As** Maya (researcher),  
**I want to** attach supplemental PDFs to a main document,  
**so that** cited papers are available in context and can be queried together.

**Acceptance Criteria:**
- "Add supplemental" attaches a PDF to the current document
- Supplemental docs indexed separately but cross-searchable with main doc
- File structure: `{doc-id}/supplemental/{supp-id}/`

---

## US-SUP-002
**As** Maya,  
**I want to** ask "what does the Smith et al. appendix say about this method?",  
**so that** I can query a supplemental document by name in natural language.

**Acceptance Criteria:**
- RAG query can be scoped to supplemental by name or "all supplementals"
- Answer cites which supplemental document it came from
- Seamless if only one supplemental is attached

---

## US-SUP-003
**As** Alex (tech reviewer),  
**I want** citations in the main document to link to corresponding supplemental PDFs when available,  
**so that** I can follow references without manually opening a second document.

**Acceptance Criteria:**
- Citation link detection in main doc (e.g., [Smith 2023], Figure A.1)
- If a matching supplemental is attached, citation becomes a clickable link
- Clicking opens the supplemental at the relevant page in a side-by-side or overlay view

---

## US-SUP-004
**As** Sarah (lawyer),  
**I want to** query across a main contract and all its exhibits at once,  
**so that** I don't miss provisions scattered across attached schedules.

**Acceptance Criteria:**
- "Search all documents in this matter" covers main + all supplementals
- Results clearly labeled with source document name and page
- Answers synthesize across sources: "Section 4.2 and Exhibit B, page 3 both address..."

---

## US-SUP-005
**As** Maya,  
**I want to** remove a supplemental document without affecting the main document index,  
**so that** I can manage my reference set as my research evolves.

**Acceptance Criteria:**
- Remove supplemental: deletes its index and cross-references but leaves main doc intact
- Confirmation prompt before deletion
- Cross-reference links in main doc that pointed to removed supplemental show a "not found" indicator

---

## US-SUP-006
**As** Alex,  
**I want to** see a list of all detected external references in a document (DOIs, URLs, RFC numbers),  
**so that** I can identify which supplementals might be worth importing.

**Acceptance Criteria:**
- Reference detection: DOIs, arXiv IDs, RFC numbers, ISBNs, bare URLs
- Listed in "References" panel with copy-to-clipboard
- "Import as supplemental" action for DOI/arXiv (fetches PDF if available)
