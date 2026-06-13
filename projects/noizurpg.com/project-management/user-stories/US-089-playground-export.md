---
id: US-089
title: "Export Playground Session to Code"
slug: "playground-export"
personas: [P-004, P-008]
epic: "Cloud & Commercial Services"
priority: "should-have"
complexity: "M"
tags: [playground, export, code-generation, onboarding, education]
---

# US-089: Export Playground Session to Code

## User Story

**As a** tabletop GM (P-004) and CS educator (P-008),
**I want to** export my browser-based playground session as a runnable Python script,
**So that** I can transition from playground exploration to local development without having to manually re-configure everything I set up in the UI.

## Acceptance Criteria

- [ ] Given a playground session with at least one component configured (Character, World, Narrative, Quest, or Dialogue), when I click "Export to Code", then a Python file is generated that reproduces the exact session configuration using the NoizuRPG framework API
- [ ] Given the exported Python file, when I run `pip install noizurpg && python exported_session.py` on a machine with a valid API key set, then the script executes without modification and produces output equivalent to the playground session
- [ ] Given the exported code, when I inspect it, then it contains inline comments explaining each configuration block (character stats, world state, quest definition, etc.) in plain English
- [ ] Given a playground session that used the managed model (no user API key), when I export to code, then the script contains a clearly marked `# TODO: Set your LLM provider here` placeholder with links to the provider setup docs (US-077, US-078, US-079)
- [ ] Given the export modal, when displayed, then it offers three format options: Python script, Jupyter notebook (`.ipynb`), and YAML config, and the selected format is downloaded directly to the user's machine

## Notes

This is the bridge between the no-code Cloud Playground (US-083) and local Python development — the primary conversion funnel from free-tier user to installed framework user. The Jupyter export format specifically serves P-008 (CS educators) for classroom use.
