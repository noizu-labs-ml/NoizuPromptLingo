# update-layout

**Type**: Command
**Category**: Documentation Maintenance
**Status**: Core

## Purpose

The `update-layout` command synchronizes `docs/PROJECT-LAYOUT.md` with the current codebase structure, ensuring documentation accurately reflects the filesystem while preserving manually-added descriptions and annotations. It automates detection of structural changes—new directories, removed files, reorganizations—and updates documentation accordingly. This is essential for maintaining accurate developer onboarding materials without losing custom documentation work during refactoring.

Primary use cases include keeping layout docs current after major refactoring, architecture changes, or framework upgrades, and performing quarterly reviews to catch structural drift.

## Key Capabilities

- **Intelligent merge**: Preserves user annotations and custom sections while regenerating structural elements from filesystem
- **Change detection**: Identifies new/removed directories and files by cross-referencing filesystem with existing documentation
- **Framework adaptation**: Automatically adapts section names and structure based on detected framework (Rails, Django, Phoenix, Next.js, Express)
- **Validation**: Verifies all documented paths exist, checks tree accuracy, and identifies orphaned references
- **Specification compliance**: Enforces PROJECT-LAYOUT spec with all 11 required sections and correct formatting conventions
- **Incremental updates**: Handles both initial generation and incremental updates with equal effectiveness

## Usage & Integration

- **Triggered by**: Manual agent invocation via `@npl update-layout` or `--validate` flag for dry-run
- **Outputs to**: `docs/PROJECT-LAYOUT.md` with change summary report listing additions/removals
- **Complements**: `update-arch` command for architecture documentation, `init-project` for new project setup
- **Prerequisites**: Requires NPL dependencies loaded via `npl-load c "syntax,fences"` and `npl-load spec "project-layout-spec"`

The command integrates with the broader NPL documentation ecosystem, following the PROJECT-LAYOUT specification defined in `core/specifications/project-layout-spec.md`.

## Core Operations

**Basic invocation** for incremental update:
```bash
@npl update-layout
```

**Validation without modification**:
```bash
@npl update-layout --validate
```

**Workflow phases**:

1. **Load** - Parse existing `docs/PROJECT-LAYOUT.md`, extract user annotations marked with `<!-- user: ... -->`, preserve custom sections
2. **Scan** - Generate fresh directory tree (`tree -L 3 -d`) and file inventory (`find` for configs/docs), identify changes
3. **Update** - Regenerate tree diagrams, merge file listings (add new, remove deleted), preserve descriptions for unchanged items
4. **Validate** - Verify path references, check naming conventions, detect orphaned documentation

## Configuration & Parameters

| Parameter | Purpose | Default | Notes |
|-----------|---------|---------|-------|
| `--validate` | Dry-run validation without modifications | N/A | Reports discrepancies only |
| `--skip` | Skip NPL dependency loading | Empty | Pass already-loaded components |
| Framework detection | Auto-adapt section names | Auto-detect | Based on `package.json`, `Gemfile`, `mix.exs`, etc. |
| Tree depth | Directory nesting level shown | 3 | Prevents overwhelming detail |
| File scan | Config/doc file discovery depth | 3 | Limits scope to key files |

## Integration Points

- **Upstream dependencies**:
  - `npl-load` for syntax and specification loading
  - `project-layout-spec.md` for structure enforcement
  - Filesystem state via `tree` and `find` commands

- **Downstream consumers**:
  - Developer onboarding documentation readers
  - `update-arch` command for cross-referencing
  - Version control for tracking documentation evolution

- **Related utilities**:
  - `init-project` - Initial project setup with layout docs
  - `update-arch` - Architecture documentation refresh
  - `yq` - YAML index management for metadata

## Merge Strategy

**Preserved content** (survives updates):
- User-added file descriptions and directory annotations
- Custom sections not in standard template
- Notes marked with `<!-- user: ... -->`
- Framework-specific adaptations

**Updated content** (regenerated):
- Tree diagrams (full regeneration from filesystem)
- File listings (add new entries, remove deleted)
- Path references and examples
- Statistics (directory/file counts)

**Removed content** (cleaned up):
- References to deleted files/directories
- Outdated path examples and broken links
- Orphaned annotations for non-existent items

## Required Sections

All 11 sections from PROJECT-LAYOUT spec:
1. Directory Structure Overview (with annotated tree)
2. Core Application Layer
3. Web/API Layer
4. Database Layer
5. Configuration
6. Testing
7. Assets/Frontend
8. Infrastructure
9. Key Files Reference (entry points table)
10. Naming Conventions (with actual examples)
11. Quick Reference Guide (common development tasks)

Document header includes: framework, language, last-updated date, architectural pattern.

## Best Practices

**Annotation conventions**:
- Use `<!-- user: ... -->` markers for preservation
- Keep annotations concise (3-5 words)
- Review placeholder annotations after automated updates

**Update frequency**:
- After major refactoring or new top-level directories
- Quarterly reviews or with major releases
- Framework version upgrades

**Version control**:
- Commit PROJECT-LAYOUT.md separately from code changes
- Provides clear documentation history

## Limitations & Constraints

- Requires `tree` command for directory visualization (falls back to bash if unavailable)
- Limited to 3-level depth to prevent overwhelming detail
- Manual review required for new placeholder annotations
- Cannot auto-generate meaningful descriptions for new items
- Framework detection may require manual override for custom architectures

## Success Indicators

- Tree diagram accurately shows 2-3 levels with annotations
- All 11 required sections present and populated
- No placeholder content remains after manual review
- All path references resolve to existing filesystem locations
- Naming conventions match actual project patterns
- Change summary shows expected additions/removals

---
**Generated from**: worktrees/main/docs/commands/update-layout.md + update-layout.detailed.md
