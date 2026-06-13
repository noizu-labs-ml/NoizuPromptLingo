# User Stories Index — therobotbrowses

## Overview

107 user stories across 8 phases, organized as individual files in the `stories/` directory.

## Story Files by Phase

| Phase | Codename | Stories | Count | Key Milestone |
|-------|----------|---------|-------|---------------|
| 0 | Shell | US-001 – US-020 | 20 | Navigate and display raw HTML in TUI |
| 1 | Render | US-100 – US-119 | 20 | ACID1 pass |
| 2 | Paint | US-201 – US-211 | 11 | Visual web pages |
| 3 | Interact | US-301 – US-312 | 12 | Interactive pages |
| 4 | Connect | US-401 – US-412 | 12 | Full MCP tool surface |
| 5 | Extend | US-501 – US-510 | 10 | User-installable extensions |
| 6 | Comply | US-601 – US-611 | 11 | Standards compliance |
| 7 | Ship | US-701 – US-711 | 11 | Public alpha |

## Priority Summary

| Priority | Count | Meaning |
|----------|-------|---------|
| P0 | ~45 | Must have — blocks phase milestone |
| P1 | ~52 | Should have — expected in phase |
| P2 | ~10 | Nice to have — can slip |

## Standards Coverage

Each story's frontmatter includes a `standards` field linking to relevant specs:
- W3C/WHATWG specifications (HTML, CSS, DOM, Fetch, etc.)
- IETF RFCs (HTTP, TLS, WebSocket, DNS, Cookies)
- ISO/IEC standards (WCAG/40500, Unicode/10646, PDF/32000, Common Criteria/15408)
- ACID test suites (Acid1, Acid2, Acid3)
- Web Platform Tests (WPT)
- Accessibility laws (EN 301 549, Section 508, ADA, EAA)

See `docs/standards/` for full research references.

## Numbering Convention

- `US-0XX` — Phase 0 (Shell)
- `US-1XX` — Phase 1 (Render)
- `US-2XX` — Phase 2 (Paint)
- `US-3XX` — Phase 3 (Interact)
- `US-4XX` — Phase 4 (Connect)
- `US-5XX` — Phase 5 (Extend)
- `US-6XX` — Phase 6 (Comply)
- `US-7XX` — Phase 7 (Ship)

## File Format

Each story file uses YAML frontmatter:
```yaml
---
id: US-XXX
title: "Story title"
phase: N
phase_name: Codename
priority: P0|P1|P2
personas: [P-001, A-001, ...]
standards: ["Spec 1", "Spec 2", ...]
---
```

## Browsing Stories

List all stories: `ls stories/`
Find by phase: `grep -l "phase: 0" stories/*.md`
Find by persona: `grep -l "P-004" stories/*.md`
Find by priority: `grep -l "priority: P0" stories/*.md`
Find by standard: `grep -l "WCAG" stories/*.md`
