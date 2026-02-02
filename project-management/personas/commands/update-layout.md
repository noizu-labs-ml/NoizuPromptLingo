# update-layout - Persona

**Type**: Command
**Category**: Documentation Automation
**Version**: 1.0.0

## Overview

The `update-layout` command synchronizes project layout documentation with the actual codebase structure. It automatically detects structural changes (new directories, removed files, reorganizations) and updates `docs/PROJECT-LAYOUT.md` accordingly while preserving manually-added descriptions, annotations, and custom sections. This ensures layout documentation remains accurate without losing valuable human-authored context.

## Purpose & Use Cases

- **Post-refactoring sync** - Update documentation after major code reorganization or directory structure changes
- **Quarterly review** - Periodic refresh to catch accumulated drift between filesystem and documentation
- **Initial documentation** - Generate comprehensive PROJECT-LAYOUT.md for new projects
- **CI/CD validation** - Verify documentation accuracy in automated pipelines
- **Framework migration** - Adapt layout documentation when upgrading frameworks or changing architectural patterns

## Key Features

✅ **Smart merge strategy** - Preserves user annotations while updating structural elements
✅ **Framework detection** - Adapts section names and conventions based on detected framework (Rails, Django, Phoenix, Next.js, Express)
✅ **Four-phase workflow** - Load → Scan → Update → Validate for comprehensive accuracy
✅ **Annotation preservation** - Maintains `<!-- user: -->` markers and custom sections through updates
✅ **Change detection** - Identifies new/removed/reorganized directories and files automatically
✅ **Spec compliance** - Generates documents following `project-layout-spec.md` with all 11 required sections

## Usage

```bash
# Agent invocation
@npl update-layout

# Validation only (dry-run)
@npl update-layout --validate
```

The command reads the current filesystem structure, compares it against existing documentation, merges changes while preserving annotations, and outputs an updated `docs/PROJECT-LAYOUT.md` with a change summary showing new/removed entries.

## Integration Points

- **Triggered by**: Project refactoring, directory reorganization, framework upgrades, or manual invocation
- **Feeds to**: Developer onboarding docs, architecture reviews, project navigation guides
- **Complements**: `update-arch` (architecture documentation refresh), `init-project` (initial project setup)

## Parameters / Configuration

- **Source documentation**: `docs/PROJECT-LAYOUT.md` (if exists)
- **Output path**: `docs/PROJECT-LAYOUT.md` (overwrites with updated version)
- **Specification**: `core/specifications/project-layout-spec.md` (defines required structure)
- **Prerequisites**: NPL syntax and project-layout-spec must be loaded via `npl-load`
- **Validation mode**: `--validate` flag for dry-run accuracy checking

## Success Criteria

- All 11 required sections present in output document
- Tree diagrams accurately reflect current filesystem structure (2-3 levels with annotations)
- User-added descriptions and annotations preserved for unchanged files/directories
- New items added with placeholder annotations for manual completion
- Removed entries cleaned up (no references to deleted files/directories)
- Framework-specific adaptations applied correctly
- All referenced paths verified to exist in filesystem

## Limitations & Constraints

- Requires manual annotation of placeholder entries for new directories/files
- Tree depth limited to 3 levels to maintain readability
- File listing capped at 50 items for key configuration/documentation files
- Framework detection may require manual correction for hybrid architectures
- Cannot infer purpose descriptions for new files (uses placeholders requiring human input)
- Annotation preservation depends on consistent use of `<!-- user: -->` markers

## Related Utilities

- **update-arch** - Refreshes `docs/PROJECT-ARCH.md` architecture documentation
- **init-project** - Initializes new project with layout and architecture documentation
- **init-project-fast** - Quick project initialization workflow
- **project-layout-spec** - Specification defining required structure and conventions
