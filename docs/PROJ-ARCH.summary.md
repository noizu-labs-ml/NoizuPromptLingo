# Architecture Summary

Single-file Bash CLI wrapping `gh` for GitHub repo creation and editing.

**Core flow**: Parse CLI flags → detect parent repo context → resolve values through 5-tier precedence (CLI > _OVERRIDE env > parent > base env > defaults) → interactive confirm or `--yes` → create/edit repo → optionally grant team access.

**Components**: CLI parser, parent repo detector, value resolver, interactive prompt, repo creator, team granter, edit mode.

**Design**: No dependencies beyond `gh` and `git`. Interactive by default, scriptable with `--yes`. Parent inheritance reduces boilerplate in monorepo/submodule workflows.
