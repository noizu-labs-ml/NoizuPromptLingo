---
id: US-096
title: "Educational Sandbox Mode"
slug: "educational-sandbox"
personas: [P-008]
epic: "Developer Experience & Community"
priority: "should-have"
complexity: "M"
tags: [education, sandbox, learning, classroom, documentation]
---

# US-096: Educational Sandbox Mode

## User Story

**As a** CS educator (P-008),
**I want to** run NoizuRPG in an educational sandbox mode that provides step-by-step explanations of every framework operation, artificial delays, and simplified output formats,
**So that** my students can observe what the framework is doing at each stage without being overwhelmed by production-grade complexity.

## Acceptance Criteria

- [ ] Given `NoizuRPGConfig(mode="educational")`, when any component performs an operation, then it emits a human-readable explanation event (e.g., `"NarrativeEngine: Building prompt with 3 context memories and current world state..."`) before and after each LLM call
- [ ] Given educational mode, when an LLM call is made, then the full prompt sent to the model is logged to the educational output stream so students can inspect what was actually sent
- [ ] Given educational mode, when a state transition occurs (quest phase change, character stat update, memory storage), then the framework emits a before/after diff in human-readable format showing exactly what changed and why
- [ ] Given educational mode, when I configure `educational_delay_ms=500`, then the framework inserts a 500ms pause between each logged step, allowing students following along in real-time to read each step before the next fires
- [ ] Given a Jupyter notebook environment with educational mode enabled, when I run a cell that executes a game turn, then the educational output is rendered inline as formatted markdown cells (not raw text) using `IPython.display`

## Notes

Educational mode is purely observational — it does not change any framework behavior, only adds instrumentation. The Jupyter integration specifically supports P-008's classroom workflow alongside the export feature (US-089). The mode should be clearly labeled so students understand production deployments do not behave this way.
