# Technical Documentation Guidelines

**Last Updated:** 2026-03-04
**Purpose:** Generic standards for API reference documentation across all projects

---

## Directory Structure

```
docs/api-reference/
├── GUIDELINES.md          <-- This file
├── assets/                <!-- Inline assets: images, diagrams, screenshots -->
├── [topic-01].md          <!-- Topic documentation -->
└── [topic-02].md
```

---

## Document Header

Each documentation file must include:

```markdown
# [Topic Name]

**Last Updated:** YYYY-MM-DD
**Min Swift Version:** X.X (or omit if not Swift-specific)
**Min macOS Version:** X.X (or omit if not macOS-specific)
**Min Python Version:** X.X (or omit if not Python-specific)
[Add other version tags as needed]
```

---

## Required Sections

Every document must contain at least these sections in order:

1. **Quick Summary** - What you need to know in 30 seconds
2. **Key APIs** - Table of main functions/types with locations
3. **Code Examples** - Copy-paste ready, version-tagged
4. **Implementation Notes** - Gotchas, pitfalls, threading
5. **References** - Links to official docs and tutorials
6. **Version Notes** - Minimum version requirements and changes

---

## Section Standards

### Quick Summary

Concise paragraph (2-3 sentences) explaining:
- What the API/component does
- Why it matters
- Common use case

### Key APIs

Table format:

```markdown
| API | Purpose | File/Module Location |
|-----|---------|----------------------|
| SomeClass | Does X | `module/file.swift` |
| someFunction | Handles Y | `internal/util.swift` |
```

### Code Examples

Each example must specify versions:

```markdown
### Basic usage

**Swift 5.9+, macOS 14.0+**

```swift
// Code here
```

### Advanced pattern

**Swift 5.9+, macOS 15.0+**

```swift
// More advanced code
```
```

**Code formatting rules:**
- Use 4-space indentation
- Add comments explaining key steps
- Mark version-specific code with comments
- Show imports when needed

### Cross-Referencing

Link to other docs:

```markdown
See also: `[API Name](./[other-file].md)` for related functionality
```

### Inline Assets

Reference assets in `assets/` subdirectory:

```markdown
![Architecture diagram](./assets/architecture-diagram.png)
```

**Asset naming:**
- Use kebab-case
- Include topic prefix when applicable: `topic-component-name.png`
- Keep under 1MB when possible

### Implementation Notes

Subsections:

```markdown
### Gotchas
- [Common pitfalls to avoid]

### Performance Considerations
- [Performance tips]

### Threading
- [Threading requirements]

### Security
- [Security considerations if applicable]
```

### References

Format with titles:

```markdown
- [Official Documentation Title](URL) - Brief description
- [Blog Article Title](URL) - Brief description
```

**Prioritize:**
1. Official documentation (Apple, Microsoft, etc.)
2. Well-known blogs/publications
3. Stack Overflow (high-vote answers only)

### Version Notes

Track minimum requirements:

```markdown
- **Version X.X**: This feature was added
- **Version Y.Y**: Changes from previous version
- **Version Z.Z**: This API was deprecated; use [alternative] instead
```

---

## Guidelines Lookup Logic (For Agents)

When `use-guides=true` parameter is passed:

1. Start from the **target file's directory**
2. Search upward for `GUIDELINES.md`:
   - Check target file's directory
   - Check parent directory
   - Continue up to 4 levels
   - Stop if `.git` directory is found
3. If not found and `.git` exists, check `../GUIDELINES.md` (relative to git root)
4. If a path is explicitly specified (`guidelines-path=/path/to/GUIDELINES.md`), use it instead

**Example:**
```
Target: docs/japanese-esthetics/han-period/fiction/poetry/some-poem.md
Search order:
  1. docs/japanese-esthetics/han-period/fiction/poetry/GUIDELINES.md
  2. docs/japanese-esthetics/han-period/fiction/GUIDELINES.md
  3. docs/japanese-esthetics/han-period/GUIDELINES.md
  4. docs/japanese-esthetics/GUIDELINES.md
  [stop at .git or after 4 levels]
  5. ../GUIDELINES.md (relative to .git if found)
```

---

## Output Validation

Agents should verify:
- [ ] Header contains Last Updated and relevant version tags
- [ ] All required sections present
- [ ] Code examples have version tags
- [ ] Cross-references are valid paths
- [ ] Assets referenced actually exist
- [ ] References include both title and URL
- [ ] Version notes are up-to-date

---

## Extension Principles

These guidelines are **project-agnostic** and can be extended for:
- Programming language-specific sections
- Framework-specific additions
- Domain-specific patterns

**Do not** hardcode:
- Project-specific file names
- Framework-specific names (unless section is optional)
- Specific technology choices

---

## Examples

See existing documentation in this directory for examples:
- `01-nsevent-global-monitoring.md`
- `02-nswindow-floating-windows.md`
- `03-nsapplication-activation-policy.md`
- `04-swiftui-view-lifecycle.md`

<!-- nav -->

---

[Table of Contents](../../product-spec.md) | [Next: NSEvent & Global Key Monitoring >](01-nsevent-global-monitoring.md)

<!-- nav -->
