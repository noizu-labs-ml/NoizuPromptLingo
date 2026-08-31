# How to: move, duplicate, or archive a conversation

**Goal:** reorganize conversations without touching the underlying JSONL by hand.
**Prereqs:** API running; conversation id from Browse/`GET /api/conversations`.

## Rehome — move the source JSONL to a different project directory

```bash
curl -X POST localhost:3100/api/conversations/<id>/rehome \
  -H 'content-type: application/json' \
  -d '{"project": "/home/you/Work/other-project"}'
```
This physically moves the `.jsonl` file on disk and updates the index's project association — it is the correct way to fix a conversation logged under the wrong project (e.g. captured before you `cd`'d into the right repo).

## Clone — duplicate before a destructive-feeling edit

```bash
curl -X POST localhost:3100/api/conversations/<id>/clone
```
Returns a new conversation id with its own copy. Since Thread Editing is already non-destructive (edits create versions, source JSONL untouched), clone is mainly useful when you want two independently taggable/exportable copies (e.g. one trimmed for a dataset, one kept full).

## Archive — hide noise from default lists

```bash
curl -X POST localhost:3100/api/conversations/<id>/archive
```

## Tag

```bash
curl -X POST localhost:3100/api/conversations/<id>/tag \
  -H 'content-type: application/json' \
  -d '{"tags": ["backend", "needs-followup"]}'
```

**Verify:** rehome/archive/tag all return `{"success": true}`; clone returns `{"data": {"id": "<newId>"}}` (HTTP 201). Follow up with `GET /api/conversations/:id` to confirm the new project path, archived flag, or tags stuck.
**Gotchas:**
- Rehome moves the real file — if the target directory doesn't exist or isn't writable the request fails and nothing moves; create the target dir first for a brand-new project.
- Archive doesn't delete anything; it's a list filter. There is no unarchive-by-CLI shortcut documented here — check the Web/TUI conversation view for an unarchive toggle before assuming it's one-way.
