# Storage Architecture

## Database

Single SQLite file at `~/.claude-assist/claude-assist.db` (configurable via `CLAUDE_ASSIST_DATA_DIR`).

### Pragmas

- `journal_mode = WAL` — concurrent readers with single writer
- `foreign_keys = ON` — referential integrity

### Extensions

- **sqlite-vec** — vector similarity search via virtual tables; stores 384-dim float32 embeddings

## Tables (Logical)

### Core Tables

| Table | Purpose |
|-------|---------|
| conversations | Indexed conversation metadata (path, dates, title, tags, status) |
| messages | Individual messages with role, content, timestamp |
| universal_messages | Structured cross-harness messages used for transfer, memory hooks, and continuation |
| raw_transcript_events | Harness-specific raw records retained for audit, replay, and future re-parsing |
| thread_edits | Edited conversation threads (injected/collapsed messages, status, updated_at) |
| datasets | Named dataset collections for fine-tuning |
| dataset_entries | Individual training examples linked to conversations |
| prompts | Saved/extracted prompts with tags and evals |
| project_metadata | User-editable project metadata (title, description, tags as JSON array) |
| tag_metadata | Tag display metadata (name, color defaulting to `#06B6D4`, description) |

### Virtual Tables

| Table | Type | Purpose |
|-------|------|---------|
| messages_fts | FTS5 | Full-text search over `messages.content`, synced via insert/delete/update triggers |
| conversation_vectors | vec0 (sqlite-vec) | 384-dim float32 embeddings for semantic search; created only if sqlite-vec loads successfully |

## Content Hashing

Files are hashed on index to skip re-processing unchanged conversations. Only new or modified JSONL files trigger re-indexing.

## Harness Retention Model

`messages` is intentionally lossy and optimized for search. `universal_messages` keeps structured roles, content blocks, provenance, and provider hints. `raw_transcript_events` preserves original harness records so adapters can be improved without losing information.

Harness transfer should flow through the universal layer:

```text
Harness -> raw_transcript_events -> universal_messages -> target harness exporter
```

Gemini, OpenCode, Aider, and Other adapters are accepted as harness values but remain stubbed until sample transcripts are captured and validated.

## Configuration

| Env Variable | Default | Purpose |
|-------------|---------|---------|
| `CLAUDE_ASSIST_DATA_DIR` | `~/.claude-assist` | Database and data directory |
| `CLAUDE_ASSIST_WATCH_PATHS` | `~/.claude/projects` | Colon-separated JSONL source paths |
| `CLAUDE_ASSIST_WATCH` | `true` | Enable/disable file watching |
| `PORT` | `3100` | API server port |
