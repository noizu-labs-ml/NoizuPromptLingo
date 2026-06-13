---
id: US-079
title: "Research Paper PDF Export"
slug: "research-paper-pdf-export"
personas: [P-008, P-001]
epic: "Research & Community"
priority: "should-have"
complexity: "M"
tags: [research, pdf, export, download]
---

# US-079: Research Paper PDF Export

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** download a well-formatted PDF of a research paper,
**So that** I can read it offline, annotate it in my tools, and archive it in my reference library.

## Acceptance Criteria

- [ ] Given a research paper page, when the user clicks "Download PDF," then a PDF is generated and downloaded to their device
- [ ] Given the generated PDF, then it includes the paper title, author, date, abstract, full body, and a canonical URL footer
- [ ] Given a paper with figures or tables, then they are preserved in the PDF output with captions
- [ ] Given the PDF, then it is accessible (tagged PDF, proper heading hierarchy, alt text on images)
- [ ] Given a large paper, when the PDF is generating, then a loading state is shown and the button is disabled until complete
- [ ] Given a PDF download, then the filename follows the pattern `{slug}-noizu-com.pdf`

## Notes

Implementation options: server-side via Puppeteer/headless Chrome rendering a print CSS route, or pre-generated PDFs stored as static assets. Pre-generated is simpler and more reliable; server-side allows always-current content. Related to US-076 (reading experience), US-077 (citations). Consider print CSS as a prerequisite.
