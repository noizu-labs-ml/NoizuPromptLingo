# PROJ-ARCH.md — Maintenance Guide

## Purpose

`docs/PROJ-ARCH.md` provides a **high-level architectural overview** of the project. It should remain concise and scannable, serving as an entry point for understanding system design.

## Structure

```
docs/
├── PROJ-ARCH.md          # Main architecture overview (keep small)
└── arch/
    ├── data-flow.md      # Detailed section documents
    ├── api-design.md
    ├── infrastructure.md
    └── ...
```

## Content Guidelines

### What to Include in PROJ-ARCH.md

- System overview (2-3 paragraphs max)
- Core components list with one-line descriptions
- High-level diagrams (mermaid preferred)
- Key design decisions and rationale (brief)
- Technology stack summary
- References to detailed `arch/*.md` files

### Section Template

```markdown
## [Section Name]

[2-4 sentence summary of this architectural concern]

→ *See [arch/section-name.md](arch/section-name.md) for details*
```

## Size Limits

| Location | Target Size | Action When Exceeded |
|----------|-------------|----------------------|
| PROJ-ARCH.md | < 300 lines | Extract sections to `arch/` |
| Individual sections | < 15 lines | Move to `arch/{section}.md` |
| arch/*.md files | < 200 lines | Consider further decomposition |

## When to Extract

Move content to `arch/{section}.md` when:

1. A section exceeds ~15 lines
2. The section contains implementation details beyond "what" into "how"
3. The section includes extensive code examples
4. Multiple subsections emerge within a section

## Extraction Process

1. Create `docs/arch/{section-name}.md` with full content
2. Replace section in PROJ-ARCH.md with:
   - 2-4 sentence summary
   - Link to detailed document
3. Ensure the summary captures the *essence* without requiring the reader to click through for basic understanding

## Example PROJ-ARCH.md

```markdown
# Project Architecture

## Overview

Brief description of what the system does and its primary architectural style
(e.g., microservices, monolith, event-driven).

## System Diagram

\`\`\`mermaid
graph TB
    A[Client] --> B[API Gateway]
    B --> C[Service A]
    B --> D[Service B]
    C --> E[(Database)]
\`\`\`

## Core Components

| Component | Purpose |
|-----------|---------|
| API Gateway | Request routing, auth |
| Service A | Handles X domain |
| Service B | Handles Y domain |

## Data Flow

Requests enter through the gateway, authenticate via JWT, and route to
appropriate services. Events propagate via message queue.

→ *See [arch/data-flow.md](arch/data-flow.md) for details*

## Infrastructure

Deployed on Kubernetes with Postgres and Redis backing stores.

→ *See [arch/infrastructure.md](arch/infrastructure.md) for details*

## Key Decisions

- **Why microservices**: Scaling requirements for component X
- **Why Postgres**: ACID compliance needed for financial data

→ *See [arch/decisions.md](arch/decisions.md) for ADRs*
```

## Maintenance Checklist

- [ ] PROJ-ARCH.md remains under 300 lines
- [ ] Each section has a clear summary even without clicking through
- [ ] All `arch/*.md` links are valid
- [ ] Diagrams reflect current architecture
- [ ] No implementation details in main file
- [ ] Updated when significant architectural changes occur
