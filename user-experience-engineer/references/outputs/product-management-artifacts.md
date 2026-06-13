# Product Management Artifacts

> Generates the `project-management/` artifact tree as part of project hydration — personas, user stories, screens, and components. This is the bridge between "understanding the product" and "designing the interface."

---

## 1. Overview

When hydrating a project, the UX Engineer generates `project-management/` as the foundation for all subsequent design work. These artifacts are not documentation for its own sake — they are **inputs to the design pipeline**: screens become sitemap pages, components become the design system's library.

Run this phase before SITEMAP.md. Run it after reading the project README and any existing docs.

```
Brief → Interpret → [Personas & Stories → Screens → Components] → SITEMAP.md → Wireframe → ...
                     └─ this document ─────────────────────────┘
```

---

## 2. Pipeline

Three sequential phases, each phase consuming the prior phase's output:

| Phase | Input | Output | Command |
|-------|-------|--------|---------|
| **1** | Project README, docs/, design/ | `project-management/personas/` + `project-management/user-stories/` | `generate-personas-and-stories` |
| **2** | All user story files | `project-management/screens/` | `extract-screens` |
| **3** | All screen files | `project-management/components/` | `extract-screens` (components pass) |

---

## 3. Phase 1: Personas & User Stories

### 3.1 Pre-Generation Steps

1. Read project README, `docs/`, `design/` for domain context
2. Check for existing artifacts in non-standard locations (e.g., `specs/personas/`, `user-research/`); migrate via `git mv` — do not copy+delete
3. Create directories: `project-management/personas/` and `project-management/user-stories/`

### 3.2 Persona Generation

Generate **5–10 personas** covering all user segments:

| Segment | Count | Examples |
|---------|-------|---------|
| Primary users | 2–3 | Power users, daily active users |
| Secondary users | 1–2 | Occasional users, stakeholders |
| Tertiary users | 1–2 | Admins, support staff |
| Edge cases | 1–2 | Accessibility needs, low-bandwidth, non-native language |

**File path:** `project-management/personas/P-{NNN}-{slug}.md`

**Format:**

```markdown
---
id: P-001
name: "Full Name"
slug: persona-slug
archetype: "Short archetype label"
segment: primary | secondary | tertiary | edge-case
tags: [tag1, tag2]
---

# P-001: Full Name

## Demographics

| Attribute | Value |
|-----------|-------|
| Age | XX |
| Occupation | ... |
| Location | ... |
| Tech comfort | low / medium / high |

## Bio
[2-3 sentences establishing who this person is]

## Goals
- [Primary goal]
- [Secondary goal]

## Frustrations
- [Frustration 1]
- [Frustration 2]

## Behaviors
- [Relevant behavior pattern]

## Job to Be Done
> "When [situation], I want to [motivation], so I can [expected outcome]."

## Relationship to Product
[How and why they use the product]

## Scenarios
- **Scenario 1:** [Name] — [Brief description of a usage scenario]
```

### 3.3 User Story Generation

Generate **100 user stories** with MoSCoW prioritization and persona cross-references.

**File path:** `project-management/user-stories/US-{NNN}-{slug}.md`

**Format:**

```markdown
---
id: US-001
title: "Short action title"
slug: short-action-title
personas: [P-001, P-003]
epic: "Epic Name"
priority: must-have | should-have | could-have | wont-have
complexity: low | medium | high
tags: [tag1, tag2]
---

# US-001: Short Action Title

## User Story

**As a** [persona role]
**I want to** [action]
**So that** [outcome]

## Acceptance Criteria

- **Given** [precondition]
  **When** [action]
  **Then** [expected result]

## Notes
[Optional clarifications, edge cases, open questions]
```

### 3.4 Story Distribution

Target distribution across 100 stories:

| Category | Count |
|----------|-------|
| Core features | 30–40 |
| Onboarding & auth | 8–12 |
| Settings & preferences | 5–8 |
| Admin & moderation | 8–12 |
| Search & discovery | 6–10 |
| Social & collaboration | 8–12 |
| Edge cases & error states | 5–8 |
| Accessibility & i18n | 3–5 |
| Performance & scale | 3–5 |
| Integration & API | 3–5 |

### 3.5 Index Files

After all individual files are written, generate index files:

**`project-management/personas/index.yaml`**
```yaml
personas:
  - id: P-001
    name: Full Name
    slug: persona-slug
    archetype: Short archetype label
    segment: primary
    file: P-001-persona-slug.md
```

**`project-management/user-stories/index.yaml`**
```yaml
user_stories:
  - id: US-001
    title: Short action title
    slug: short-action-title
    epic: Epic Name
    priority: must-have
    personas: [P-001]
    file: US-001-short-action-title.md
```

---

## 4. Phase 2: Screen Extraction

### 4.1 Process

1. Read ALL user story files from `project-management/user-stories/`
2. Group stories by the screens/views they imply
3. For each distinct screen, create one numbered markdown file
4. Create a README.md with the full index

### 4.2 Screen File Format

**File path:** `project-management/screens/{NN}-{screen-slug}.md`

