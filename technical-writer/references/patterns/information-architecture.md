# Information Architecture

Organizing documentation for findability, progressive disclosure, and maintainability.

## Core Principle

Information architecture answers: "Where does the reader look for X?" If they can't find it within 30 seconds, the architecture has failed.

## Documentation Hierarchy

### For a Single-Product Project

```
README.md                          ← Entry point: what, why, quick start
├── docs/
│   ├── getting-started.md         ← First-time setup (the full version)
│   ├── usage.md                   ← Primary use cases
│   ├── configuration.md           ← Config reference
│   ├── api/                       ← API reference (if applicable)
│   │   ├── authentication.md
│   │   ├── endpoints.md
│   │   └── errors.md
│   ├── guides/                    ← Task-based guides
│   │   ├── deploying.md
│   │   └── migrating-v1-to-v2.md
│   ├── architecture.md            ← System design (for contributors)
│   └── troubleshooting.md         ← Symptom-based problem solving
├── CONTRIBUTING.md                ← How to contribute
├── CHANGELOG.md                   ← Version history
└── CLAUDE.md                      ← Agent instructions
```

### For a Multi-Service System

```
README.md                          ← System overview + navigation
├── docs/
│   ├── architecture.md            ← System-wide design
│   ├── getting-started.md         ← Full system setup
│   ├── services/
│   │   ├── api/                   ← Per-service docs
│   │   ├── worker/
│   │   └── gateway/
│   ├── operations/
│   │   ├── deployment.md
│   │   ├── monitoring.md
│   │   └── runbooks/
│   └── development/
│       ├── local-setup.md
│       ├── testing.md
│       └── contributing.md
```

## Navigation Patterns

### Hub-and-Spoke

A single landing page (hub) links to all topic areas (spokes). Best for small-to-medium doc sets (5-20 pages).

```markdown
## Documentation

| Topic | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | Install and run your first query |
| [Configuration](docs/configuration.md) | All config options |
| [API Reference](docs/api/) | Endpoint documentation |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
```

### Breadcrumb Trail

Each page links to its parent and siblings. Best for deep hierarchies.

```markdown
← [Documentation](../README.md) / [API](./README.md) / Authentication
```

### See-Also Footer

Each page links to related pages. Best for cross-cutting topics.

```markdown
## See Also

- [Authentication](./authentication.md) — How to get API credentials
- [Rate Limits](./rate-limits.md) — Request quotas and throttling
- [Errors](./errors.md) — Error codes and troubleshooting
```

## Organizing Principles

### By Reader Task (Preferred)

Organize around what the reader is trying to do:

```
How do I install this?        → Getting Started
How do I use feature X?       → Usage Guide / Feature Docs
How do I configure X?         → Configuration Reference
How do I fix problem X?       → Troubleshooting
How do I deploy this?         → Deployment Guide
How does this work inside?    → Architecture
How do I contribute?          → Contributing Guide
```

### By Information Type (Diátaxis)

The Diátaxis framework organizes by how the reader learns:

| Type | Reader mode | Structure | Example |
|------|------------|-----------|---------|
| **Tutorial** | Learning | Step-by-step lesson | "Build your first app" |
| **How-to** | Working | Task-based guide | "How to add authentication" |
| **Reference** | Checking | Exhaustive lookup | "Configuration options" |
| **Explanation** | Understanding | Conceptual discussion | "How the cache works" |

Most projects need at least tutorial + reference. Add how-to guides and explanations as the project matures.

## Progressive Disclosure

Layer information so readers can stop at any depth:

| Level | Content | Reader need |
|-------|---------|-------------|
| 1 | README (what + quick start) | "Is this relevant to me?" |
| 2 | Getting started (full setup) | "How do I get this running?" |
| 3 | Usage guides (primary features) | "How do I use this?" |
| 4 | Reference (all options) | "What are all the settings?" |
| 5 | Architecture (internals) | "How does this work inside?" |

**Rule:** Each level should work standalone. Don't require reading level 5 to understand level 2.

## Cross-Linking Rules

1. **Link forward, not backward** — guide pages link to reference; reference doesn't link back to the guide that mentioned it
2. **Link on first mention** — the first time a concept appears, link to its dedicated page
3. **Don't over-link** — if every other word is a link, nothing stands out. Link the concept, not the article.
4. **Use descriptive link text** — "see the [configuration reference](./config.md)" not "see [here](./config.md)"
5. **Relative paths** — use `./file.md` not absolute URLs (keeps docs portable)

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files | kebab-case | `getting-started.md` |
| Directories | kebab-case | `api-reference/` |
| Index files | `README.md` or `index.md` | `docs/api/README.md` |
| Guides | verb phrase | `deploying-to-production.md` |
| Reference | noun phrase | `configuration.md` |
| Troubleshooting | `troubleshooting-{topic}.md` | `troubleshooting-auth.md` |

## Doc Set Sizing

| Project size | Expected docs | Maintenance burden |
|-------------|--------------|-------------------|
| Small CLI tool | README + 1-2 pages | Low (update on release) |
| Library/SDK | README + API ref + 3-5 guides | Medium (update with API changes) |
| Web application | README + 10-20 pages | High (update with features + ops changes) |
| Platform/system | README + 30+ pages + runbooks | Very high (dedicated tech writer role) |

Scale docs with the project. Don't write 30 pages for a CLI tool, and don't try to fit a platform into a single README.
