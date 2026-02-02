# Skill Definition Conventions

**Standard layout and content structure for all skills in the NoizuPromptLingo system.**

---

## Directory Structure

```
skills/
└── [skill-name]/
    ├── SKILL.md                      # Core skill definition (main file)
    ├── [prompt-name-1].prompt.md     # Prompt templates and frameworks
    ├── [prompt-name-2].prompt.md     # Each file ~500-2000 lines
    └── product-types/                # (Optional) Sub-directories for variants
        ├── [variant-1].prompt.md
        └── [variant-2].prompt.md
```

### Naming Conventions

**Skill directories:** Lowercase with hyphens
- ✅ `market-intelligence`
- ✅ `ai-template-developer`
- ❌ `MarketIntelligence`

**Prompt files:** Descriptive name + `.prompt.md`
- ✅ `niche-discovery.prompt.md`
- ✅ `audience-profiling.prompt.md`
- ❌ `prompt1.md`

**Core file:** Always `SKILL.md`
- ✅ `SKILL.md` (exactly this name)
- ❌ `README.md` or `Skill.md`

---

## SKILL.md Structure

Every skill has a `SKILL.md` file with this standardized structure:

### Header Section
```markdown
# [Skill Name]

**One-sentence tagline describing what the skill does.**

---

## Overview

[2-3 paragraph overview explaining:]
- What this skill accomplishes
- When to use it
- How it fits into the larger system

**Core Purpose:**
- [Purpose 1]
- [Purpose 2]
- [Purpose 3]
```

### When to Use
```markdown
## When to Use This Skill

Use this skill:
- When you [situation 1]
- When you [situation 2]
- When you [situation 3]
```

### Core Concepts (if applicable)
```markdown
## Core Concepts

### Concept 1
[Detailed explanation]

### Concept 2
[Detailed explanation]

### Framework or Model (if applicable)
[Table, matrix, or diagram explaining framework]
```

### Main Content Sections
- **Process/Framework/Methodology** - How the skill works
- **Research Tools** - Tools available to support the skill
- **Templates** - Actionable templates users can customize
- **Common Mistakes** - Pitfalls to avoid
- **Examples** - Real examples showing skill in action

### Navigation & Resources
```markdown
## Next Steps

### Immediate (This [timeframe])
1. [Action 1]
2. [Action 2]

### Short-term (Next [timeframe])
3. [Action 3]
4. [Action 4]

### Implementation
5. [Action 5]

---

## Related Skills

- **[Related Skill 1]** - What it does
- **[Related Skill 2]** - What it does

---

## MCP Resources

Available supplemental resources:

- `mcp://[resource-type]/[resource-name]` - Description
- `mcp://[resource-type]/[resource-name]` - Description

---

## Version History

- **v0.1.0** (2026-02-02) - Initial [skill name]
- **Status:** Production-ready

---

*[One sentence about where to start or what to do next]*
```

---

## Prompt File Structure

Each `.prompt.md` file contains prompts and frameworks users can invoke with Claude.

### Prompt File Header
```markdown
# [Prompt Category Name]

Use this prompt to [describe what it accomplishes].

---

## PROMPT: [Specific Prompt Title]

[Preamble explaining context and what to provide]

### User Input Section
```
Your Input Here:
- [Field 1]: [Example or description]
- [Field 2]: [Example or description]
```

### Prompt Content
[The actual prompt - what to ask Claude]

[Use markdown to structure requests clearly]

### Expected Output
```markdown
## Expected Output Format

[Show example output structure]
- What format to expect
- Key sections
- What data should be in each section
```
```

### Notes
```markdown
## Notes for Best Results

1. [Tip 1]
2. [Tip 2]
3. [Tip 3]

## Related Prompts

- `[other-prompt].prompt.md` - When to use
```

---

## Content Guidelines

### Length
- **SKILL.md:** 2,000-4,000 lines (comprehensive but scannable)
- **Prompt files:** 500-2,000 lines each (focused on one workflow)
- Use headers and whitespace liberally

### Writing Style
- **Active voice:** "Use this to X" not "This can be used to X"
- **Imperative where appropriate:** "Identify the niche" not "The niche should be identified"
- **Concrete examples:** Show actual examples, not vague descriptions
- **Scannable:** Use headers, bullets, tables extensively

### Content Reuse
- **Avoid duplication:** Link to other skills instead of repeating
- **Cross-reference:** Use "See [Skill] for [Topic]" pattern
- **Dependencies:** Clearly state if a skill requires others

### Quality Checklist
- [ ] Core file (SKILL.md) is complete and accurate
- [ ] At least 1-2 prompt files included with actionable templates
- [ ] All sections follow this structure
- [ ] Links to related skills are present
- [ ] MCP resources are listed
- [ ] Version history included
- [ ] No broken internal references
- [ ] Proofread for clarity and typos

---

## Skills Taxonomy

### Skill Categories

**Meta-Skills** (Help choose direction)
- Location: `skills/[name]/`
- Purpose: Strategic decision-making
- Example: `monetization-strategy`

**Core Skills** (Cross-stream, foundational)
- Location: `skills/[name]/`
- Purpose: Used by multiple streams
- Dependency: None or other core skills
- Examples: `market-intelligence`, `keyword-research`

**Stream-Specific Skills** (Domain-specific)
- Location: `skills/[name]/`
- Purpose: Specific to one income stream
- Dependency: Core skills
- Examples: `ai-template-developer`, `content-publisher`

### Skill Interdependencies

Document in SKILL.md:
```markdown
## Related Skills

