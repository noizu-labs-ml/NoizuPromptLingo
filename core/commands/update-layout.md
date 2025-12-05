# Update Layout Documentation

Refresh `docs/PROJECT-LAYOUT.md` to reflect current directory structure while preserving user annotations.

## Workflow

### Phase 1: Load Existing Documentation
1. Read `docs/PROJECT-LAYOUT.md` (if exists)
2. Extract user annotations (descriptions, comments, notes)
3. Identify custom sections not in standard template

### Phase 2: Scan Current Structure
Generate fresh directory tree and file inventory:

```bash
# Get directory structure
tree -L 3 -d --noreport

# Get key files
find . -maxdepth 3 -type f \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.toml" -o -name "Makefile" -o -name "Dockerfile" \) | head -50
```

Cross-reference with existing documentation to identify:
- New directories/files to document
- Removed items to clean up
- Reorganized structure to update

### Phase 3: Update Documentation

**Directory Structure Overview:**
- Regenerate tree diagram
- Preserve existing annotations where structure unchanged
- Add annotations for new directories

**Layer Breakdowns:**
- Update each layer section with current files
- Preserve file purpose descriptions
- Add new files, remove deleted ones

**Key Files:**
- Refresh entry points table
- Update configuration file list
- Preserve "Edit When" guidance if still accurate

**Naming Conventions:**
- Verify patterns still match reality
- Update examples with current file names

**Quick Reference:**
- Update "Finding Files" paths
- Add new common search patterns

### Phase 4: Validate
1. Verify all referenced paths exist
2. Check tree diagrams match actual structure
3. Confirm naming conventions are accurate
4. Ensure no orphaned references

## Merge Strategy

**Preserve:**
- User-added file descriptions
- Custom annotations on directories
- Additional sections not in template
- Notes marked with `<!-- user: ... -->`

**Update:**
- Tree diagrams (regenerate)
- File listings (add new, remove deleted)
- Path references
- Examples with current file names

**Remove:**
- References to deleted files/directories
- Outdated path examples

## Output
- Updated `docs/PROJECT-LAYOUT.md`
- Summary of structural changes detected
