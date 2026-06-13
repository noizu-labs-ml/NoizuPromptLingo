# User Stories — CodeFresh

Planning and conventions for **150 user stories** covering the CodeFresh MVP and near-term roadmap.

**Status:** All three waves complete (US-001–US-150). Schema-alignment pass pending.

## Purpose

User stories are the bridge between:

- **Personas** (`docs/personas/*.md`) — *who* uses the product
- **Architecture** (`docs/PROJ-ARCH.md`) — *what* the system is
- **Data model** (`docs/arch/data-model.md`) — *how* data is structured

Each story answers: "What specific capability does persona X need in order to accomplish workflow Y?"

## Directory Structure

**Flat.** All 128 stories live directly in `docs/user-stories/`, one file per story:

```
docs/user-stories/
├── README.md                        # this file
├── index.md                         # catalog of all stories (regenerated)
├── US-001-create-empty-script.md
├── US-002-add-user-turn-node.md
├── US-003-attach-prompt-to-node.md
├── ...
└── US-128-...md
```

## Naming Convention

- **Story ID:** `US-NNN` — zero-padded, sequential across all 128. Not reset per category.
- **Filename:** `US-NNN-{slug}.md` where slug is kebab-case from the title (~6 words max).
- **Numbering by wave:** US-001 through US-040 = Wave 1 (P0). US-041 through US-090 = Wave 2 (P1). US-091 through US-128 = Wave 3 (P2/P3). Wave boundaries let numeric ordering match implementation sequence.
- Gaps allowed when stories are cancelled. Do not reuse IDs.

## YAML Frontmatter (required)

Designed to map cleanly to Jira, Linear, GitHub Issues, and similar issue trackers. Every field below should be present (use `null` or `[]` rather than omitting).

```yaml
---
# Identity
id: US-001
title: Create an empty script with name and description
issue_type: story
slug: create-empty-script

# Workflow state
status: draft                       # draft | triaged | ready | in-progress | in-review | shipped | cancelled
priority: P0                        # P0 | P1 | P2 | P3

# Sizing
story_points: 2                     # Fibonacci: 1, 2, 3, 5, 8, 13
estimated_scope: XS                 # XS (<1d) | S (1-2d) | M (3-5d) | L (1-2w) | XL (2w+)

# Classification
category: script-authoring          # one of the 12 MVP categories
components:                         # functional areas (Jira-style components)
  - backend
  - frontend
labels:
  - mvp
  - wave-1
  - authoring

# People
assignee: null
reporter: null

# Roadmap
epic: mvp-authoring                 # see Epics table below
wave: 1                             # 1 | 2 | 3
fix_version: "0.1.0"                # target release
sprint: null                        # filled in at sprint planning

# Personas
most_impacted_personas:             # ranked — most affected first
  - priya-ml-engineer
  - alex-oss-maintainer
secondary_personas:
  - nia-academic

# Relations
related_stories:
  - US-002
  - US-006
dependencies: []                    # hard blockers: stories that must ship first
blocks: []                          # stories that wait on this one
duplicates: []

# Schema alignment (post-hoc)
schema_refs: []                     # populated during schema-alignment pass after authoring

# External tracker mapping (populated on sync)
external_refs:
  jira: null                        # e.g. CF-123
  linear: null                      # e.g. CODEF-42
  github: null                      # e.g. codefresh/codefresh#42
  notion: null                      # page id or URL

# Audit
created_at: "2026-04-20"
updated_at: "2026-04-20"
---
```

### Frontmatter field reference

| Field | Required | Purpose |
|---|---|---|
| `id` | ✓ | Stable unique identifier |
| `title` | ✓ | Matches `# Heading` in body |
| `issue_type` | ✓ | Always `story` for this bucket (reserves `bug`, `task`, `epic` for later) |
| `slug` | ✓ | kebab-case, matches filename suffix |
| `status` | ✓ | Workflow state |
| `priority` | ✓ | MVP criticality (P0–P3) |
| `story_points` | ✓ | Fibonacci estimate; maps to Jira / Linear estimate |
| `estimated_scope` | ✓ | Human-readable ballpark (duplicates story_points with a plain-english label) |
| `category` | ✓ | One of the 15 MVP categories |
| `components` | ✓ | Functional areas touched |
| `labels` | ✓ | Free-form tags (Jira labels) |
| `assignee` | ✓ | Null in authoring; set on sync |
| `reporter` | ✓ | Null in authoring; set on sync |
| `epic` | ✓ | Roadmap bucket |
| `wave` | ✓ | 1, 2, or 3 |
| `fix_version` | ✓ | Target release tag |
| `sprint` | ✓ | Null until sprint planning |
| `most_impacted_personas` | ✓ | At least one persona slug |
| `secondary_personas` | ✓ | May be `[]` |
| `related_stories` | ✓ | May be `[]` |
| `dependencies` | ✓ | Hard blockers |
| `blocks` | ✓ | Derived (stories that list this in `dependencies`); kept for forward-refs |
| `duplicates` | ✓ | Usually `[]`; populated if merging |
| `schema_refs` | ✓ | Post-hoc — populated after Wave 3 during schema-alignment pass |
| `external_refs` | ✓ | Object with `jira`, `linear`, `github`, `notion` keys; all null until sync |
| `created_at` / `updated_at` | ✓ | ISO dates |

