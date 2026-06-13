---
id: US-099
title: "Export to Markdown, JSON & PDF"
slug: "export-markdown-json-pdf"
personas: [P-001, P-002, P-003, P-004, P-005, P-008]
epic: "Export & Integration"
priority: "must-have"
complexity: "M"
tags: [export, markdown, json, pdf, data-portability, integration]
---

# US-099: Export to Markdown, JSON & PDF

## User Story

**As a** worldbuilder who uses the platform alongside other tools (P-001, P-002, P-003, P-004, P-005, P-008),
**I want to** export my universe data as Markdown, structured JSON, or a formatted PDF,
**So that** I can use my lore in writing apps, share printable references, or migrate to another platform without data lock-in.

## Acceptance Criteria

- [ ] Given I am on Universe Settings > Export, when I select "Markdown" and click Export, then I receive a ZIP containing one `.md` file per canon entry, with frontmatter (title, type, tags) and full body content.
- [ ] Given I select "JSON" and click Export, when the download completes, then I receive a single `.json` file containing the full universe schema: entries, relationships, metadata, and generation history, conforming to the documented export schema.
- [ ] Given I select "PDF" and click Export, when the download completes, then I receive a formatted PDF with a table of contents, one section per entry category, and internal hyperlinks between cross-referenced entries.
- [ ] Given a universe contains more than 500 entries, when I request an export, then the system processes it asynchronously and sends me an email with a download link when complete (within 10 minutes).
- [ ] Given I request any export format, when private entries exist in the universe, then those entries are excluded from the export unless I check "Include private entries" and I am the universe owner.

## Notes

JSON export schema must be versioned and publicly documented to support third-party tooling. Related: US-100 (game engine export). PDF generation should use a server-side renderer (e.g., headless Chrome or Puppeteer) to ensure consistent layout across platforms.
