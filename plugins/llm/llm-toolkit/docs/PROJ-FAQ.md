# FAQ

Anticipated why/when/compared-to-what questions. See [PROJ-HOWTO.md](PROJ-HOWTO.md) for procedures and [PROJ-ARCH.md](PROJ-ARCH.md) for design rationale.

## Motivation

### Why would I use Claude Assist instead of just grepping `~/.claude/projects/*.jsonl` myself?

Grep finds lines; it doesn't understand conversation structure, rank relevance, or find meaning-based matches. Claude Assist parses the JSONL into `conversations`/`messages` tables, adds FTS5 keyword search and MiniLM semantic search, and gives you a browsable UI plus a CLI. The honest trade-off: it's another process to run and a SQLite DB to maintain, for something grep already does for free if you just need "does this string appear anywhere."

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-search-your-conversations-from-the-terminal).*

### Why index into SQLite instead of searching the JSONL files directly on every query?

Re-scanning every JSONL file on every keyword search doesn't scale past a few dozen conversations, and semantic search needs precomputed embeddings — you can't cosine-compare against raw text at query time. SQLite plus FTS5/sqlite-vec gives sub-second search over a growing archive. The cost is a derived index that can drift from disk until the watcher or a manual reindex catches up.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-rebuild-the-search-index).*

### Why does the project have both a Web UI and a terminal TUI instead of just one?

Different moments call for different interfaces: the Web UI is better for thread reading (rendered markdown, Mermaid, LaTeX) and dataset curation with a mouse; the Ink TUI is for staying inside a terminal-only workflow (tmux/zellij, SSH sessions, keyboard-only). Both hit the same Hono API and SQLite DB, so neither is the "real" one — pick per-task, not once.

## Fit

### Is this worth running if I only use Claude Code occasionally and have a handful of conversations?

Marginal. The value compounds with volume — search, artifact extraction, and dataset curation matter most once you have dozens-to-hundreds of sessions worth mining. With a handful of conversations, `--resume`/`--continue` in Claude Code itself and manual JSONL reading cover the same ground with zero extra setup.

### Should I run this on a shared or team machine?

No, not as-is. It's a local-first, single-user tool: one SQLite DB at `~/.llm-toolkit/llm-toolkit.db`, no auth layer, no multi-tenant isolation, and it indexes whatever `~/.claude/projects/` (or configured watch paths) it can read on that box. Running it where multiple people's conversation logs are readable means every user's data lands in one shared, unauthenticated index.

### Is the multi-harness "agent-watch-dog" layer ready to use today?

Partially. Claude Code and Codex importers are implemented; Gemini, OpenCode, and Aider are documented stubs with no working importer yet. Safety Watch and memory extraction are also stubs. If your workflow is Claude Code only, the feature is moot; if you need Gemini/OpenCode ingestion now, it isn't there.

→ *See [PROJ-ARCH.md](PROJ-ARCH.md#multi-harness-agent-watch-dog).*

## Comparison

### How is this different from Claude Code's own `--resume`/`--continue`?

`--resume`/`--continue` reopen one session inline in Claude Code with no search, no cross-session view, and no editing. Claude Assist indexes *all* your sessions across projects, adds keyword/semantic search and a Thread Viewer, and layers non-destructive editing, artifact extraction, and dataset curation on top — then hands you back the resume command for the session you found (see Thread page).

### How does Thread Editing differ from hand-editing the JSONL file?

Hand-editing a JSONL risks corrupting the `parentUuid` chain or breaking Claude Code's ability to reopen the session, and there's no undo. Thread Editing (collapse, remove, reorder, inject) always writes a new *version* — the source JSONL is never touched — so you can compare or revert. The trade-off is indirection: you're editing through an operation model, not raw text, which is more ceremony for a one-line fix.

### FTS keyword search vs semantic search — which should I use?

Use FTS5 (the CLI default and Web UI's default mode) when you remember the actual wording — a function name, an error string, a flag. Use semantic search (`mode=semantic` on the Web UI's `/search` page) when you remember the *idea* but not the phrasing. Semantic search costs more (embedding the query, ANN comparison) and can surface false positives on vague queries; FTS is faster and more precise when you know the term.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-search-your-conversations-from-the-terminal).*

### Rehome vs Clone — which one do I use to reorganize a conversation?