## Story Body Template

```markdown
# {title}

## Story

As a **{primary persona role}**,
I want to **{capability}**
so that **{outcome}**.

## Acceptance Criteria

- [ ] {specific, testable criterion}
- [ ] ...
- [ ] ...

## Notes

- Design hints, arch references, open questions

## Out of Scope

- What this story deliberately does not cover (link to related stories)
```

Keep stories **single-concern**. If AC exceeds ~8 items, split into related stories.

## Category Breakdown (150 total)

| Category | Prefix | Count | Scope |
|---|---|---|---|
| Script authoring | AUTH | 18 | Graph editor, node/edge CRUD, versioning, YAML import/export, diff view |
| Prompt management | PRT | 8 | Prompt CRUD, template vars, tool defs |
| Persona management | PER | 10 | Persona CRUD, tone variants, layered expectations |
| Rubric & scoring | RUB | 10 | Rubric CRUD, judge prompts, criteria, scoring methods |
| Agent connectors | AGT | 10 | Adapter setup, auth_ref, health checks, request/response mapping |
| Run execution | RUN | 14 | Trigger, streaming, fan-out, cancel, retry, budgets |
| Freeball protocol | FB | 12 | Runner config, confidence, depth caps, policy modes |
| Results & dashboards | DSH | 14 | Lists, detail, drill-down, persona breakdowns, diff, trends, exports |
| OTel ingestion | OTL | 8 | OTLP receiver, correlation, attribute + semantic queries, trace drill-down |
| CLI & CI/CD | CLI | 10 | `codefresh run`, JUnit, threshold gates, CI templates, login |
| Review & promotion | REV | 8 | Freeball review queue, chain promotion, bulk actions |
| Tenancy & admin | ORG | 6 | Org setup, roles, invites, API tokens |
| **SDKs** | **SDK** | **8** | **Python / Elixir / TypeScript clients, OTel bridge helpers, query helpers, webhooks** |
| **Flagged captures** | **FLG** | **6** | **Flag production interactions, browse, promote to scripts or datasets, auto-rules** |
| **Datasets** | **DAT** | **8** | **Request→expected-output datasets, CSV/JSON import, dataset-based eval runs, rubric attach** |
| **Total** | | **150** | |

The three bold categories were added during Wave 2 authoring per direction to cover OTel-ingress → tagging → dataset-curation → model-based-eval pipeline alongside the graph-dynamic-eval that the original 12 categories describe.

**Deferred (post-MVP):** Marketplace/sharing, Audit/compliance, Billing/usage.

Note: the "Prefix (legacy)" column is for internal category grouping only — it does *not* appear in story IDs. Story IDs are `US-NNN` across all categories.

## Epics

Stories group into the following roadmap epics for Jira rollup and release planning:

| Epic | Scope | Spans categories |
|---|---|---|
| `mvp-authoring` | Script, prompt, persona, rubric, expectation authoring | AUTH, PRT, PER, RUB |
| `mvp-agents` | Agent adapter configuration and connection | AGT |
| `mvp-runner` | Executing runs including freeball | RUN, FB |
| `mvp-results` | Displaying runs, scores, dashboards, drill-downs | DSH |
| `mvp-cli` | CLI, CI/CD templates, exports | CLI |
| `mvp-tenancy` | Org, membership, roles, tokens | ORG |
| `post-mvp-otel` | OTel ingestion, correlation, query surface | OTL |
| `post-mvp-review` | Review queue + promotion workflow | REV |
| `post-mvp-sdks` | Python / Elixir / TypeScript client SDKs + OTel bridge | SDK |
| `post-mvp-capture` | Flagged production captures + promotion to scripts/datasets | FLG |
| `post-mvp-datasets` | Dataset CRUD, CSV import, dataset-based eval runs | DAT |

