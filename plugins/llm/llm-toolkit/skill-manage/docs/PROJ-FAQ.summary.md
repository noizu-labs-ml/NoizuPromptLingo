# FAQ — Question Index

Companion to [PROJ-FAQ.md](PROJ-FAQ.md): question headings only, for a cheap
relevance check.

## Motivation
- Why would I use skill-manage instead of just copying skill dirs into `~/.claude/skills`?
- Why does it manage agents and commands too, not just skills?
- Why a YAML catalog on top of plain symlinking, instead of just always enabling everything?

## Fit
- When is skill-manage the wrong tool for the job?
- Do I need the YAML catalog to use skill-manage at all?

## Comparison
- How is this different from just using `ln -s` by hand?
- How does `enable-set --work-type` differ from `enable --all`?

## Capability
- Can I use skill-manage across Claude, Codex, and Grok at once, or is it Claude-only?
- Can skill-manage break a skill that's currently working if I run it wrong?

## Caveats
- What's the catch with the symlink-everywhere model?
- Why does my `SKILL_REPO`/`AGENT_REPO`/`COMMAND_REPO` env var not win over `config.yaml`?
- Why don't some Codex or Grok skills show up as manageable in skill-manage?
- Is the example catalog shipped with `catalog init` actually usable as-is in this repo?
- Does skill-manage do anything with editor profiles beyond checking file existence?

## Trust
- Does skill-manage ever modify files inside the source tree (the monorepo skills/ dir)?
- Where does skill-manage store its own state — is anything sent anywhere?
