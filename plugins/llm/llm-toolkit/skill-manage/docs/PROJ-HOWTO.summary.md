# How To — Summary

Task list only; see [PROJ-HOWTO.md](PROJ-HOWTO.md) for full steps.

- **Install skill-manage** — get the `skill-manage` binary on your `PATH`.
- **Point skill-manage at your source trees** — tell the tool where your skills/agents/commands actually live so it can discover them.
- **Enable or disable a skill/agent/command for a provider** — symlink an item into (or remove it from) a provider's install root.
- **Bulk-enable a curated toolset by work type** — enable a whole recommended bundle of skills/agents/commands/editor-profile hints in one command, driven by a YAML catalog. → `howto/work-type-bundles.md`
- **Fork a skill/agent/command to test local edits without touching the shared source** — disable the symlink, drop in a real copy to edit freely, then `enable --replace` to rejoin the shared, live-updating source when done.
- **Convert a real file into a managed symlink** — bring an existing (non-symlink) skill/agent/command under skill-manage's management without losing it.
- **Find broken or orphaned links** — catch stale symlinks and provider-side files skill-manage doesn't know about, before they cause confusion.
- **Browse and toggle interactively** — eyeball everything enabled/disabled across kinds and flip items without memorizing names.
