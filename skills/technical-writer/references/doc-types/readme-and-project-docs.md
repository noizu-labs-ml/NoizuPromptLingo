# README and Project Documentation

Patterns for READMEs, CLAUDE.md, CONTRIBUTING.md, architecture docs, and project overview documents.

## README Structure

The README is the front door. Most readers spend less than 30 seconds deciding if a project is relevant to them.

### Minimal README (small project / internal tool)

```markdown
# Project Name

One-line description of what this does.

## Quick Start

\```bash
npm install
npm run dev
\```

## Usage

\```bash
myctl do-thing --flag value
\```

## Configuration

Copy `.env.example` to `.env` and set `DATABASE_URL`.

## License

MIT
```

### Full README (open source / public project)

```markdown
# Project Name

One-line description. [Optional badge row]

## What It Does

2-3 sentences. What problem does it solve? Who is it for?

## Quick Start

Fastest path from zero to working. 3-5 steps maximum.

## Installation

Full installation with prerequisites and platform variations.

## Usage

Common operations with examples. Start with the 80% use case.

## Configuration

Configuration reference or link to config docs.

## Architecture

Brief overview for contributors. Link to detailed arch doc if it exists.

## Contributing

How to contribute, or link to CONTRIBUTING.md.

## License

License name + link.
```

### Section Priority

Write sections in this order (stop when scope is met):

1. Title + one-liner (always)
2. Quick Start (always)
3. Installation (if non-trivial)
4. Usage (always)
5. Configuration (if configurable)
6. Architecture (if accepting contributions)
7. Contributing (if open source)
8. License (if open source)

## CLAUDE.md Pattern

CLAUDE.md tells an AI agent how to work in a codebase. Structure for machine consumption — scannable, unambiguous, command-focused.

### Sections

```markdown
# CLAUDE.md

## What This Is
One paragraph: what the project does, its tech stack, primary language.

## Commands
Table or list of every build/test/lint/deploy command. Group by purpose.

| Command | Purpose |
|---------|---------|
| `npm test` | Run test suite |
| `npm run lint` | Lint + format check |
| `npm run build` | Production build |

## Architecture
Key directories and what they contain. Don't describe every file —
describe the organizing principles.

## Conventions
Naming patterns, code style rules, patterns the agent should follow.
Only include non-obvious conventions (don't say "use camelCase" if
the linter enforces it).

## Gotchas
Things that will trip up an agent: env vars that must be set,
services that must be running, commands that have side effects.
```

### CLAUDE.md Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Prose paragraphs describing architecture | Use directory tree + one-line descriptions |
| Documenting what the linter enforces | Only document what's NOT automatically checked |
| "Run `npm install` first" without saying when | Be explicit: "After pulling, run `npm install`" |
| Listing every file | Describe patterns and organizing principles |

## CONTRIBUTING.md Pattern

```markdown
# Contributing

## Development Setup
{Prerequisites + setup steps}

## Making Changes
1. Create a branch from `main`
2. Make your changes
3. Run tests: `npm test`
4. Open a PR with a description of what and why

## Code Style
{Brief style notes or link to linter config}

## Commit Messages
{Convention: conventional commits, imperative mood, etc.}

## Review Process
{What to expect: timeline, who reviews, merge policy}
```

## Architecture Document Pattern

For when the README's architecture section isn't enough.

```markdown
# Architecture: {Project Name}

## Overview
{System purpose in 2-3 sentences}

## High-Level Design
{Diagram or description of major components and their relationships}

## Key Components
### {Component A}
- **Purpose:** {what it does}
- **Location:** `src/components/a/`
- **Key interfaces:** {what it exposes}

### {Component B}
...

## Data Flow
{How data moves through the system for the primary use case}

## Design Decisions
### {Decision 1: Why X instead of Y}
- **Context:** {what problem we faced}
- **Decision:** {what we chose}
- **Rationale:** {why}
- **Consequences:** {tradeoffs accepted}

## Deployment
{How the system runs in production}
```

## Quality Checklist

- [ ] README answers "what is this?" in the first 3 lines
- [ ] Quick Start gets to "it works" in under 5 steps
- [ ] All commands in README actually work when copy-pasted
- [ ] No broken links
- [ ] License is stated (for public projects)
- [ ] CLAUDE.md commands are verified against actual scripts
- [ ] Architecture doc matches current code (not aspirational)
