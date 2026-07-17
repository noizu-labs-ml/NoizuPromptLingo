---
name: generate-personas-and-stories
description: Generate user personas (one per file) under project-management/personas/ and 100 user stories under project-management/user-stories/, with persona cross-references. Reads project README for domain context.
---

# Generate User Personas & User Stories

You are running inside a project directory. Your job is to deeply understand this project and produce two deliverables:

1. **User personas** → `project-management/personas/` (one file per persona)
2. **100 user stories** → `project-management/user-stories/` (one file per story)

---

## Phase 0: Understand the Project

1. Read `README.md` (or `docs/` if README is thin) to understand the product vision, target users, features, and domain
2. Read any existing `project-management/` artifacts if they exist
3. Read any existing `design/` or `docs/` directories for additional context
4. If you cannot determine what the product does, STOP and ask the user

---

## Phase 0.5: Normalize Directory Structure

Before generating anything, check for existing personas and user stories in **non-standard locations** and migrate them to `project-management/`.

### Detection

Check all of these alternative locations for existing persona or user-story files:

| What to look for | Alternative locations to check |
|------------------|-------------------------------|
| Personas | `docs/personas/`, `projects/personas/`, `personas/` |
| User stories | `docs/user-stories/`, `docs/stories/`, `projects/user-stories/`, `projects/stories/`, `user-stories/`, `stories/` |
| Mixed artifacts | `docs/project-management/`, `projects/project-management/` |

### Migration Rules

1. **If `project-management/` already exists with content** → use it as-is, skip migration
2. **If personas or stories exist in an alternative location** → move (rename) the directory into `project-management/` using `git mv` (preserves history). For example:
   - `docs/personas/` → `project-management/personas/`
   - `docs/user-stories/` → `project-management/user-stories/`
   - `projects/stories/` → `project-management/user-stories/` (also normalize the name)
3. **If a `docs/project-management/` or `projects/project-management/` directory exists** → move the whole thing to `project-management/` at the project root
4. **If nothing exists anywhere** → create `project-management/personas/` and `project-management/user-stories/` fresh
5. **After migration**, verify no broken references remain (grep for old paths in any `index.yaml` or markdown cross-references and update them)

### Name Normalization

Always normalize directory names to the canonical forms:
- Personas dir → `project-management/personas/`
- Stories dir → `project-management/user-stories/` (not `stories/`, not `user_stories/`)

---

## Phase 1: User Personas

Create `project-management/personas/index.yaml` and one markdown file per persona.

### How Many Personas

Generate **5-10 personas** covering:
- All primary, secondary, and tertiary user segments mentioned in the project docs
- At least one edge-case or underserved persona the docs don't explicitly mention
- If agents/bots/automated actors are users of the system, include them as persona types

### Persona File Format

**Path:** `project-management/personas/P-{NNN}-{slug}.md`

```markdown
---
id: P-{NNN}
name: "{Full Name}"
slug: "{slug}"
archetype: "{Archetype Label}"
segment: "{primary|secondary|tertiary|edge-case}"
tags: [{tag1}, {tag2}, ...]
---

# {Full Name} — {Archetype Label}

## Demographics

| Field | Value |
|-------|-------|
| **Age** | {range, e.g., 28-35} |
| **Role** | {job title or life role} |
| **Technical Level** | {Novice / Intermediate / Advanced / Expert} |
| **Industry** | {industry or domain} |
| **Location** | {region or context} |

## Bio

{2-3 sentence narrative establishing who this person is, what they care about, and what their day looks like. Make them feel real — not a demographic checklist.}

## Goals

1. {Primary goal — what they're trying to accomplish}
2. {Secondary goal}
3. {Tertiary goal}

## Frustrations

1. {Pain point that this product addresses}
2. {Pain point in their current workflow}
3. {Unmet need}

## Behaviors

- {How they currently solve the problem}
- {Tools they use}
- {Habits relevant to the product}

## Job to Be Done

> "{When I [situation], I want to [motivation], so I can [expected outcome].}"

## Relationship to Product

{How this persona would discover, adopt, and use the product. What features matter most to them. What would make them churn.}

## Scenarios

1. **{Scenario name}** — {Brief description of a realistic usage scenario}
2. **{Scenario name}** — {Another scenario}
```

### Index File

**Path:** `project-management/personas/index.yaml`

```yaml
personas:
  - id: P-001
    name: "{Name}"
    archetype: "{Archetype}"
    segment: "{segment}"
    file: P-001-{slug}.md
  # ... one entry per persona
```

---

## Phase 2: User Stories

Generate exactly **100 user stories**, covering the full breadth of the product.

