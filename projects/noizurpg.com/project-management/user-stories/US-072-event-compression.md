---
id: US-072
title: "Periodic Event Compression"
slug: "event-compression"
personas: [P-001, P-006]
epic: "Memory System"
priority: "must-have"
complexity: "L"
tags: [memory-system, compression, summarization, llm, token-management]
---

# US-072: Periodic Event Compression

## User Story

**As an** indie AI game developer (P-001),
**I want to** compress older journal events into LLM-generated summaries at configurable intervals,
**So that** the memory system stays within token budget limits for long sessions without losing narrative continuity.

## Acceptance Criteria

- [ ] Given a session with 200 events and `compression_threshold: 100` configured, when `memory.compress(session_id="s1")` is called, then all events older than the most recent 100 are passed to the LLM and replaced with a single `{event_type: "compressed_summary", data: {summary: "..."}, covers_event_ids: [...]}` entry.
- [ ] Given a compressed summary entry, when `memory.events(session_id="s1")` is called, then the summary entry appears in correct chronological position and `covers_event_ids` lists all original event IDs that were summarized.
- [ ] Given `auto_compress: true` and `compression_threshold: 100` configured, when `memory.record()` causes total event count to exceed the threshold, then compression is triggered automatically without the caller invoking `compress()` explicitly.
- [ ] Given an LLM timeout during compression, when the error occurs, then the original events are preserved intact, the partial summary is discarded, and a `CompressionError` is raised.
- [ ] Given a `compression_strategy` set to a custom callable, when compression is triggered, then the custom callable is invoked with the event list instead of the default LLM summarizer, and its string return value is stored as the summary.
- [ ] Given `memory.compression_history(session_id)` called after two compression passes, then it returns a list of two entries each with `compressed_at`, `event_count_before`, and `summary_preview` fields.

## Notes

Aisha Patel (P-006) requires compression for studio games with multi-hour sessions generating thousands of events. The `covers_event_ids` field enables audit tracing from summary back to source events (US-071). `L` complexity due to LLM call orchestration, error recovery, and auto-trigger logic.
