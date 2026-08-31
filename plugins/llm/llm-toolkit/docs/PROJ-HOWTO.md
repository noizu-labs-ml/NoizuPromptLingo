# How To

Task-oriented guides for the things you'll actually do with Claude Assist. See [PROJ-ARCH.md](PROJ-ARCH.md) for *what it is* and [PROJ-LAYOUT.md](PROJ-LAYOUT.md) for *where things live*.

## How to: get up and running the first time

**Goal:** install deps, start the API + Web UI, confirm it's indexing your conversations.
**Prereqs:** Node.js >= 18, pnpm >= 8 (`npm install -g pnpm` or `corepack enable`).

1. Install workspace deps and symlink the launcher onto your PATH:
   ```bash
   cd utilities/agent/llm-toolkit
   make install
   ```
2. Launch it:
   ```bash
   llm-toolkit
   ```
   With `zellij` installed and not already inside a session, this opens a split pane (web 80% / api 20%). Otherwise it falls back to the same thing without panes (`llm-toolkit --no-zellij`).
3. Open http://localhost:5173 in a browser.

**Verify:** `curl -sf http://localhost:3100/api/health` returns 200, and the Dashboard shows a non-zero conversation count (it auto-indexes `~/.claude/projects/` on first boot).
**Gotchas:**
- No `zellij` on PATH, or you're already inside a zellij session → it silently falls back to `--no-zellij` (foreground web, backgrounded API). Not a bug.
- `make install` skips `pnpm install` if `node_modules/.bin` already exists — delete it first if you need a hard refresh, or run `pnpm install` directly.
- Ports are fixed unless overridden: `LLM_TOOLKIT_API_PORT` (default 3100), `LLM_TOOLKIT_WEB_PORT` (default 5173).

## How to: search your conversations from the terminal

**Goal:** find a past conversation by keyword without opening the browser.
**Prereqs:** none — the CLI starts the API for you if it isn't already running.

```bash
llm-toolkit search "auth middleware"
```

**Verify:** results print with conversation id, project, and matched snippet.
**Gotchas:** this is FTS5 keyword search, not semantic — for meaning-based search use the Web UI's `/search` page with `mode=semantic`.

## How to: list recent sessions without the web or API server

**Goal:** quickly see what ran recently, where it ran, and the first/last message from each indexed session.
**Prereqs:** run `llm-toolkit` at least once so its local SQLite index exists.

```bash
llm-toolkit recent                 # last hour
llm-toolkit recent 2h              # supplied interval
llm-toolkit recent 1 day --full    # untruncated first/last messages
llm-toolkit recent 1d --json       # scripting output
```

Each entry includes its title, session ID, update time, project directory, runner/harness, transcript source path, and first/last message. This command opens the existing database read-only and does not start the API or web UI.

**Gotcha:** results reflect the current local index. If the API watcher has not been running, open `llm-toolkit` or run `llm-toolkit index` to refresh it.

## How to: launch the full-screen terminal UI

**Goal:** browse, view threads, edit, and manage conversations without leaving the terminal.
**Prereqs:** none.

```bash
npx tsx packages/cli/bin.ts interactive
```

**Verify:** an Ink full-screen app opens with Explore, Thread, Edit, Convert, Datasets, Prompts, Settings, Safety Watch, and Style Guide pages.
**Gotchas:** `--interface`/`LLM_TOOLKIT_DEFAULT_INTERFACE` are parsed by `packages/cli/src/interface-selection.ts` but that parser is never wired into `bin.ts` — passing `--interface tui` currently has no effect. Use the explicit `interactive` command instead.

## How to: rebuild the search index

**Goal:** pick up new or edited conversation files without restarting the API.
**Prereqs:** API running.

```bash
npx tsx packages/cli/bin.ts index
```

**Verify:** `GET /api/index/status` (Settings page → Index Paths, or `curl localhost:3100/api/index/status`) shows an updated timestamp/count.
**Gotchas:** the API also watches `LLM_TOOLKIT_WATCH_PATHS` via chokidar by default — manual reindex is only needed if you set `LLM_TOOLKIT_WATCH=false` or added a new index path since last boot.

## How to: point Claude Assist at a different LLM provider
Configure the embedding provider or the LLM used by Convert/Safety Watch to something other than the local default.
→ *See [howto/configure-llm-provider.md](howto/configure-llm-provider.md)*

## How to: edit a conversation thread (non-destructively)
Collapse, remove, reorder, or inject messages without ever touching the source JSONL — every edit is a saved, revertible draft/version.
→ *See [howto/edit-conversation.md](howto/edit-conversation.md)*

## How to: pull a reusable skill/agent/runbook out of a conversation
Turn a good past conversation into a checked-in artifact instead of retyping the same instructions next time.
→ *See [howto/convert-conversation.md](howto/convert-conversation.md)*

## How to: curate a fine-tuning dataset from your conversations
Tag message ranges with quality labels and export them in a provider-ready format.
→ *See [howto/export-dataset.md](howto/export-dataset.md)*

## How to: move, duplicate, or archive a conversation
Rehome a JSONL file to a different project, clone it before editing, or archive noise out of your lists.
→ *See [howto/manage-conversations.md](howto/manage-conversations.md)*
