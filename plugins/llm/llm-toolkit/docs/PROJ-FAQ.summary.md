# FAQ Summary

Question index for [PROJ-FAQ.md](PROJ-FAQ.md). Use this to check "is my question already anticipated?" before reading the full file.

## Motivation
- Why would I use Claude Assist instead of just grepping `~/.claude/projects/*.jsonl` myself?
- Why index into SQLite instead of searching the JSONL files directly on every query?
- Why does the project have both a Web UI and a terminal TUI instead of just one?

## Fit
- Is this worth running if I only use Claude Code occasionally and have a handful of conversations?
- Should I run this on a shared or team machine?
- Is the multi-harness "agent-watch-dog" layer ready to use today?

## Comparison
- How is this different from Claude Code's own `--resume`/`--continue`?
- How does Thread Editing differ from hand-editing the JSONL file?
- FTS keyword search vs semantic search — which should I use?
- Rehome vs Clone — which one do I use to reorganize a conversation?

## Capability
- Can it edit my actual conversation history?
- Can I use it against a remote/hosted LLM instead of the local embedding model?
- Does the `--interface tui` CLI flag actually switch me into the terminal UI?

## Caveats
- Why does dataset export have three quality tiers (gold/silver/bronze) if exporters don't filter by them?
- Can I trust a Convert-generated artifact to use as-is?
- What happens if `sqlite-vec` isn't available on my platform?
- Will this get slow as my conversation archive grows?

## Trust
- What happens to my conversation data — does Claude Assist copy, move, or upload it?
- What happens to LLM provider API keys I enter in Settings?
