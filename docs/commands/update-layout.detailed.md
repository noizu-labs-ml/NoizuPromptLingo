# update-layout Command Reference

Command for refreshing `docs/PROJECT-LAYOUT.md` to match current directory structure while preserving user annotations.

---

## Purpose

The `update-layout` command synchronizes project layout documentation with the actual codebase structure. It detects structural changes (new directories, removed files, reorganizations) and updates documentation accordingly while preserving manually-added descriptions and annotations.

**Primary use case**: Keeping `docs/PROJECT-LAYOUT.md` accurate after codebase changes without losing custom documentation.

---

## Prerequisites

Load NPL dependencies before execution:

```bash
# Load syntax elements
npl-load c "syntax,fences" --skip {@npl.def.loaded}

# Load layout specification
npl-load spec "project-layout-spec" --skip {@npl.spec.loaded}
```

The `project-layout-spec` defines the expected structure and formatting conventions for PROJECT-LAYOUT.md files.

---

## Workflow

### Phase 1: Load Existing Documentation

1. Read `docs/PROJECT-LAYOUT.md` if it exists
2. Parse and extract:
   - User annotations (descriptions, comments, notes)
   - Custom sections not in standard template
   - Markers like `<!-- user: ... -->`
3. Store extracted content for merge

### Phase 2: Scan Current Structure

Generate fresh directory tree and file inventory:

```bash
# Get directory structure (3 levels deep)
tree -L 3 -d --noreport

# Get key configuration and documentation files
find . -maxdepth 3 -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" -o -name "Makefile" -o -name "Dockerfile" \) | head -50
```

Cross-reference with existing documentation to identify:

| Change Type | Detection Method |
|:------------|:-----------------|
| New directories | Present in tree, absent in doc |
| Removed directories | Present in doc, absent in tree |
| New files | Present in filesystem, absent in doc |
| Removed files | Present in doc, absent in filesystem |
| Reorganized structure | Path changes between doc and filesystem |

### Phase 3: Update Documentation

**Directory Structure Overview**
- Regenerate tree diagram from current filesystem
- Preserve existing inline annotations where structure unchanged
- Add placeholder annotations for new directories
- Remove entries for deleted directories

**Layer Breakdowns**
- Update each layer section with current files
- Preserve file purpose descriptions for unchanged files
- Add new files with placeholder descriptions
- Remove entries for deleted files

**Key Files Reference**
- Refresh entry points table
- Update configuration file list
- Preserve "Edit When" guidance if file still exists and unchanged

**Naming Conventions**
- Verify documented patterns match actual file naming
- Update examples with current file names
- Flag discrepancies for manual review

**Quick Reference**
- Update "Finding Files" paths to reflect current structure
- Add new common search patterns discovered during scan

### Phase 4: Validate

1. **Path verification**: Confirm all referenced paths exist in filesystem
2. **Tree accuracy**: Verify tree diagrams match actual structure
3. **Convention accuracy**: Check naming conventions reflect reality
4. **Orphan detection**: Identify references to non-existent files/directories

---

## Merge Strategy

### Preserve

Content that survives updates:

- User-added file descriptions
- Custom annotations on directories
- Additional sections not in template
- Notes marked with `<!-- user: ... -->`
- Framework-specific adaptations

### Update

Content regenerated from filesystem:

- Tree diagrams (full regeneration)
- File listings (add new, remove deleted)
- Path references
- Examples using current file names
- Statistics (directory count, file count)

### Remove

Content cleaned up:

- References to deleted files/directories
- Outdated path examples
- Broken internal links
- Orphaned annotations for removed items

---

## Output

The command produces:

1. **Updated `docs/PROJECT-LAYOUT.md`**
   - Synchronized with current structure
   - User annotations preserved
   - New items annotated with placeholders

2. **Change summary**
   - Count of new directories/files added
   - Count of removed entries
   - List of items needing manual annotation

---

## Integration with PROJECT-LAYOUT Specification

The `update-layout` command follows the structure defined in `core/specifications/project-layout-spec.md`:

### Required Sections (11 total)

1. Directory Structure Overview
2. Core Application Layer
3. Web/API Layer
4. Database Layer
5. Configuration
6. Testing
7. Assets/Frontend
8. Infrastructure
9. Key Files Reference
10. Naming Conventions
11. Quick Reference Guide

### Document Header

Generated documents include metadata:

```markdown
# Project Layout: <project-name>

**framework**
: <detected-framework>

**language**
: <primary-language>

**last-updated**
: <YYYY-MM-DD>

**architecture**
: <architectural-pattern>
```

### Framework Adaptation

The command adapts section names based on detected framework:

| Framework | Core Location | Web Layer |
|:----------|:--------------|:----------|
| Rails | `app/` | `app/controllers/`, `app/views/` |
| Django | `<project>/` | App subdirectories |
| Phoenix | `lib/<app>/` | `lib/<app>_web/` |
| Next.js | `src/` or root | `pages/` or `app/` |
| Express | `src/` | `src/routes/`, `src/controllers/` |

---

## Usage Examples

### Initial Generation

For a new project without existing PROJECT-LAYOUT.md:

```bash
# Agent invocation
@npl update-layout
```

Creates `docs/PROJECT-LAYOUT.md` with:
- Full tree diagram
- All 11 sections with detected content
- Placeholder annotations for manual completion

### Incremental Update

After adding new directories:

```bash
# Agent invocation after structural changes
@npl update-layout
```

Outputs:
- Updated tree with new directories
- Preserved existing annotations
- New entries flagged for annotation

### Validation Only

Check documentation accuracy without modifications:

```bash
# Dry-run validation
@npl update-layout --validate
```

Reports:
- Missing directories
- Extra documentation entries
- Naming convention mismatches

---

## Best Practices

### Annotation Conventions

Use consistent markers for custom content:

```markdown
<!-- user: Custom annotation that should be preserved -->
```

Keep annotations concise (3-5 words):

```markdown
# Good
|-- src/                    # Core application source

# Avoid
|-- src/                    # This directory contains all the main source code files
```

### Update Frequency

Run `update-layout` after:
- Adding new top-level directories
- Major refactoring
- Framework version upgrades
- Architecture pattern changes

Recommended: Quarterly review or with major releases.

### Manual Review

After automated update, review:
- New placeholder annotations (replace with meaningful descriptions)
- Removed entries (ensure intentional)
- Quick Reference section (add project-specific patterns)

### Version Control

Commit PROJECT-LAYOUT.md changes separately from code changes for clear history.

---

## Validation Checklist

After running `update-layout`:

- [ ] Tree diagram shows 2-3 levels with annotations
- [ ] All 11 required sections present
- [ ] Definition lists use correct NPL syntax
- [ ] Tables have consistent column alignment
- [ ] File paths are accurate and up-to-date
- [ ] Naming conventions match actual project patterns
- [ ] Quick reference covers common development tasks
- [ ] No placeholder content remains
- [ ] Document header includes framework and last-updated date

---

## Related Commands

- `update-arch` - Refresh PROJECT-ARCH.md architecture documentation
- `init-project` - Initialize new project with layout documentation
- `init-project-fast` - Quick project initialization

## Related Specifications

- `core/specifications/project-layout-spec.md` - Full specification for PROJECT-LAYOUT.md structure
- `docs/PROJECT-LAYOUT.md` - Example output in NPL repository
