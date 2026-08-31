# Storage Architecture

## Database

Single SQLite file at `~/.llm-toolkit/llm-toolkit.db` (configurable via `LLM_TOOLKIT_DATA_DIR`; legacy `CLAUDE_ASSIST_DATA_DIR` accepted).

### Pragmas

- `journal_mode = WAL` — concurrent readers with single writer
- `foreign_keys = ON` — referential integrity

### Extensions

- **sqlite-vec** — vector similarity via virtual tables; 384-dim float32 embeddings. If the extension fails to load, semantic search degrades gracefully (`_vecAvailable = false`).

## Tables

### Core content

| Table | Purpose |
|-------|---------|
| conversations | Metadata: harness, project/source paths, title, tags JSON, status, counts, dates |
| messages | Flattened role/content/timestamp rows optimized for FTS and list views |
| universal_messages | Structured cross-harness messages (JSON payload) for transfer, memory hooks, continuation |
| raw_transcript_events | Provider-native records retained for audit, replay, and re-parse |
| conversation_work_items | Optional LLM-extracted work units (kind, title, evidence, message range, confidence) |

### Curation

| Table | Purpose |
|-------|---------|
| thread_edits | Non-destructive edit versions (messages JSON, status, description) |
| datasets | Named fine-tuning collections |
| dataset_entries | Training examples linked to conversations (quality gold/silver/bronze) |
| saved_prompts | Extracted/saved prompts with tags and optional evals |
| project_metadata | User-editable project title/description/tags |
| tag_metadata | Tag color (default `#06B6D4`) and description |
| settings | Key/value app config persistence |

### Virtual tables

| Table | Type | Purpose |
|-------|------|---------|
| messages_fts | FTS5 | Full-text over `messages.content`; insert/delete/update triggers keep sync |
| conversation_vectors | vec0 (sqlite-vec) | 384-dim embeddings for semantic KNN; created only if sqlite-vec loads |

## Content hashing

Files are hashed on index to skip re-processing unchanged conversations. Only new or modified JSONL files trigger re-indexing (mod-time / hash tracking in the indexer).

## Harness retention model

`messages` is intentionally lossy and search-oriented. `universal_messages` keeps structured roles, content blocks, provenance, and provider hints. `raw_transcript_events` preserves original harness records so adapters can improve without data loss.

```text
Harness JSONL → raw_transcript_events → universal_messages → target harness exporter
                     ↘ messages (+ FTS / vectors)
```

Gemini, OpenCode, Aider, and Other are valid `harness` values but importers remain stubbed until sample transcripts are validated.

## Configuration

| Env Variable | Default | Purpose |
|-------------|---------|---------|
| `LLM_TOOLKIT_DATA_DIR` | `~/.llm-toolkit` | Database and data directory |
| `LLM_TOOLKIT_WATCH_PATHS` | *(unset → defaults)* | Colon-separated paths (treated as Claude harness sources when set) |
| `LLM_TOOLKIT_WATCH` | `true` | Enable/disable file watching (`false` disables) |
| `PORT` | `3100` | API server port |

Legacy aliases: `CLAUDE_ASSIST_DATA_DIR`, `CLAUDE_ASSIST_WATCH_PATHS`, `CLAUDE_ASSIST_WATCH`.

Default index sources when watch paths are unset:

- Claude: `~/.claude/projects` (jsonl)
- Codex: `~/.codex/sessions` (jsonl)
