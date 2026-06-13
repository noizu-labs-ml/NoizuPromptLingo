---
id: US-096
title: "Screen Reader Compatibility for Technique Detail"
slug: "screen-reader-compatibility"
personas: [P-001, P-004]
epic: "Accessibility & Performance"
priority: "should-have"
complexity: "M"
tags: [accessibility, screen-reader, wcag, a11y, aria]
---

# US-096: Screen Reader Compatibility for Technique Detail

## User Story

**As a** researcher relying on a screen reader (P-001, P-004),
**I want to** access technique detail pages with full semantic markup and ARIA labels,
**So that** I can read and understand all technique information — including structured fields, severity ratings, code examples, and related links — without relying on visual layout.

## Acceptance Criteria

- [ ] Given a technique detail page, when a screen reader traverses it, then the page has a single `<h1>` with the technique name and a logical heading hierarchy (h2 for sections, h3 for subsections)
- [ ] Given severity and category badges, when the screen reader encounters them, then the announced text includes the full label (e.g., "Severity: Critical" not just a colored icon)
- [ ] Given code examples (proof-of-concept prompts), when rendered, then they use `<code>` or `<pre>` elements with an accessible label identifying them as code blocks
- [ ] Given the technique taxonomy tree (category breadcrumb), when announced, then it reads as "Category: Prompt Injection > Instruction Override" in a meaningful sequence
- [ ] Given dynamic content (e.g., loading state, scan result updates), when it changes, then ARIA live regions announce the change to the screen reader without requiring focus
- [ ] Given all images and icons on the page, when they convey information, then they have descriptive `alt` text; decorative images have `alt=""`

## Notes

Test with NVDA + Firefox and VoiceOver + Safari as primary screen reader combinations. Screen reader testing should be part of the acceptance criteria checklist for any new catalog-facing component. WCAG 2.1 AA is the minimum; AAA is a stretch goal for technique pages given their research audience.
