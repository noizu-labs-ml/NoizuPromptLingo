# How to: curate a fine-tuning dataset from your conversations

**Goal:** tag good (and bad) message ranges across conversations with a quality label, then export them in a provider-ready fine-tuning format.
**Prereqs:** API running; conversations already indexed.

1. Create a dataset:
   ```bash
   curl -X POST localhost:3100/api/datasets \
     -H 'content-type: application/json' \
     -d '{"name": "auth-patterns"}'
   ```
2. Add entries from a conversation's message range, with a quality label (`gold`, `silver`, or `bronze`). `messages` is the actual prompt/completion pair for the entry, not just a pointer — pull it from `GET /api/conversations/:id/messages`:
   ```bash
   curl -X POST localhost:3100/api/datasets/auth-patterns/entries \
     -H 'content-type: application/json' \
     -d '{"conversationId": "<id>", "startIndex": 2, "endIndex": 10, "quality": "gold",
          "messages": [{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]}'
   ```
   Easier in practice: use the Web UI (`/datasets/auth-patterns`) / TUI Datasets page to add entries by selecting message ranges visually — it fills `messages` for you.
3. Adjust an entry's quality or prompt later:
   ```bash
   curl -X PATCH localhost:3100/api/datasets/auth-patterns/entries/<entryId> \
     -H 'content-type: application/json' \
     -d '{"quality": "silver"}'
   ```
4. Export:
   ```bash
   curl "localhost:3100/api/datasets/auth-patterns/export?format=openai" -o auth-patterns.jsonl
   ```
   `format` is one of `openai`, `anthropic`, or `jsonl` (raw).

**Verify:** the exported file has one JSON record per line, each record's shape matching the target format's fine-tuning schema.
**Gotchas:**
- `messages` is stored as its own copy at add-time, not a live reference — editing the source conversation afterward does not change already-added entries.
- `bronze`/`silver`/`gold` are just labels stored as-is; the exporters don't filter by quality automatically — filter which entries you add, not which you export. Omit `quality` and it defaults to `silver`.
