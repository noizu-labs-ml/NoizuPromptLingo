# Agent Watch Dog Architecture

`agent-watch-dog` is the evolution of `claude-assist` from a Claude Code log browser into a local-first session continuity tool for multiple agent harnesses. Its core job is to index transcripts, retain raw provider records for audit and replay, normalize conversations into a universal message format, and prepare future workflows for memory extraction and harness-to-harness transfer.

## Harnesses

A harness is the runtime or client that produced a session transcript.

| Harness | Status | Notes |
|---------|--------|-------|
| `claude` | importer implemented | Reads Claude Code JSONL records from configured sources. |
| `codex` | importer implemented | Reads Codex JSONL sessions and session metadata. |
| `gemini` | stubbed | TODO: collect real transcripts and validate format before parsing. |
| `opencode` | stubbed | TODO: collect real transcripts and validate format before parsing. |
| `aider` | stubbed | TODO: collect real transcripts and validate format before parsing. |
| `other` | stubbed | Reserved for future user-defined adapters. |

Default source registration only includes Claude and Codex paths. Gemini, OpenCode, Aider, and Other may be configured explicitly, but their importers intentionally no-op until real transcript examples are available.

## Raw Transcript Retention

Provider transcripts are stored as raw events in `raw_transcript_events`. This is separate from searchable messages. Raw retention is important because provider formats contain quirks that may matter later: hidden metadata, tool call ids, parent ids, model names, partial response records, session state, and provider-specific resume hints.

The rule is:

1. Never assume normalized text is enough for replay.
2. Preserve the raw event before deriving universal messages.
3. Re-parse from raw events when adapter behavior changes.

## Universal Message Format

`UniversalMessage` is the canonical cross-harness representation used for memory, transfer, and future continuation workflows. It keeps:

- a normalized role: `system`, `developer`, `user`, `assistant`, or `tool`
- structured content blocks such as `text`, `thinking`, `tool_use`, `tool_result`, `image`, `audio`, `document`, and `unknown`
- provenance: source harness, source path, raw index, and parent id when available
- provider hints for reconstruction where practical

Search still uses a flattened `messages` table. Universal messages are the structured layer; raw transcript events are the audit/replay layer.

## Harness Transfer

The transfer model is:

```text
Source Harness Transcript -> Raw Events -> UniversalThread -> Target Harness Payload
```

This avoids direct provider-to-provider conversions such as `codex -> claude`. Each adapter should implement two boundaries:

- importer: `Harness -> Universal`
- exporter: `Universal -> Harness`

Exporter stubs exist for Claude, Codex, Gemini, OpenCode, Aider, and Other, but they are intentionally placeholders until continuation semantics and transcript samples are validated. The universal format should remain stable enough that new providers can be added without rewriting the storage model.

## Safety Watch

Safety Watch is currently a UI and architecture stub only. It is not an enforcement boundary and does not grant, deny, monitor, or revoke filesystem permissions yet.

Planned concerns include folder-level sensitivity, environment posture such as dev/stage/prod, quick enable/disable profiles, audit review, and context-sensitive permission recommendations.

## Memory Hooks

Memory extraction is intentionally deferred to a separate architecture discussion. The storage layer now has enough structure for memory hooks to consume canonical messages and raw provenance, but no durable memory policy should be implemented until the plan covers:

- what should be remembered
- what must never be retained
- session compression strategy
- review and correction workflow
- memory scope by harness, project, folder, and sensitivity
- how continuation payloads cite or attach memory
