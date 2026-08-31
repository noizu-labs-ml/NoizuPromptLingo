# FAQ

Why/when/compared-to-what questions for `skill-manage`. See
[PROJ-HOWTO.md](PROJ-HOWTO.md) for procedures and
[PROJ-ARCH.md](PROJ-ARCH.md) for design rationale.

## Motivation

### Why would I use skill-manage instead of just copying skill dirs into `~/.claude/skills`?

Because copies go stale the moment the source changes and you won't notice.
`skill-manage` symlinks `~/.claude/skills/<name>` back to one canonical copy
(typically the monorepo's `skills/` tree), so an edit to the source is live
everywhere instantly — no re-sync step, no "which copy is newer?" guessing.
The trade-off: your provider dirs are no longer self-contained — deleting or
moving the source tree breaks every symlink pointing at it (shows up as
`broken` in `audit`). If you want an isolated, disposable copy for one-off
experimentation, a plain copy is still simpler than fighting the tool.
→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-enable-or-disable-a-skillagentcommand-for-a-provider).*

### Why does it manage agents and commands too, not just skills?

Because all three are the same underlying problem — a named artifact that a
provider install root expects at a specific path — and Claude/Codex/Grok all
draw on overlapping source trees for them. One tool with one classification
model (`enabled`/`disabled`/`foreign`/`real`/`broken`/`missing-source`) avoids
three slightly-different scripts. The catalog and `enable-set --work-type`
bundle all three kinds together for exactly this reason — a "feature-dev"
bundle is rarely skills-only.

### Why a YAML catalog on top of plain symlinking, instead of just always enabling everything?

Because most providers don't want every skill in the monorepo active at once
— context budget, noise in autocomplete, and irrelevant trigger phrases all
cost something. The catalog lets you name a curated bundle (`feature-dev`,
etc.) and enable it in one command instead of enumerating names by hand each
time. The catalog is pure metadata, not state — deleting `catalog.yaml`
doesn't touch a single symlink, it only removes your ability to bulk-select.
→ *See [howto/work-type-bundles.md](howto/work-type-bundles.md).*

## Fit

### When is skill-manage the wrong tool for the job?

When you need a provider install to diverge from the canonical source — e.g.
testing a modified copy of a skill without touching the shared original.
Symlinks mean one copy serves every provider; there's no built-in "fork this
one instance" workflow. For that, disable the symlink and drop in a real file
instead — `skill-manage` will report it as `real` (not `broken` or `foreign`)
and leave it alone until you explicitly `enable --replace` it back.

### Do I need the YAML catalog to use skill-manage at all?

No. `list` / `enable` / `disable` / `audit` / `status` work with zero catalog
configured — just `config.yaml` (or `SKILL_REPO`/`AGENT_REPO`/`COMMAND_REPO`
env vars) pointing at source trees. The catalog is opt-in, only needed for
`enable-set --work-type`, `work-types show`, and the TUI's tag/work-type
editing (`e` key). Most single-item enable/disable workflows never touch it.

## Comparison

### How is this different from just using `ln -s` by hand?

`skill-manage` adds the bookkeeping `ln -s` doesn't: it tracks which
symlinks it created (vs. ones you or something else made — `foreign`), it
detects dangling links (`broken`) and orphaned real files (`orphan`) across
every provider in one `audit --strict` pass, and it refuses to clobber a real
file/dir without an explicit `--replace` + timestamped backup. Hand-rolled
`ln -s` gives you none of that classification, and one `rm -rf` on a source
tree leaves broken links nobody notices until a provider fails to load a
skill.
→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-find-broken-or-orphaned-links).*

### How does `enable-set --work-type` differ from `enable --all`?

`--all` enables every discovered item of a kind, unconditionally. `enable-set
--work-type <type>` enables only the curated subset named in that catalog
bundle (mixed skills/agents/commands), and silently skips catalog entries
that don't resolve to a discovered source item rather than failing the whole
batch. Use `--all` when you genuinely want everything; use a work type when
you want a considered subset.

## Capability

### Can I use skill-manage across Claude, Codex, and Grok at once, or is it Claude-only?

