# Worked Example: Quick Scaffold (Fast-Path)

This example demonstrates the fast-path through the trl-skill-engineer workflow — what happens when a user provides enough information upfront to skip the full interactive discovery phase.

---

## Scenario

A user wants to create a skill called `changelog-generator` and provides this brief:

> "I need a skill that generates changelogs from git history. It should work with conventional commits, support multiple output formats (markdown, JSON, RSS), and integrate with GitHub releases. Target audience is developers maintaining open-source projects. It should NOT handle version bumping (that's a separate concern) and should NOT manage git tags. Related to git-and-github tools in the MCP catalog."

That's enough to get started — but how much is "enough"? The first step is scoring it.

---

## 1. Input Assessment

Score the brief against the eight discovery dimensions before asking any questions.

| Dimension | Status | Evidence |
|-----------|--------|----------|
| Domain | ✓ Complete | "Generates changelogs from git history" — unambiguous |
| Audience | ✓ Complete | "Developers maintaining open-source projects" |
| Use Cases | ✓ Implied | Generate changelog, format output, integrate with GitHub releases |
| Anti-Scope | ✓ Complete | No version bumping, no tag management — explicitly stated |
| Constraints | ✗ Partial | No mention of Claude Teams, NPL, or platform dependencies |
| Tools | ✗ Partial | Mentions GitHub but not specific MCP tools or fallback behavior |
| Cross-References | ✓ Complete | "git-and-github tools in the MCP catalog" |
| Quality Criteria | ✗ Missing | No definition of what a "good" changelog looks like |

**Score: 5.5 / 8**

This is above the threshold for scaffolding (4/8 triggers full discovery; 5+ triggers fast-path). The gaps are small and answerable in a single exchange. Proceed with targeted gap-filling rather than the full discovery interview.

---

## 2. Targeted Gap-Filling

Rather than running the full eight-dimension discovery interview, ask only about the missing dimensions. Keep questions short and concrete.

**Questions sent:**

> 1. **Constraints:** Should this skill work in Claude Teams standalone (no MCP servers available), or can it assume MCP tools are present?
> 2. **Quality criteria:** What makes a good changelog to you — is there a format standard you follow?
> 3. **Tools:** For the GitHub integration, should it use a GitHub MCP tool if available, or prefer CLI/API calls?

**User responses:**

> 1. "Yes, it should work standalone. MCP tools are a nice-to-have, not required."
> 2. "It should follow keepachangelog.com format, group entries by type (Added, Changed, Fixed, etc.), and link to PRs where possible."
> 3. "Use GitHub MCP if available, fall back to gh CLI or GitHub API otherwise."

**Updated score: 7.5 / 8**

The only remaining gap is a worked example scenario, which will be generated as a stub. Ready to scaffold.

---

## 3. Archetype Selection

The trl-skill-engineer selects an archetype based on the use case pattern before generating any files.

**Candidate archetypes:**

| Archetype | Description | Fit |
|-----------|-------------|-----|
| Workflow | Phased process: input → transform → output | Strong |
| Catalog | Browse and retrieve from a knowledge base | Weak — no KB to browse |
| Service | Cross-cutting capability used by other skills | Weak — not advisory |
| Strategy | Advisory framework for decision-making | Weak — this is operational, not strategic |

**Selected: Workflow**

Reasoning: changelog generation is a pipeline — read git log, parse commits by convention, group and format output, optionally publish to GitHub. This maps directly to the workflow archetype's phased structure. Each phase has clear inputs and outputs, making the agent-playbook straightforward to write.

---

## 4. Generated Scaffold

### File Tree

```
skills/changelog-generator/
├── SKILL.md                                      # Entry point with full trigger description
├── references/
│   ├── agent-playbook.claude-code.md             # Agent role + phased workflows (stub)
│   ├── commit-conventions.md                     # Conventional commits reference + parsing rules
│   ├── output-formats.md                         # Markdown, JSON, RSS format specs
│   ├── github-integration.md                     # MCP tool usage, gh CLI fallback, API fallback
│   └── worked-example-react-library.md           # End-to-end example for an OSS React library
├── assets/
│   └── project-tracker.md                        # Tracks changelog runs per project
└── scripts/                                      # Reserved for future automation
```

**Why these reference files?**

- `commit-conventions.md` — the skill is useless without knowing how to parse conventional commits. This is domain-critical knowledge.
- `output-formats.md` — three output formats were explicitly requested. Each has different structure and audience.
- `github-integration.md` — the integration has three fallback tiers (MCP → gh CLI → API). This complexity warrants its own reference.
- `worked-example-react-library.md` — a concrete, realistic scenario for an OSS React library grounds the abstract workflow in something users can follow.

