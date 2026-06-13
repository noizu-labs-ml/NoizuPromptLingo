---
id: US-045
title: "Stream narrative output"
slug: "stream-narrative"
personas: [P-001, P-005]
epic: "Narrative Engine"
priority: "should-have"
complexity: "M"
tags: [narrative-engine, streaming, ux, screen-reader, real-time]
---

# US-045: Stream Narrative Output

## User Story

**As a** blind game developer building audio-first experiences (P-005),
**I want to** receive narrative output as a token stream rather than waiting for the full response,
**So that** screen readers and audio systems can begin speaking narrative immediately, reducing perceived latency and improving the real-time feel for players.

## Acceptance Criteria

- [ ] Given an engine with a streaming-capable LLM adapter, when I call `engine.stream(action)`, then an async generator is returned that yields narrative text chunks as they arrive from the LLM.
- [ ] Given a streaming call in progress, when I iterate the generator, then each yielded chunk is a non-empty string fragment of the complete narrative.
- [ ] Given a streaming call that completes, when I collect all chunks and concatenate them, then the result is identical to what `engine.generate(action)` would return for the same input and seed.
- [ ] Given an LLM adapter that does not support streaming, when `engine.stream()` is called, then the full response is buffered and yielded as a single chunk, without raising an error.
- [ ] Given a streaming response that contains an embedded event block (US-041 format), when the stream completes, then `NarrativeStreamResult.events` is populated with parsed events extracted from the full concatenated response.
- [ ] Given a streaming call interrupted by a network error mid-stream, when the error occurs, then a `StreamInterruptedError` is raised with the partial content received up to that point available on the exception.

## Notes

Streaming is especially important for P-005's accessibility workflows where every millisecond of latency before audio playback begins matters. P-001 benefits from streaming for more responsive game UIs. Event parsing (US-041) is deferred until stream completion since events may span multiple chunks.
