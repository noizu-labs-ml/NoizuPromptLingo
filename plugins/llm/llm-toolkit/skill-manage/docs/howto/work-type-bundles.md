# How to: bulk-enable a curated toolset by work type

**Goal:** enable a whole recommended bundle of skills/agents/commands (and see
editor-profile hints) with one command, instead of enabling items one at a
time.
**Prereqs:** a populated `~/.config/skill-manage/catalog.yaml`; item names in
the catalog must match names discoverable in your configured source trees
(`skill-manage list`) or `enable-set` silently skips them.

1. Bootstrap a catalog if you don't have one yet (refuses to overwrite without `--force`):
   ```bash
   skill-manage catalog init
   ```
2. See what's in it:
   ```bash
   skill-manage catalog show
   # catalog: ~/.config/skill-manage/catalog.yaml
   # skills=5 agents=3 commands=3 work_types=8 editor_profiles=3
   ```
3. List the available work types and inspect one:
   ```bash
   skill-manage work-types list
   skill-manage work-types show feature-dev
   ```
   `show` prints the bundle's skills/agents/commands plus each editor-profile
   file with an `[ok]`/`[MISSING]` existence check.
4. Preview the bulk-enable before mutating anything:
   ```bash
   skill-manage enable-set --work-type feature-dev --provider claude --dry-run
   ```
5. Run it for real:
   ```bash
   skill-manage enable-set --work-type feature-dev --provider claude
   ```

**Verify:**
```bash
skill-manage list --work-type feature-dev --provider claude
```

**Gotchas:**
- `enable-set` prints `skip: unknown skill/agent/command '<name>'` for any
  catalog entry that doesn't resolve to a discovered source item — this is
  the single most common surprise, and it means the catalog and your source
  trees have drifted. Run `skill-manage catalog validate` first:
  ```bash
  skill-manage catalog validate
  # warn: catalog skills.react-engineer: not found in sources
  # ...
  # catalog valid (14 warnings)
  ```
  Warnings don't block `enable-set` — it validates each name again at
  enable-time and just skips misses, so treat `catalog validate` as an
  up-front sanity pass, not a gate.
- The example catalog (`schema/catalog.example.yaml`, seeded by `catalog init`)
  ships with names like `react-engineer` and `technical-writer` that assume
  un-prefixed skill names — this repo's actual skills use a `trl-` prefix
  (`trl-react-engineer`). Edit the catalog's item names to match
  `skill-manage list skills` output before relying on `enable-set`.
- Editor profiles are metadata-only in v1 — `[MISSING]` next to a profile file
  is informational, it does not block enabling and skill-manage never creates
  or writes that file for you.
- `--replace` is accepted by `enable-set` too, for converting real files to
  symlinks across the whole bundle in one pass.