```markdown
# {NN}: Screen Name

| Field | Value |
|-------|-------|
| ID | SCR-{NN} |
| Type | primary \| dashboard \| settings \| modal \| storyboard |
| Category | Onboarding / Core / Discovery / Admin / etc. |
| User Stories | US-001, US-002, US-007 |

## Description
[What this screen does and when users encounter it]

## Key Components
- ComponentName — [brief purpose]
- ComponentName — [brief purpose]

## Interactions
- [Interaction 1]
- [Interaction 2]

## Navigation
- **From:** [What leads to this screen]
- **To:** [Where this screen leads]
```

**Screen types:**

| Type | When to Use |
|------|------------|
| `primary` | Main feature screens, most important views |
| `dashboard` | Data overview screens, home screens |
| `settings` | Configuration, preferences, profile |
| `modal` | Overlays, dialogs, drawers |
| `storyboard` | Multi-step flows (onboarding, wizards) |

### 4.3 Screens README

`project-management/screens/README.md` includes:
- Category table (category → screen list)
- Type legend
- Total screen count

---

## 5. Phase 3: Component Extraction

### 5.1 Process

1. Read ALL screen files from `project-management/screens/`
2. Identify reusable UI elements across screens
3. Prioritize components that appear in 2+ screens, have complex interaction patterns, or have meaningful size variants
4. Create one file per component
5. Create a README.md with the full index

### 5.2 Component File Format

**File path:** `project-management/components/{NN}-{component-slug}.md`

```markdown
# {NN}: Component Name

| Field | Value |
|-------|-------|
| ID | CMP-{NN} |
| Category | Data Display \| Cards & Tiles \| Navigation & Layout \| etc. |
| Used In | SCR-01, SCR-03, SCR-07 |

## Description
[What this component does and where it appears]

## Size Variants

| Variant | Use Case |
|---------|---------|
| Default | [When to use] |
| Compact | [When to use] |
| Large | [When to use] |

## Props / Configuration
- `prop-name` — [type] — [description]
- `prop-name` — [type] — [description]

## Interactions
- [Hover/focus/active states]
- [Keyboard behavior]
- [Animation notes]
```

### 5.3 Component Categories

| Category | Examples |
|----------|---------|
| Data Display | Stats, metrics, charts, badges, tags |
| Cards & Tiles | Content cards, feature tiles, profile cards |
| Navigation & Layout | Nav bars, sidebars, breadcrumbs, tabs |
| Input & Forms | Search bars, filters, form fields, date pickers |
| Feedback & Indicators | Loading states, progress bars, toasts, alerts |
| AI-Specific | Stream outputs, thinking indicators, prompt inputs |
| Modals & Overlays | Dialogs, drawers, tooltips, popovers |
| Domain-Specific | Project-specific components not fitting above |
| Tables & Lists | Data tables, list views, sortable grids |

### 5.4 Components README

`project-management/components/README.md` includes:
- Category table (category → component list)
- Full index (ID, name, used-in count, screens)
- Total component count

---

## 6. Validation Checklist

Run after all three phases complete:

- [ ] Every user story maps to at least one screen
- [ ] Every screen's Key Components list maps to a documented component
- [ ] Component "Used In" fields reference valid screen IDs
- [ ] No orphaned user stories (every story appears in at least one screen)
- [ ] Every persona is referenced by at least 3 user stories
- [ ] MoSCoW distribution is realistic (Must > Should > Could >> Won't)
- [ ] All index files generated after individual files
- [ ] No files left in non-standard locations (migration complete)

---

## 7. Integration with Design Sprint

Product management artifacts feed directly into the sitemap and wireframing phases:

```
Brief
  └─ Interpret
       └─ Personas & User Stories   ← Phase 1 (this doc)
            └─ Screen Extraction    ← Phase 2 (this doc)
                 └─ Component Library  ← Phase 3 (this doc)
                      └─ SITEMAP.md    ← screens become pages
                           └─ Wireframes  ← components inform layout
                                └─ Style Guide → Implementation
```

**Screens → Sitemap:** Each screen in `project-management/screens/` maps to a route entry in `design/SITEMAP.md`. Primary and dashboard screens become top-level routes; modals become overlays within routes.

**Components → Design System:** The component list from Phase 3 defines the scope of the design system. These are the components to spec in the style guide and implement in the frontend.

See [`outputs/sitemap.md`](sitemap.md) for sitemap format.
See [`process/design-sprint.md`](../process/design-sprint.md) for the full sprint context.

---

## 8. Execution Notes

| Concern | Guideline |
|---------|-----------|
| **Parallel generation** | For 100 stories, spawn parallel `npl-tasker-sonnet` agents by epic or category; merge results into sequential IDs |
| **Directory creation** | Create all directories before writing any files |
| **Index files** | Write index files AFTER all individual files are complete |
| **Migration** | Use `git mv` for moving existing artifacts; never copy+delete |
| **Large file caution** | Break generation into logical sections (10-20 stories per pass); review before continuing |
| **ID padding** | Always zero-pad: `P-001`, `US-042`, `SCR-07`, `CMP-03` |
| **Slug format** | Lowercase, hyphenated, derived from the title; no special characters |
| **Overwrites** | Check for existing files before writing; prompt user if collision detected |
