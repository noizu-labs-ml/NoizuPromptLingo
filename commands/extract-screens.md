---
name: extract-screens
description: Analyze user stories in the current project and extract screens + reusable UI components into project-management/screens/ and project-management/components/. Requires user stories in project-management/user-stories/.
---

# Extract Screens & Components from User Stories

You are running inside a project directory that contains user stories under `project-management/user-stories/`. Your job is to analyze ALL user stories and produce two deliverables:

1. **Screen inventory** → `project-management/screens/`
2. **Component library** → `project-management/components/`

## Prerequisites — Verify Before Starting

- Confirm `project-management/user-stories/` exists and contains `US-*.md` files
- Optionally read `project-management/personas/` for additional context
- If user stories don't exist, STOP and tell the user

## Phase 1: Screen Extraction

Read ALL user story files. For each distinct screen/view the application needs, create a numbered markdown file:

**Output path:** `project-management/screens/{NN}-{screen-slug}.md`

**Per-screen document:**

```markdown
# {Screen Name}

| Field | Value |
|-------|-------|
| **ID** | `{screen-slug}` |
| **Type** | {Primary|Dashboard|Settings|Modal|Storyboard} |
| **Category** | {Category Name} |
| **User Stories** | {US-001, US-002, ...} |

## Description

{What this screen does and why it exists}

## Key Components

- **{Component name}** — {What it does on this screen} ({US-XXX reference})

## Interactions

- {User interaction description}

## Navigation

- Accessible from: {Where users arrive from}
- Links to: {Where users can go from here}
```

**Screen types:**
- `primary` — Full-page views in main navigation
- `dashboard` — Aggregation/metrics views with charts and cards
- `settings` — Configuration panels
- `modal` — Overlays/dialogs triggered from other screens
- `storyboard` — Multi-step flows/wizards

**Include a `README.md`** with category table, type legend, total count, and confirmation all user stories are mapped.

## Phase 2: Component Extraction

After screens are written, analyze them to extract reusable UI components.

**Output path:** `project-management/components/{NN}-{component-slug}.md`

**Per-component document:**

```markdown
# {Component Name}

| Field | Value |
|-------|-------|
| **ID** | `{component-slug}` |
| **Category** | {Category Name} |
| **Used In** | {NN-Screen Name, NN-Screen Name, ...} |

## Description

{What this component does}

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | {Chip/badge/single-line presentation} |
| **Compact** | {Card/summary presentation} |
| **Expanded** | {Panel/detail presentation} |
| **Full Page** | {Standalone page view} |

(Omit rows where a variant doesn't apply)

## Props / Configuration

- `{propName}` — {description}

## Interactions

- {Interaction description}
```

**Component categories:**
- Data Display — charts, timelines, graphs, progress indicators
- Cards & Tiles — self-contained content containers
- Navigation & Layout — sidebars, tabs, filters, split panels
- Input & Forms — editors, pickers, selectors, builders
- Feedback & Indicators — badges, alerts, status signals
- AI-Specific — suggestion overlays, confidence scores, rationale popovers
- Modals & Overlays — floating containers
- Domain-Specific — components tied to the product's domain
- Tables & Lists — structured row/column data

**Focus on components that:**
- Appear across 2+ screens (shared building blocks)
- Represent complex interaction patterns (even if single-use)
- Have meaningful size variants

**Include a `README.md`** with category table, full index, and total count.

## Phase 3: Validation

After both phases, verify:
- [ ] Every user story maps to at least one screen
- [ ] Every screen's "Key Components" maps to a documented component
- [ ] Component "Used In" fields reference valid screen numbers
- [ ] No orphaned user stories

Report the final counts and any gaps found.
