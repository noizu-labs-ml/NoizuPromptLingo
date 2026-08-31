# How to: edit a conversation thread (non-destructively)

**Goal:** collapse, remove, reorder, or inject messages in a conversation without ever touching the source JSONL — every edit is saved as a new draft/version you can revert.
**Prereqs:** API running; conversation id from Browse/Thread view.

## Via the Web UI

1. Open a conversation's Thread page, then click **Edit** (`/thread/:id/edit`).
2. Use the editor to:
   - **Collapse** a run of messages into a single summary line
   - **Remove** selected messages
   - **Reorder** messages by dragging
   - **Inject** a new user/assistant/system message at a given position
3. Edits accumulate in a **draft** — nothing is finalized until you say so.
4. Click **Finalize** to turn the draft into a permanent, named edit version.

## Via the full-screen terminal UI

```bash
npx tsx packages/cli/bin.ts interactive
```
Navigate to the **Edit** page for a conversation. Key bindings (`packages/cli/src/interactive/pages/EditPage.tsx`):

| Key | Action |
|-----|--------|
| `space` | toggle-select current message |
| `e` | edit selected message |
| `i` | insert a message from a template |
| `d` | delete (with confirm) |
| `r` | change role of selected message |
| `s` | save draft |
| `f` | finalize draft |
| `u` | revert draft (confirm) |
| `A` / `X` | select all / deselect all |
| `K` | bulk-compress selection |
| `L` | bulk-simplify selection |

## Via the API directly

```bash
# Start (or fetch existing) draft
curl -X POST localhost:3100/api/conversations/<id>/draft \
  -H 'content-type: application/json' -d '{"messages": []}'

# Update the in-progress draft
curl -X PATCH localhost:3100/api/conversations/<id>/draft \
  -H 'content-type: application/json' \
  -d '{"messages": [...]}'

# Finalize it into a permanent edit
curl -X POST localhost:3100/api/conversations/<id>/draft/finalize \
  -d '{"description": "Trimmed setup noise"}'

# Or apply a one-shot operation list without the draft flow
curl -X POST localhost:3100/api/conversations/<id>/edits \
  -H 'content-type: application/json' \
  -d '{"description": "Collapse install steps", "operations": [
        {"type": "collapse", "startIndex": 2, "endIndex": 6, "summary": "Ran install + config"}
      ]}'
```

Operation shapes accepted (`packages/api/src/services/editor.ts`):
- `{"type": "collapse", "startIndex", "endIndex", "summary"}`
- `{"type": "remove", "indices": [...]}`
- `{"type": "reorder", "newOrder": [...]}`
- `{"type": "inject", "atIndex", "role", "content"}`

**Verify:** `GET /api/conversations/<id>/edits` lists finalized edit versions; `GET /api/conversations/<id>/draft` shows the in-progress draft (or `{"data": null}` once finalized/deleted).
**Gotchas:**
- The source `.jsonl` Claude Code wrote is never mutated by any of this — edits are always a new stored version, which is also why Claude Code's own `--resume`/`--continue` keeps working regardless of what you do here.
- `reorder` silently no-ops if `newOrder` isn't a full permutation of the message indices (wrong length or out-of-range index) — the original order is returned unchanged rather than erroring.
- Only one draft exists per conversation at a time; `POST /draft` returns the existing draft instead of creating a second one, and `DELETE /draft` discards it (use before finalizing if you want to start over).
