# Initialize Project Documentation

Generate `docs/PROJECT-ARCH.md` and `docs/PROJECT-LAYOUT.md` for the current project.

## Prerequisites

Load NPL dependencies and specifications before proceeding:

```bash
# Load NPL syntax elements for documentation generation
npl-load c "syntax,fences,directive,formatting.template" --skip {@npl.def.loaded}

# Load specification documents
npl-load spec "project-arch-spec,project-layout-spec" --skip {@npl.spec.loaded}
```

---

## Workflow

### Phase 1: Reconnaissance

Use `@npl-gopher-scout` to explore the codebase:

```
@npl-gopher-scout Perform comprehensive reconnaissance of this project:

1. **Structure Analysis**
   - Directory tree (3 levels deep)
   - Key entry points and configuration files
   - Source code organization patterns

2. **Architecture Discovery**
   - Identify architectural layers
   - Map domain models/entities
   - Detect frameworks and key dependencies
   - Find infrastructure services (DB, cache, queues)

3. **Pattern Recognition**
   - Code organization patterns
   - Naming conventions
   - Testing structure

Report findings in structured format for documentation generation.
```

### Phase 2: Generate Architecture Documentation

Based on reconnaissance findings, generate `docs/PROJECT-ARCH.md` following the loaded `project-arch-spec`.

**Key Requirements:**
- Main file ~200-400 lines max
- Use NPL directives: `⟪📐 arch-overview:⟫`, `⟪🗺️ layers:⟫`, `⟪🔧 services:⟫`
- Create sub-files in `docs/PROJECT-ARCH/` for sections exceeding ~50-100 lines
- Include ASCII layer diagram
- Mark critical issues with `🎯`

**Sub-files to consider:**
- `layers.md` - If architectural layers need detailed breakdown
- `domain.md` - If domain model has multiple bounded contexts
- `patterns.md` - If custom patterns need code examples
- `infrastructure.md` - If multiple infrastructure services
- `database.md` - If complex database schema/extensions
- `api.md` - If public API documentation needed

### Phase 3: Generate Layout Documentation

Generate `docs/PROJECT-LAYOUT.md` following the loaded `project-layout-spec`.

**Key Requirements:**
- Single file ~300-500 lines
- Clean tree diagrams with annotations
- Include all 11 required sections
- Document naming conventions
- Provide "Finding Files" quick reference

### Phase 4: Verify

1. Ensure both files are complete and consistent
2. Verify sub-file references resolve correctly
3. Check that critical architectural decisions are captured

---

## Output

- `docs/PROJECT-ARCH.md`
- `docs/PROJECT-ARCH/*.md` (sub-files as needed)
- `docs/PROJECT-LAYOUT.md`
