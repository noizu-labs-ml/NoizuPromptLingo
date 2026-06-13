# PROJECT-LAYOUT Specification Brief

**Location**: `worktrees/main/core/specifications/project-layout-spec.md`

## Overview
Convention specification for documenting project directory structures to enable effective LLM navigation. Reduces context-building overhead and enables precise file location discovery.

## Key Principle
Well-structured layout documents help language models understand and navigate codebases efficiently, reducing navigation time and improving accuracy.

## 11 Required Sections

1. **Directory Structure Overview** - Tree diagram (2-3 levels) with inline annotations
2. **Core Application Layer** - Primary source code organization, architecture pattern, module breakdown
3. **Web/API Layer** - HTTP interface structure, controllers, routes, views, API versioning
4. **Database Layer** - Migrations, schemas/models, seeds, queries organization
5. **Configuration** - Configuration file inventory, environment handling, secrets management
6. **Testing** - Test directory structure, conventions, helpers, running tests
7. **Assets/Frontend** - Frontend asset organization, build pipeline, static files
8. **Infrastructure** - Container configuration, CI/CD, deployment scripts, IaC
9. **Key Files Reference** - Quick-reference table of critical entry points and config files
10. **Naming Conventions** - File/directory naming patterns, case conventions by context
11. **Quick Reference Guide** - Finding files by task, common modifications, search patterns

## Section Specifications

### Annotation Style Guide
- Concise: 3-5 words maximum
- Functional: Describe what the directory contains
- Consistent: Use parallel grammatical structure

### Tree Diagram Convention
```
project-name/
|-- src/                    # Core application source
|   |-- domain/             # Business logic and entities
|   `-- services/           # Application services
|-- tests/                  # Test suites
`-- docs/                   # Documentation
```

### Definition List Format
```
**<component>**
: Description of purpose
: Key files: `file1`, `file2`
```

## Document Metadata

### Required Header
```
# Project Layout: <project-name>

**framework**: <primary-framework>
**language**: <primary-language>
**last-updated**: <YYYY-MM-DD>
**architecture**: <architectural-pattern>
```

### Update Triggers
- Major structural changes
- New top-level directories added
- Framework version upgrades
- Architecture pattern changes

### Review Frequency
Quarterly or with major releases

## Framework-Specific Adaptations

| Framework | Core Location | Notes |
|:----------|:--------------|:------|
| Rails | `app/` | Controllers in `app/controllers/`, views in `app/views/` |
| Django | `<project>/` | Each app is a subdirectory |
| Phoenix | `lib/<app>/` | Web layer in `lib/<app>_web/` |
| Next.js | `src/` or root | Web layer in `pages/` or `app/` |
| Express | `src/` | Web layer in `src/routes/`, `src/controllers/` |

## Validation Checklist
- [ ] Tree diagram shows 2-3 levels with annotations
- [ ] All 11 required sections present
- [ ] Definition lists use correct NPL syntax
- [ ] Tables have consistent column alignment
- [ ] File paths are accurate and up-to-date
- [ ] Naming conventions match actual project patterns
- [ ] Quick reference covers common development tasks
- [ ] Examples are concrete and project-specific
- [ ] No placeholder content remains
- [ ] Document header includes framework and last-updated date

## Key Insight
PROJECT-LAYOUT.md is the navigation map for developers and LLMs. Clear organization reduces context-building time and enables faster file discovery. Consistency across projects improves tool-assisted navigation.

## Dependencies
- Requires NPL syntax: `syntax,fences,directive,formatting.template`
