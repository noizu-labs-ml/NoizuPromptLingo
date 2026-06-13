---
id: US-077
title: "Paper Citation & Reference Tools"
slug: "paper-citation-reference-tools"
personas: [P-008, P-001]
epic: "Research & Community"
priority: "could-have"
complexity: "M"
tags: [research, citation, bibliography, academic]
---

# US-077: Paper Citation & Reference Tools

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** copy properly formatted citations for research papers in multiple citation styles,
**So that** I can reference Keith's work accurately in my own publications without manual formatting.

## Acceptance Criteria

- [ ] Given a research paper page, when the user clicks "Cite this paper," then a modal opens with formatted citation options
- [ ] Given the citation modal, when a style is selected (APA, MLA, Chicago, BibTeX), then the citation updates to that format in real time
- [ ] Given a citation style selected, when the user clicks "Copy," then the citation text is copied to clipboard and a success toast appears
- [ ] Given a paper with a DOI or arXiv ID, then those identifiers are included in the citation output
- [ ] Given a BibTeX citation, when copied, then it includes all required BibTeX fields (author, title, year, url, note)

## Notes

Citation data sourced from paper frontmatter (author, year, title, venue, doi). BibTeX is the highest-priority format for academic users. Related to US-076 (reading experience).
