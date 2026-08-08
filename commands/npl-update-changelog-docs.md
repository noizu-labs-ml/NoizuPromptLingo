# CHANGELOG.md — Maintenance Guide (Milestone-Based, Monorepo-Aware)

## Purpose

`CHANGELOG.md` at the **project/sub-project root** (NOT under `docs/`) records what changed, grouped into **milestones** rather than versions — this monorepo doesn't version components independently, so meaningful clusters of change get named milestones anchored to **git tags** at their historical boundary commits.

## Structure & Placement

```
<component-root>/
├── CHANGELOG.md          # Newest first; milestone entries
└── docs/ ...             # (changelog does NOT live here)
```

## Entry Format

```markdown
# Changelog — {component}

## [Unreleased]
- [Accumulating changes since the last milestone tag]

## [m4-provider-expansion] — 2026-06-12 — tag: `utilities-media-tool/m4-provider-expansion`
Milestone summary: one or two sentences on what this cluster achieved.

### Added
- groq_chat provider; 13 providers total across 3 categories
### Changed
- Quality-fallback loop now eval-gated via lmstudio-proxy
### Fixed
- ...
### Removed
- ...
```

Rules: newest first; omit empty subsections; every milestone entry carries its date **and** tag; published entries are append-only — never rewrite history, add a correction note instead.

## Milestone & Tag Conventions

- **Milestones, not semver**: name clusters by what they accomplished — `m1-initial-tooling`, `m3-rust-rewrite` — numbered in landing order
- **Tag naming**: `<component-slug>/<milestone>` where component-slug is the path with `/`→`-` (e.g. `utilities/media-tool` → `utilities-media-tool/m4-provider-expansion`); the slug prefix keeps monorepo tags collision-free
- **Tag placement**: annotated tag on the last commit belonging to the milestone: `git tag -a <name> -m "<summary>" <commit>`
- **Do not push tags** without explicit user go-ahead — creating local tags is reversible; pushing publishes them

## Back-Population Procedure (No Existing Changelog)

1. **Scope history to the component**: `git log --oneline --follow -- <path>` (subtree moves matter — check old paths too)
2. **Read messages first**; when a message is inadequate to know what actually changed, inspect the change itself: `git show --stat <sha>`, then the diff for the files that matter
3. **Cluster commits into milestones**: look for natural boundaries — feature landings, rewrites, long gaps, "big cluster then quiet" rhythms; a milestone should be tellable as one story
4. **Name each cluster**, write its entry (summary + Added/Changed/Fixed/Removed), date it by its final commit
5. **Tag each milestone boundary commit** per the convention above
6. Anything after the last milestone boundary goes to `[Unreleased]`

## Incremental Updates (Changelog Exists)

1. Find the most recent entry's tag; review `git log <tag>..HEAD -- <path>`
2. Small delta → fold into `[Unreleased]`
3. Coherent cluster → promote to a new milestone entry + tag
4. **Large interval** (many mixed concerns since the tag) → break it into multiple **checkpoint entries**, each clustered and tagged as in back-population; don't ship one undifferentiated mega-entry

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| CHANGELOG.md | < 400 lines | Move oldest entries to `docs/changelog-archive.md`, leave a link |
| Milestone entry | < 40 lines | Summarize; the diff is the authority, the entry is the story |
| Bullet | 1 line | State the change and its user-visible effect, not the implementation |

## Maintenance Checklist

- [ ] CHANGELOG.md at component root, not docs/
- [ ] Every milestone entry has date + tag; tag actually exists (`git tag -l '<slug>/*'`)
- [ ] Newest first; `[Unreleased]` section present at top
- [ ] Inadequate commit messages resolved by reading diffs, not guessed
- [ ] Large intervals split into checkpoint entries
- [ ] No rewriting of published entries
- [ ] Tags created locally only; pushing requires explicit approval

## Useful Commands

```bash
git log --oneline --follow -- <path>          # component-scoped history
git log --format='%h %ad %s' --date=short -- <path>
git show --stat <sha>                          # when the message says nothing
git log <tag>..HEAD --oneline -- <path>        # delta since last entry
git tag -a <slug>/<milestone> -m "<summary>" <sha>
git tag -l '<slug>/*'                          # audit existing milestone tags
```