Yes, all three are first-class providers, though support isn't identical —
Codex agents are only managed "if configured" and Grok agents/commands are
optional, per the provider support table in the README. Omitting `--provider`
on `enable`/`disable`/`audit` acts across every configured provider in one
call; `list` and the TUI let you filter to one.

### Can skill-manage break a skill that's currently working if I run it wrong?

Not silently, by design. Disable only ever removes a destination that is
itself a managed symlink resolving under a configured source root — a real
file or a foreign symlink is left untouched even if you name it. The one
genuinely destructive-looking operation is `enable --replace`, and even that
renames the original to `*.bak.<timestamp>` rather than deleting it. Run
anything you're unsure of with `--dry-run` first.
→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-convert-a-real-file-into-a-managed-symlink).*

## Caveats

### What's the catch with the symlink-everywhere model?

Single point of failure: if the shared source tree is unavailable (unmounted
drive, monorepo not checked out, path typo after a move), every provider that
symlinks into it loses that skill/agent/command at once, and it shows up as
`broken` rather than quietly falling back to a local copy. It also means
provider install dirs are not self-contained — you can't hand someone a
`~/.claude/skills` tarball and expect it to work elsewhere without the source
tree too.

### Why does my `SKILL_REPO`/`AGENT_REPO`/`COMMAND_REPO` env var not win over `config.yaml`?

Because env vars are always appended as **priority-10** source roots, and
lower priority numbers win on a name clash — a `config.yaml` entry for the
same kind with priority < 10 shadows it silently, no warning printed. This is
deliberate: `config.yaml` is treated as your considered, persistent setup, so
a one-off env var (set for a single shell session) can't accidentally
displace it. If you genuinely want the env var to win, give it a lower
number by adding an explicit source-root entry in `config.yaml` instead of
relying on the env var, or unset/rename the conflicting config entry.
→ *See [PROJ-HOWTO.md](PROJ-HOWTO.md#how-to-point-skill-manage-at-your-source-trees).*

### Why don't some Codex or Grok skills show up as manageable in skill-manage?

Because Codex's `skills/.system/` tree and Grok's bundled trees are
intentionally excluded — skill-manage never writes under them, and `audit`
won't report items there as broken/foreign/orphan even if present. These are
provider-internal or vendor-bundled locations, not user-configured source
roots, so treating them as manageable would risk the tool "fixing" links it
never created and doesn't own. If a skill genuinely needs managing, put its
canonical copy in a real configured source root instead.

### Is the example catalog shipped with `catalog init` actually usable as-is in this repo?

No — treat it as a template, not a working config. `schema/catalog.example.yaml`
ships with unprefixed names like `react-engineer`, but this repo's actual
skills use a `trl-` prefix (`trl-react-engineer`). `enable-set` will silently
skip every unmatched entry rather than error, so an unedited catalog looks
like it worked while doing almost nothing. Run `skill-manage catalog validate`
right after `catalog init` to see the drift before relying on it.
→ *See [howto/work-type-bundles.md](howto/work-type-bundles.md).*

### Does skill-manage do anything with editor profiles beyond checking file existence?

No, and that's intentional for v1 — editor profiles are metadata plus an
`[ok]`/`[MISSING]` existence check only; skill-manage never creates, writes,
or applies one automatically. A `[MISSING]` profile file next to a work-type
bundle is informational and does not block `enable-set`.

## Trust

### Does skill-manage ever modify files inside the source tree (the monorepo skills/ dir)?

No. Every mutation happens on the destination side — provider install roots
like `~/.claude/skills/` — via symlink create/remove. The one exception is
`--replace`, which renames a pre-existing *destination-side* real file to
`*.bak.<timestamp>` before symlinking; it does not touch source-tree content.
Nothing in the tool writes into `SKILL_REPO`/`AGENT_REPO`/`COMMAND_REPO`
paths themselves.

### Where does skill-manage store its own state — is anything sent anywhere?

Everything is local: `~/.config/skill-manage/config.yaml` and `catalog.yaml`,
plus the symlinks themselves as the only "state." There's no network call,
telemetry, or external service — `audit`/`status`/`list` are read-only
filesystem walks, and mutation is limited to symlink create/remove under
configured roots.