Rehome when the conversation is filed under the wrong project and there should still be exactly one copy of it; clone when you want two independent copies to diverge (e.g. one trimmed for a dataset, one kept intact). Rehome physically moves the source `.jsonl` on disk and updates the index in place — there is no second conversation afterward. Clone leaves the original untouched and returns a brand-new conversation id with its own copy, which then has its own drafts, edits, and tags independent of the source.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-move-duplicate-or-archive-a-conversation).*

## Capability

### Can it edit my actual conversation history?

No, not in place. Every edit operation (collapse/remove/reorder/inject) produces a new versioned record; the original JSONL Claude Code wrote is never mutated. This is deliberate — it keeps Claude Code's own resume/continue behavior intact regardless of what you do in Claude Assist.

### Can I use it against a remote/hosted LLM instead of the local embedding model?

Search embeddings are always local (MiniLM-L6-v2, no network call). LLM-*powered* features — Convert and Safety Watch — do support remote providers: Anthropic, OpenAI, Groq, Cerebras, DeepSeek, Z.ai, or a custom OpenAI-compatible/LiteLLM endpoint, configured in Settings or via env vars.

→ *See [howto/configure-llm-provider.md](howto/configure-llm-provider.md).*

### Does the `--interface tui` CLI flag actually switch me into the terminal UI?

Yes — `bin.ts` now calls `parseInvocation()` from `interface-selection.ts`, so `--interface tui` (and `LLM_TOOLKIT_DEFAULT_INTERFACE`/`CODE_ASSIST_DEFAULT_INTERFACE`) route to the `interactive` command as expected. The explicit `interactive` subcommand still works too.

→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-launch-the-full-screen-terminal-ui).*

## Caveats

### Why does dataset export have three quality tiers (gold/silver/bronze) if exporters don't filter by them?

The tiers are a labeling convenience for you, not an export filter — every entry you've added to a dataset goes out on export regardless of its quality label. Filtering happens at *add time*: only add the ranges you actually want in the export, and use the label to track which are your best examples for later re-curation, not to gate what ships. Omitting `quality` entirely defaults an entry to `silver`.

→ *See [howto/export-dataset.md](howto/export-dataset.md).*

### Can I trust a Convert-generated artifact to use as-is?

No — treat it as a first draft, not a finished skill/agent/runbook. Generation is pattern-detection over the message range you pick (stronger with an LLM provider configured, weaker heuristic fallback without one), and the `/candidates` endpoint that suggests source ranges doesn't verify the range contains a complete, self-consistent solution. Skim the source messages and edit the output before committing it into a skills/agents directory.

→ *See [howto/convert-conversation.md](howto/convert-conversation.md).*

### What happens if `sqlite-vec` isn't available on my platform?

Semantic search degrades gracefully — the app keeps working with FTS5 keyword search, but the `/search` page's `mode=semantic` and vector-backed features silently have nothing to rank against. There's no loud error today; if semantic results look empty or unranked, that's the first thing to check.

### Will this get slow as my conversation archive grows?

SQLite + FTS5 comfortably handles thousands of conversations for keyword search; semantic search cost scales with embedding time on first index (MiniLM runs locally, no GPU assumed) and with ANN comparison size thereafter. There's no built-in pruning/archival policy beyond manual archive/tag — a very large, never-archived history is the main path to slowdown, not the indexing engine itself.

## Trust

### What happens to my conversation data — does Claude Assist copy, move, or upload it?

It reads your JSONL files in place (default `~/.claude/projects/`, configurable via `LLM_TOOLKIT_WATCH_PATHS`) and writes a derived SQLite index to `~/.llm-toolkit/`; source files are never moved or deleted by search/index/edit operations. The one operation that *does* move a file is the explicit rehome action, which relocates a conversation's JSONL to a different project directory on your own disk — nothing leaves the machine unless you configure a remote LLM provider for Convert/Safety Watch.

→ *See [howto/manage-conversations.md](howto/manage-conversations.md).*

### What happens to LLM provider API keys I enter in Settings?

They're resolved through a fallback chain — masked-key detection, per-provider env vars, then a stored `app_config` value — and used only to call that provider's completion endpoint for Convert/Safety Watch. If you don't configure an LLM provider, no API key is needed and no external call is made for search or browsing.

→ *See [howto/configure-llm-provider.md](howto/configure-llm-provider.md).*