### Distribution Guidelines

Aim for roughly this distribution (adjust based on the product):

| Category | ~Count | Description |
|----------|--------|-------------|
| **Core features** | 30-40 | The main value proposition features |
| **Onboarding & auth** | 8-12 | Sign up, login, profile setup, first-run |
| **Settings & preferences** | 5-8 | Account, notification, privacy settings |
| **Admin & moderation** | 8-12 | Content moderation, user management, reporting |
| **Search & discovery** | 6-10 | Finding content, filtering, recommendations |
| **Social & collaboration** | 8-12 | Interactions between users, sharing, notifications |
| **Edge cases & error states** | 5-8 | Empty states, error recovery, rate limits |
| **Accessibility & i18n** | 3-5 | Screen reader, keyboard nav, language |
| **Performance & scale** | 3-5 | Loading states, pagination, offline |
| **Integration & API** | 3-5 | External system connections, webhooks, exports |

### Story File Format

**Path:** `project-management/user-stories/US-{NNN}-{slug}.md`

```markdown
---
id: US-{NNN}
title: "{Short title}"
slug: "{slug}"
personas: [{P-001}, {P-003}]
epic: "{Epic Name}"
priority: "{must-have|should-have|could-have|won't-have-yet}"
complexity: "{S|M|L|XL}"
tags: [{tag1}, {tag2}]
---

# US-{NNN}: {Short Title}

## User Story

**As a** {persona archetype or name} ({persona ID}),
**I want to** {action or capability},
**So that** {benefit or outcome}.

## Acceptance Criteria

- [ ] {Given [context], when [action], then [expected result]}
- [ ] {Given [context], when [action], then [expected result]}
- [ ] {Given [context], when [action], then [expected result]}

## Notes

{Any additional context, constraints, edge cases, or design considerations. Reference related stories by ID if applicable (e.g., "Depends on US-005"). Keep brief — 1-3 sentences max.}
```

### Index File

**Path:** `project-management/user-stories/index.yaml`

```yaml
epics:
  - name: "{Epic Name}"
    stories: [US-001, US-002, ...]
  # ... one entry per epic

stories:
  - id: US-001
    title: "{Title}"
    personas: [P-001, P-003]
    epic: "{Epic Name}"
    priority: "{priority}"
    complexity: "{complexity}"
    file: US-001-{slug}.md
  # ... one entry per story
```

---

## Execution Rules

1. **Read the project first.** Every persona and story must be grounded in the actual product — no generic "User wants to log in" without understanding WHY logging in matters for THIS product.

2. **Personas before stories.** Write all personas first, then reference them in stories. Every story must reference at least one persona.

3. **Every persona must appear.** Each persona should be referenced in at least 3 stories. No orphan personas.

4. **Stories must interconnect.** Use "Depends on US-XXX" and "Related: US-XXX" notes where logical dependencies exist.

5. **Prioritize realistically.** Not everything is must-have. Use MoSCoW honestly:
   - `must-have`: Product is broken without it
   - `should-have`: Expected by users, but workarounds exist
   - `could-have`: Nice to have, adds delight
   - `won't-have-yet`: Planned but explicitly deferred

6. **Size honestly.** S = hours, M = 1-2 days, L = 3-5 days, XL = needs decomposition

7. **Write for developers.** Acceptance criteria should be testable. "User can see their profile" is bad. "Given a logged-in user, when they navigate to /profile, then they see their display name, avatar, and bio" is good.

8. **Use parallel agents.** This is a large generation task. Use `npl-tasker-sonnet` or `npl-tasker-fast` agents to parallelize:
   - Agent 1: Generate personas
   - Agents 2-5: Generate 25 stories each (assign epic ranges)
   - Main thread: Write index files after all agents complete

9. **Create directories first.** Ensure `project-management/personas/` and `project-management/user-stories/` exist before writing files.

10. **Large file generation.** For the index files, compile after all individual files are written. Don't try to predict IDs — read what was generated.

---

## Quality Checklist (verify before reporting done)

- [ ] All persona files follow the template exactly
- [ ] `personas/index.yaml` lists all personas
- [ ] Exactly 100 user story files exist
- [ ] `user-stories/index.yaml` lists all 100 stories grouped by epic
- [ ] Every story references at least one persona ID
- [ ] Every persona is referenced by at least 3 stories
- [ ] MoSCoW distribution is realistic (not everything is must-have)
- [ ] Acceptance criteria are testable (Given/When/Then format)
- [ ] Stories cover the full product surface, not just happy paths
- [ ] No duplicate or near-duplicate stories