### Generated SKILL.md (frontmatter + first sections)

```yaml
---
name: changelog-generator
description: >
  Generate structured changelogs from git history following conventional commit
  conventions. Use this skill when the user wants to generate a CHANGELOG.md,
  produce a release summary, format git history for GitHub releases, convert
  commits to keepachangelog.com format, group changes by type (Added, Changed,
  Fixed, Deprecated, Removed, Security), output changelog as JSON or RSS, or
  integrate changelog generation into a release workflow — even if they do not
  say "changelog." Also trigger when users mention release notes, commit history
  formatting, or conventional commits output.
triggers:
  - generate changelog
  - release notes from git
  - conventional commits output
  - keepachangelog format
  - changelog for GitHub release
  - format git history
  - group commits by type
anti-triggers:
  - version bumping (use a dedicated versioning skill)
  - git tag management
  - semantic versioning decisions
cross_references:
  - skills/mcp-catalog/git-and-github.md
---
```

```markdown
# Changelog Generator

Generate structured, human-readable changelogs from git history using
conventional commit conventions. Outputs in markdown, JSON, or RSS.

## Scope

**In scope:**
- Parse git log using conventional commit format
- Group entries by type: Added, Changed, Fixed, Deprecated, Removed, Security
- Output as CHANGELOG.md (keepachangelog.com format), JSON, or RSS
- Link entries to PRs and issues where available
- Integrate with GitHub releases via MCP tool, gh CLI, or GitHub API

**Out of scope:**
- Version bumping — this skill reads versions, does not set them
- Git tag management — assumes tags already exist or are handled elsewhere

## When to Use This Skill

Invoke changelog-generator when a user wants to:
- Generate or update CHANGELOG.md for a project
- Produce release notes for a GitHub or GitLab release
- Export commit history in a structured, machine-readable format
- Summarize recent changes grouped by conventional commit type

## Workflow Overview

This skill follows a four-phase pipeline:

1. **Read** — extract git log for a range (tag-to-tag, tag-to-HEAD, or date range)
2. **Parse** — classify commits by conventional commit type; extract PR/issue refs
3. **Format** — render output in the requested format (markdown, JSON, RSS)
4. **Publish** — optionally push to GitHub releases using available integration

See `references/agent-playbook.claude-code.md` for the full agent workflow.
```

---

## 5. What Happened

**Time comparison:**

| Path | Time | Questions Asked |
|------|------|-----------------|
| Full interactive discovery | 2–4 hours | 24 questions across 8 dimensions |
| Fast-path (this example) | ~15 minutes | 3 targeted questions |

**What made this fast-path eligible:**

The user's brief was specific enough to score 5.5/8 without any follow-up. The anti-scope was explicit (a common gap that usually requires a full question), the audience was named, and a cross-reference was provided. The missing dimensions (constraints, tools, quality) were narrow enough to resolve in a single exchange.

**What the fast-path did NOT skip:**

- Completeness scoring — the brief was still measured against all eight dimensions
- Archetype selection — the workflow archetype was explicitly evaluated against alternatives
- Domain-specific reference files — the scaffold was tailored to changelog generation, not generic

**What was deferred to the user:**

- Filling in the agent-playbook workflows (stubs only)
- Writing the worked example content (stub created)
- Validating the commit-conventions and output-formats references against their actual usage

---

## 6. Next Steps

After receiving the scaffold, the user does the following:

1. **Review SKILL.md** — confirm the trigger description covers real invocation patterns; add any missing anti-triggers.

2. **Fill agent-playbook.claude-code.md** — write the actual agent instructions for each workflow phase. The stub has section headers; the user adds the procedural detail.

3. **Write commit-conventions.md** — document the exact conventional commit format supported (Commitizen? Angular? custom?), edge cases, and how to handle non-conventional commits in the repo.

4. **Write output-formats.md** — specify the exact schema for JSON output and the RSS feed structure. Markdown can reference keepachangelog.com directly.

5. **Create a realistic worked example** — the stub at `worked-example-react-library.md` needs a real scenario: a specific repo, a realistic git log excerpt, and the generated changelog output so users can see the skill in action.

6. **Run the quality audit** — use `references/quality-checklist.md` from the trl-skill-engineer skill to verify the scaffold is complete before publishing.

---

*This worked example is part of the trl-skill-engineer reference library. See `discovery-workflow.md` for the full interactive path and `scaffold-specification.md` for the exact output format rules.*
