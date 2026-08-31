# Agent Watch Dog Architecture

`agent-watch-dog` is the evolution of `llm-toolkit` from a Claude Code log browser into a local-first **session continuity** tool for multiple agent harnesses. Goals: index transcripts, retain raw provider records, normalize to a universal message format, support continuation/transfer, and leave room for memory extraction and Safety Watch.

## Harnesses

A harness is the runtime/client that produced a session transcript.

| Harness | Importer | Universal → harness export | Notes |
|---------|----------|----------------------------|-------|
| `claude` | implemented | transform implemented | Claude Code JSONL under `~/.claude/projects` by default |
| `codex` | implemented | transform implemented | Codex sessions under `~/.codex/sessions` by default |
| `gemini` | stubbed | stubbed | Need real transcripts before parsing |
| `opencode` | stubbed | stubbed | Need real transcripts before parsing |
| `aider` | stubbed | stubbed | Need real transcripts before parsing |
| `other` | stubbed | stubbed | Reserved for user-defined adapters |

Default source registration includes Claude and Codex only. Other harnesses may be configured explicitly; importers intentionally no-op until formats are validated.

## Raw transcript retention

Provider transcripts land in `raw_transcript_events`, separate from searchable `messages`. Raw retention matters for hidden metadata, tool call ids, parent ids, model names, partial responses, session state, and resume hints.

Rules:

1. Never assume normalized text is enough for replay.
2. Preserve the raw event before deriving universal messages.
3. Re-parse from raw events when adapter behavior changes.

## Universal message format

`UniversalMessage` is the canonical cross-harness representation for memory, transfer, and continuation. It keeps:

- normalized role: `system`, `developer`, `user`, `assistant`, or `tool`
- content blocks: `text`, `thinking`, `redacted_thinking`, `tool_use`, `tool_result`, `image`, `audio`, `document`, `unknown`
- provenance: harness, source path, raw index, parent id
- provider hints / metadata for reconstruction

Search still uses flattened `messages`. Universal messages are the structured layer; raw events are the audit/replay layer.

## Transform vs transfer

```text
Source harness transcript
  → raw events
  → UniversalThread / UniversalMessage
  → harness-transform export (Claude / Codex payloads)
  → (planned) harness-transfer write / resume into target harness
```

- **harness-transform** (`harness-transform.ts`) — Implemented exporters build Claude message payloads and Codex JSONL event streams from universal messages, collecting unsupported-block notices. Import into universal prefers the indexer normalizer path rather than ad-hoc re-import.
- **harness-transfer** (`harness-transfer.ts`) — Façade still returns pending warnings for all targets until compatibility tests and write-back semantics are complete. Do not treat transfer as production-ready.

Session workflow (`session-workflow.ts`) builds continuation payloads (`continue` | `transfer`) and marks export readiness from transform support; memory hooks remain stubs.

## Safety Watch

Safety Watch is a UI and architecture stub only. It does not enforce, grant, deny, or revoke filesystem permissions.

Planned concerns: folder-level sensitivity, env posture (dev/stage/prod), enable/disable profiles, audit review, context-sensitive permission recommendations.

## Memory hooks

Memory extraction is deferred. Storage has structure for hooks to consume canonical messages + raw provenance, but no durable memory policy should land until design covers:

- what to remember vs never retain
- session compression
- review / correction workflow
- scope by harness, project, folder, sensitivity
- how continuation payloads cite or attach memory
