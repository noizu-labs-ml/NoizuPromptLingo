# 34: CLI Index Rebuild (command output)

| Field | Value |
|-------|-------|
| ID | SCR-34 |
| Surface | cli-command |
| Type | primary |
| Category | Indexing & Ingestion |
| Route / Entry | `llm-toolkit index` |
| Primary Personas | P-001, P-008 |
| User Stories | US-012, US-080 |

## Description
One-shot Ink command that triggers a full index rebuild via `POST /api/index/rebuild` and polls `/api/index/status` until the indexer returns to idle, printing progress and a final summary (conversations indexed / errors / skipped). The manual counterpart to the automatic file-watcher indexing (US-010).

## Entry Points
- `llm-toolkit index` from any shell

## Key Components
- Status line — `starting → indexing → done`
- Result summary — indexed count, error count, skipped count

## States
- **Indexing:** polling loop shows the in-progress state; large histories index without blocking the terminal from other work (US-080 — the poll itself is non-blocking, output updates as status changes)
- **Done:** final counts printed once the API reports `status: "idle"` with a `lastIndexed` timestamp
- **Error:** rebuild trigger failure (`API error: {status}`) surfaces immediately rather than polling indefinitely

## Interactions
- No flags beyond invocation — this is a full rebuild trigger; incremental reindexing happens automatically via the watcher (US-011) and via the Settings "Reindex" button (SCR-14/27) for full-vs-incremental choice

## Navigation
- **From:** shell invocation
- **To:** n/a (prints and exits)
