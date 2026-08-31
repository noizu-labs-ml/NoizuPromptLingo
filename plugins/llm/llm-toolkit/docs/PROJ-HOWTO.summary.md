# How To — Summary

- **Get up and running the first time** — install deps, start the API + Web UI, confirm it's indexing your conversations.
- **Search your conversations from the terminal** — find a past conversation by keyword without opening the browser.
- **Launch the full-screen terminal UI** — browse, view threads, edit, and manage conversations without leaving the terminal.
- **Rebuild the search index** — pick up new or edited conversation files without restarting the API.
- **Point Claude Assist at a different LLM provider** — configure the embedding provider or the LLM used by Convert/Safety Watch to something other than the local default. → [howto/configure-llm-provider.md](howto/configure-llm-provider.md)
- **Edit a conversation thread (non-destructively)** — collapse, remove, reorder, or inject messages without ever touching the source JSONL; every edit is a saved, revertible draft/version. → [howto/edit-conversation.md](howto/edit-conversation.md)
- **Pull a reusable skill/agent/runbook out of a conversation** — turn a good past conversation into a checked-in artifact instead of retyping the same instructions next time. → [howto/convert-conversation.md](howto/convert-conversation.md)
- **Curate a fine-tuning dataset from your conversations** — tag message ranges with quality labels and export them in a provider-ready format. → [howto/export-dataset.md](howto/export-dataset.md)
- **Move, duplicate, or archive a conversation** — rehome a JSONL file to a different project, clone it before editing, or archive noise out of your lists. → [howto/manage-conversations.md](howto/manage-conversations.md)