- **[Prerequisite]** - Must use this first / dependency
- **[Complementary]** - Use alongside this
- **[Optional]** - Can use for advanced workflows
```

---

## Metadata & Indexing

### Version Numbering
- **v0.1.0** - Initial release
- **v0.x.x** - Bug fixes, clarifications, minor updates
- **v1.0.0** - First major release after user feedback
- **v1.x.x** - New prompts, frameworks added
- **v2.0.0** - Major restructure or complete rewrite

### Status Labels
- **Prototype** - First draft, not ready for users
- **Beta** - Ready for testing, may change significantly
- **Production-ready** - Stable, ready for regular use
- **Deprecated** - Use different skill instead

### Tags (optional metadata)
```yaml
tags:
  - research
  - validation
  - ideation
dependencies:
  - market-intelligence
  - (optional) other skills
difficulty: beginner|intermediate|advanced
time_to_complete: "2-3 hours"
```

---

## MCP Resource Conventions

### Resource Naming
```
mcp://[skill-name]/[resource-type]/[resource-name]
```

Examples:
- `mcp://market-intelligence/niche-database/pre-researched`
- `mcp://conversion-marketing/platforms/google-ads`
- `mcp://keyword-research/tools/autocomplete-data`

### Resource Types
- **databases** - Data lookups (niches, benchmarks)
- **platforms** - Platform-specific guides
- **templates** - Reusable templates
- **tools** - Calculators, frameworks
- **examples** - Case studies, examples

---

## Template Structure (Optional)

If a skill provides templates, structure as:

```markdown
## [Template Name]

**Use this template when:** [When to use it]

```markdown
[Template markdown - copy and paste ready]
```

**Customization notes:**
- [What to customize]
- [What to keep]
- [Common variations]
```

---

## Navigation & Discovery

### Skill Index (skills/INDEX.md)
```markdown
# Skill System Index

## Meta-Skills
- **[monetization-strategy](monetization-strategy/)** - Choose your income stream

## Core Skills
- **[market-intelligence](market-intelligence/)** - Find niches
- **[keyword-research](keyword-research/)** - Find topics

## Stream-Specific Skills
- **[ai-template-developer](ai-template-developer/)** - Build templates
```

### Skill Homepage
```markdown
# [Skill Name] Quick Start

1. Read: [Core concept]
2. Use: [Primary prompt file]
3. Next: [Where to go after]

[Link to SKILL.md for full details]
[Link to related skills]
```

---

## Quality Assurance

### Pre-Release Checklist

- [ ] SKILL.md is complete and internally consistent
- [ ] At least one `.prompt.md` file with working prompts
- [ ] All markdown is valid and renders cleanly
- [ ] No broken internal links
- [ ] MCP resources documented (even if not built yet)
- [ ] Dependencies clearly stated
- [ ] Version history included
- [ ] Related skills section complete
- [ ] Proofread by author
- [ ] Tested with Claude to ensure prompts work

### Annual Review
- Update version history
- Review for outdated information
- Incorporate user feedback
- Refresh examples and references

---

## Example: Complete Skill File Structure

```
skills/market-intelligence/
├── SKILL.md
│   └── ~3000 lines
│       - Overview & when to use
│       - Core concepts (niche, scoring)
│       - Research process (5 phases)
│       - Audience profiling template
│       - Validation signals
│       - Common mistakes
│       - Next steps
│       - Related skills
│       - MCP resources
│       - Version history
│
├── niche-discovery.prompt.md
│   └── ~800 lines
│       - Discovery frameworks
│       - How to generate 10-20 ideas
│       - Sources and questions
│       - Expected output
│
├── audience-profiling.prompt.md
│   └── ~700 lines
│       - Detailed audience research
│       - Demographics, psychographics
│       - Pain point mapping
│       - Online behavior
│
├── validation-framework.prompt.md
│   └── ~600 lines
│       - Validation signals
│       - Scoring rubric
│       - Decision criteria
│
└── competitive-analysis.prompt.md
    └── ~500 lines
        - Competition research
        - Gap identification
        - Differentiation framework
```

---

## Using These Conventions

### For Skill Authors
1. Follow this structure exactly
2. Use provided templates as starting point
3. Keep files focused and scannable
4. Link to other skills, don't duplicate

### For Skill Users
1. Start with SKILL.md overview
2. Choose relevant `.prompt.md` file
3. Follow the prompts with Claude
4. Reference related skills as needed

---

## Evolution & Feedback

These conventions will evolve as we learn what works best. When adding new skills:

1. Follow this structure
2. Document any deviations
3. Note feedback for future versions
4. Update this document if you find improvements

---

*Last updated: 2026-02-02*
*Applicable to: v0.1+ of all skills*