## Persona Cross-Reference

Stories reference personas by slug (matching `docs/personas/{slug}.md`):

| Slug | Role | Product tier |
|---|---|---|
| `priya-ml-engineer` | Senior ML Engineer | primary |
| `marcus-qa-lead` | QA Lead | secondary |
| `yuki-red-teamer` | AI Red Team Researcher | tertiary |
| `alex-oss-maintainer` | OSS Framework Maintainer | influencer |
| `sofia-product-manager` | AI Product Manager | secondary |
| `derek-support-engineer` | Support Automation Engineer | secondary |
| `nia-academic` | AI Research Engineer | tertiary |

**Coverage floor:** every persona appears as `most_impacted_persona` on ≥ 6 stories across the 150.

## Priority Taxonomy

| Priority | Meaning |
|---|---|
| **P0** | MVP-blocking — product cannot launch without it |
| **P1** | MVP-required — meaningful gap if missing |
| **P2** | Post-MVP polish — ships in follow-up releases |
| **P3** | Stretch — may never ship |

**Target distribution (150 total):** ~40 P0 + ~70 P1 + ~32 P2 + ~8 P3.

**Actual distribution (final):** 40 P0 + 70 P1 + 22 P2 + 18 P3. More stories classified as genuinely stretch (P3) than originally planned — honest labeling over aspirational.

## Authoring Waves

| Wave | IDs | Priority | Count | Goal |
|---|---|---|---|---|
| 1 | US-001 – US-040 | P0 | 40 | Smallest viable surface: author a script, connect an agent, run it, see results, basic freeball |
| 2 | US-041 – US-110 | P1 | 70 | Complete MVP + expansion: persona fan-out, rubrics, diff view, CLI, CI/CD templates, review queue, OTel ingress + correlation + query surface, SDKs (Py/Ex/TS), API tokens, flagged captures, datasets, dataset-based eval |
| 3 | US-111 – US-150 | P2/P3 | 40 | Post-MVP polish, OTel trace viewer UI, advanced exports, marketplace groundwork, enterprise readiness |

Each wave is a review gate. No wave starts until the previous is approved.

**Why Wave 2 grew to 70:** The original plan had 50 P1 stories. During authoring we added three new categories (SDK 5 / FLG 4 / DAT 6 Wave-2 stories plus 2 ORG for API tokens and 3 OTL deep-query stories) to cover the OTel-ingress → tagging → dataset-curation → model-based-eval pipeline. These unlock the "production capture → test fixture" workflow that differentiates CodeFresh from script-only eval tools.

## Schema Alignment (Post-Hoc)

Per the authoring decision: **generate all stories first, then run a schema-alignment pass.**

`schema_refs` is a required frontmatter field but starts as `[]`. After Wave 3 completes, a dedicated pass walks every story, identifies affected tables/fields in `docs/arch/data-model.md`, populates `schema_refs`, and surfaces any gaps — either the schema needs extension, or the story's scope is out of plan. This inverts the original plan where schema led stories.

Rationale: stories reveal schema needs more honestly than schema-first authoring does. Stakeholders describe workflows concretely; we then check whether the data model supports them.

## Index Maintenance

`docs/user-stories/index.md` is a catalog of every story (ID, title, priority, primary persona, status). It's **regenerated** from YAML frontmatters, not hand-edited. Proposed regen mechanism: `yq '.[filename]' + find` pipeline (script TBD; author when index diverges from filesystem).

## External Tracker Sync

The `external_refs` object is populated when the story is first replicated into Jira / Linear / GitHub. The reverse — importing existing tracker tickets *into* this directory — is out of scope; these docs are source-of-truth for MVP planning only.

## Related Documents

- `docs/personas/*.md` — persona specs
- `docs/arch/data-model.md` — schema (schema_refs cross-reference)
- `docs/PROJ-ARCH.md` — system architecture
- `docs/arch/freeball-protocol.md` — freeball state machine (STORY-FB-* reference this)

## Wave 1 Readiness Checklist

- [x] Directory: flat
- [x] Naming: `US-NNN-slug.md`
- [x] Frontmatter schema includes Jira/Linear/GitHub sync fields
- [x] Schema alignment deferred to post-Wave-3
- [x] Wave-based authoring
- [x] 12 categories + counts
- [x] Priority taxonomy + target distribution
- [x] Persona coverage floor (≥6 per persona)

All checks green. Wave 1 authoring begins now.
