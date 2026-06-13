# Screen & Component Extraction Prompt

Use this prompt template to repeat the screen/component extraction process for any project that has user stories defined under `project-management/user-stories/`.

---

## Step 1: Extract Screens from User Stories

```
Analyze the user stories in @projects/{PROJECT_DOMAIN}/project-management/user-stories/ and identify the screens the application requires. For each screen document:

1. Screen ID (kebab-case slug)
2. Screen name (human readable)
3. Type: primary | dashboard | settings | modal | storyboard
4. Which user stories it serves (US-XXX references)
5. Description of what the screen does
6. Key components/widgets it contains
7. User interactions supported
8. Navigation (accessible from, links to)

Group screens into logical categories (e.g., "Today & Daily Planning", "Project Management", "Settings").

Save each screen as a numbered markdown file under:
  project-management/screens/{NN}-{screen-slug}.md

Include a README.md with:
- Category table with screen counts
- Screen type legend
- Total screen count
- Confirmation that all user stories are mapped to at least one screen
```

---

## Step 2: Extract Reusable Components from Screens

```
Analyze all screen files in @projects/{PROJECT_DOMAIN}/project-management/screens/ and extract the reusable UI components. For each component document:

1. Component ID (kebab-case slug)
2. Component name (human readable)
3. Category (Data Display, Cards, Navigation, Input, Feedback, AI-Specific, Modals, Domain-Specific, Tables)
4. Which screens use it (by screen number)
5. Description of what it does
6. Size variants:
   - inline: chip/badge/single-line presentation (or null)
   - compact: card/summary presentation (or null)
   - expanded: panel/detail presentation (or null)
   - full_page: standalone page view (or null)
7. Props/configuration it accepts
8. Interaction patterns

Focus on components that:
- Appear across 2+ screens (shared building blocks)
- Represent complex interaction patterns (even if single-use)
- Have meaningful size variants (shows differently in different contexts)

Save each component as a numbered markdown file under:
  project-management/components/{NN}-{component-slug}.md

Include a README.md with:
- Category table with component counts
- Full component index grouped by category
- Total component count
```

---

## Step 3: Cross-Reference Validation

After both steps, verify:
- [ ] Every user story maps to at least one screen
- [ ] Every screen's "Key Components" section maps to documented components
- [ ] Component "Used In" fields reference valid screen numbers
- [ ] No orphaned user stories or components

---

## Template: Screen File

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
{repeat for each component}

## Interactions

- {User interaction description}
{repeat}

## Navigation

- Accessible from: {Where users arrive from}
- Links to: {Where users can go from here}
```

---

## Template: Component File

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
| **Inline** | {Description or omit row} |
| **Compact** | {Description or omit row} |
| **Expanded** | {Description or omit row} |
| **Full Page** | {Description or omit row} |

## Props / Configuration

- `{propName}` — {description}
{repeat}

## Interactions

- {Interaction description}
{repeat}
```

---

## Usage

Replace `{PROJECT_DOMAIN}` with the target project's domain folder name (e.g., `codefre.sh`, `derobot.is`, `therobotknows.com`).

Prerequisites:
- Project must have user stories in `project-management/user-stories/`
- Optionally has personas in `project-management/personas/` (enriches context)
