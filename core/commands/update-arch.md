# Update Architecture Documentation

Refresh `docs/PROJECT-ARCH.md` to reflect current codebase state while preserving user-added content.

## Workflow

### Phase 1: Load Existing Documentation
1. Read `docs/PROJECT-ARCH.md` (if exists)
2. Read all sub-files in `docs/PROJECT-ARCH/` (if exists)
3. Identify user-added sections (not in standard template)

### Phase 2: Detect Changes
Use `@npl-gopher-scout` to identify what's changed:

```
@npl-gopher-scout Compare current codebase against existing architecture documentation:

Review:
1. **New Components** - Files/modules not documented
2. **Removed Components** - Documented items no longer present
3. **Changed Patterns** - Modified architectural patterns
4. **Infrastructure Changes** - New/removed services
5. **Dependency Updates** - Version changes, new dependencies

Focus on:
- Architectural significance (not minor changes)
- New bounded contexts or entities
- Changed layer responsibilities
- New infrastructure services
- Critical issues introduced

Output: Structured diff of architectural changes.
```

### Phase 3: Update Documentation
Apply changes while preserving structure:

**Main File (`docs/PROJECT-ARCH.md`):**
- Update `⟪📐 arch-overview:⟫` if stack changed
- Update `⟪🗺️ layers:⟫` if layer structure changed
- Update `⟪🔧 services:⟫` if infrastructure changed
- Add new critical issues with `🎯`
- Preserve user-added sections

**Sub-files:**
- Update existing sub-files with new content
- Create new sub-files if sections now exceed threshold
- Consolidate sub-files if content shrunk below threshold
- Preserve user comments and annotations

### Phase 4: Validate
1. Ensure all `→ See:` references resolve
2. Verify main file stays within ~200-400 lines
3. Check that critical issues are current
4. Confirm no orphaned sub-files

## Merge Strategy

**Preserve:**
- User-added sections not in template
- Custom annotations and comments
- Additional diagrams or examples
- Notes marked with `<!-- user: ... -->`

**Update:**
- Technology versions
- Layer mappings
- Service configurations
- Entity/pattern lists
- Critical issues

**Remove:**
- References to deleted components
- Outdated critical issues (if resolved)

## Output
- Updated `docs/PROJECT-ARCH.md`
- Updated/new sub-files in `docs/PROJECT-ARCH/`
- Summary of changes made
