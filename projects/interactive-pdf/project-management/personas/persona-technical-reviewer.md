# Persona: Alex Rivera — Technical Writer / Doc Reviewer

## Profile
- **Age:** 34
- **Role:** Senior Technical Writer, infrastructure software company
- **Environment:** MacBook Pro, external monitor, reviews RFCs and API specs
- **Tech Comfort:** Very High — uses terminal, scripting, multiple editors

## Goals
- Navigate 500-page specification documents efficiently by structure
- Verify that terminology is used consistently across sections
- Cross-reference definitions against their usage in examples
- Listen to drafts being read aloud to catch awkward phrasing

## Frustrations
- PDFs have no structural awareness — no jump-to-symbol, no dependency graph
- Manually checking term consistency across 50 sections is tedious
- Can't hear the document to catch prose-level issues while doing other things
- No way to ask "does Section 7's example match the definition in Section 2?"

## Behaviors
- Thinks in document structure; always opens TOC first
- Jumps between sections non-linearly — doesn't read front-to-back
- Exports notes/findings for other team members
- Uses multiple docs simultaneously (spec + reference implementation)

## Key Scenarios
1. Asks "show me all uses of 'endpoint' and highlight inconsistent capitalization" — app surfaces discrepancies
2. Listens to a new section at 1.5x speed while writing notes; pauses to ask clarifying questions
3. Cross-references a term in a spec with its definition in an attached RFC

## Acceptance Criteria
- Structural navigation: jump to any section/subsection by name or number
- Concept consistency checking: detect same-term variations (case, hyphenation)
- Export Q&A sessions as markdown notes with page citations
- Cross-document concept linking between attached supplemental PDFs
