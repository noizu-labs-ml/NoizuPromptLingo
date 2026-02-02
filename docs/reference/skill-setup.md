# Skill Setup Conventions

**Step-by-step guide for creating and setting up new skills in the NoizuPromptLingo system.**

---

## Pre-Creation Checklist

Before starting a new skill, answer these questions:

- [ ] **Scope clear?** What exactly does this skill accomplish? (One thing, not multiple)
- [ ] **Fits system?** Does it fit the monetization/product/tracking framework?
- [ ] **Not duplicate?** Is there an existing skill that does this?
- [ ] **Dependencies clear?** What skills must users complete first?
- [ ] **Output defined?** What does successful completion look like?
- [ ] **MCP resources identified?** What external resources does it reference?

---

## Directory Setup

### Step 1: Create Directory Structure

```bash
skills/[skill-name]/
├── SKILL.md              # Main skill definition (REQUIRED)
├── [prompt-1].prompt.md  # Primary workflow
├── [prompt-2].prompt.md  # Secondary workflow
└── (optional subdirs)
    └── product-types/    # For multi-variant skills
        ├── [variant-1].prompt.md
        └── [variant-2].prompt.md
```

### Step 2: Naming Conventions

**Directory name:**
- Lowercase with hyphens
- Descriptive (not abbreviations)
- Examples: `market-intelligence`, `conversion-marketing`
- ❌ Don't: `MI`, `conv-mktg`, `MarketIntelligence`

**Main file:**
- Always named exactly: `SKILL.md`
- Never: `README.md`, `Skill.md`, `overview.md`

**Prompt files:**
- Format: `[descriptive-name].prompt.md`
- Use hyphens for word separation
- Examples: `niche-discovery.prompt.md`, `audience-profiling.prompt.md`
- ❌ Don't: `prompt1.md`, `main_prompt.md`, `Niche Discovery.md`

---

## SKILL.md Structure

The main skill file should follow this exact structure:

### 1. Header (Lines 1-5)

```markdown
# [Skill Name]

**One-sentence tagline describing what the skill does.**

---
```

**Guidelines:**
- Title matches directory name (Title Case)
- Tagline: concise, benefit-focused
- Example: "# Market Intelligence Skill" / "**Identify, validate, and score underserved niches**"

### 2. Overview Section (Lines 7-20)

```markdown
## Overview

[2-3 paragraph overview explaining:]
- What this skill accomplishes in concrete terms
- When/why you'd use it
- How it fits into the larger system

**Core Purpose:**
- [Purpose 1 - specific outcome]
- [Purpose 2 - specific outcome]
- [Purpose 3 - specific outcome]
```

**Guidelines:**
- Be specific about what the skill enables
- Explain the "why" not just "what"
- Core Purpose should be 2-4 bullets, outcomes not activities
- Example ❌: "Help you research markets"
- Example ✅: "Validate that a market has paying customers before building"

### 3. When to Use Section (Lines 22-30)

```markdown
## When to Use This Skill

Use this skill:
- When you [situation 1] → [outcome]
- When you [situation 2] → [outcome]
- When you [situation 3] → [outcome]
```

**Guidelines:**
- 3-5 concrete use cases
- Include trigger (when/situation) and outcome
- Make it clear when NOT to use
- Example: "When you have 5 product ideas and need to pick which to build first"

### 4. Core Concepts (Lines 32-60, if applicable)

```markdown
## Core Concepts

### Concept 1: [Name]
[2-3 paragraph explanation]

### Framework/Model
| Item | Description |
|------|-------------|
| | |

### Scoring Rubric (if applicable)
[Detailed scoring methodology]
```

**Guidelines:**
- Only include if skill has core concepts to teach
- Can skip for very practical skills
- Include visual frameworks (tables, diagrams)
- Make concepts concrete with examples

### 5. Process/Methodology Section (Lines 62-150)

```markdown
## [Process Name] Process

### Phase 1: [Name]
**Goal:** [Specific outcome]

[Detailed explanation]

**Checklist:**
- [ ] [Item 1]
- [ ] [Item 2]

### Phase 2: [Name]
[Same structure]
```

**Guidelines:**
- Break skill into logical phases/stages
- Each phase has clear goal and deliverables
- Include checklists for validation
- Use ~2-3 phases for simple skills, up to 5-6 for complex ones

### 6. Templates (Lines 152-200, if applicable)

```markdown
## [Template Name]

**Use when:** [Specific situation]

```markdown
[Copy-paste ready template]
```

**Customization notes:**
- [What to modify]
- [What to keep consistent]
```

**Guidelines:**
- Provide working templates users can customize
- Make them copy-paste ready
- Include clear customization guidance
- Can be multiple templates per skill

### 7. Common Mistakes Section (Lines 202-230)

```markdown
## Common Mistakes to Avoid

| Mistake | Why It Fails | Prevention |
|---------|---|---|
| [Mistake 1] | [Impact] | [How to avoid] |
| [Mistake 2] | [Impact] | [How to avoid] |
```

**Guidelines:**
- Include 4-8 real mistakes users make
- Explain consequences
- Provide specific prevention strategies
- Base on actual user experience if possible

### 8. Next Steps Section (Lines 232-260)

```markdown
## Next Steps

### Immediate ([Timeframe])
1. [Action 1]
2. [Action 2]

### Short-term ([Timeframe])
3. [Action 3]
4. [Action 4]

### Implementation
5. [Action 5]
```

**Guidelines:**
- 3 timeframes: immediate (days), short-term (weeks), implementation (ongoing)
- Include specific, actionable steps
- Reference related skills for next phase

### 9. Navigation Section (Lines 262-end)

```markdown
## Related Skills

- **[Prerequisite]** - Must complete this first
- **[Complementary]** - Use alongside this skill
- **[Optional]** - Useful for advanced workflows

---

## MCP Resources

Available supplemental resources:

- `mcp://[path]/[resource]` - [Description]
- `mcp://[path]/[resource]` - [Description]

---

## Version History

- **v0.1.0** (2026-02-02) - Initial [skill name]
- **Status:** Production-ready

---

*[One sentence about where to start or what to do next]*
```

**Guidelines:**
- Related Skills: use 2-3 per category
- MCP Resources: list even if not built yet (marks for future)
- Version History: track all releases
- Final line: simple, actionable starting point

---

## Prompt File Structure

Each `.prompt.md` file contains 1-3 working prompts for Claude.

### File Header

```markdown
# [Prompt Category Name]

Use this prompt to [describe what it accomplishes].

---
```

### Prompt Format

```markdown
## PROMPT: [Specific Prompt Title]

[Preamble: Context and what user should provide]

### What to Provide

```
[Input fields or example format]
```

### The Prompt

[The actual prompt text - what to ask Claude]

[Use markdown headers for structure]

### Expected Output

```markdown
## Expected Output Format

[Show example output]

Key sections:
- [Section 1]: [What goes here]
- [Section 2]: [What goes here]
```

### Tips for Best Results

1. [Tip 1]
2. [Tip 2]

### Related Prompts

- `[other-file].prompt.md` - When/why to use it
```

### Multiple Prompts Per File

If a file has 3+ related prompts:

```markdown
# [Workflow Name]

Use these prompts to [accomplish X].

---

## PROMPT 1: [Name]

[Prompt 1 structure as above]

---

## PROMPT 2: [Name]

[Prompt 2 structure as above]

---

## PROMPT 3: [Name]

[Prompt 3 structure as above]
```

---

## Prompt File Guidelines

### Length & Scope
- **Per file:** 500-2,000 lines
- **Per prompt:** One coherent workflow (5-30 minutes of work)
- **Per SKILL.md:** 2,000-4,000 lines (comprehensive)

### Content Requirements

**Every prompt should include:**
- [ ] Clear purpose statement
- [ ] Input requirements (what user provides)
- [ ] The actual prompt (Claude instruction)
- [ ] Expected output format (what to expect back)
- [ ] 2-3 tips for best results
- [ ] Links to related prompts

**Best practices:**
- Use markdown headers extensively for scanability
- Include examples (actual, not hypothetical)
- Define terms that aren't universal
- Link to other skills for dependencies
- Keep prompts focused (one thing, done well)

---

## Quality Assurance Checklist

Before marking a skill as "production-ready":

### Content
- [ ] SKILL.md is complete (all sections present)
- [ ] At least 2 `.prompt.md` files with working prompts
- [ ] No broken internal links (check related skills references)
- [ ] No external link rot (MCP resources documented)
- [ ] Markdown renders cleanly (no formatting errors)

### Structure
- [ ] File naming follows conventions exactly
- [ ] Directory structure matches template
- [ ] Related skills section is complete
- [ ] MCP resources listed (even if not built)
- [ ] Version history present

### Usability
- [ ] Someone new could follow this skill end-to-end
- [ ] Outcomes are clear (what does completion look like)
- [ ] Prompts work with standard Claude invocation
- [ ] Dependencies are explicit
- [ ] Time estimates are realistic

### Content Quality
- [ ] Proofread (no typos, grammar errors)
- [ ] Specific examples provided (not vague)
- [ ] Jargon explained or linked
- [ ] Active voice where appropriate
- [ ] Scannable (lots of white space, headers, bullets)

### Accuracy
- [ ] Facts are correct (or marked as opinion)
- [ ] Links are current (test MCP resource paths)
- [ ] Pricing/timeline info accurate
- [ ] No misleading claims or guarantees

---

## Integration Points

### Step 1: Add to skills/INDEX.md

Add entry to appropriate section:

```markdown
#### **[skill-name]/**
[One sentence description]

**When to use:**
- [Use case 1]
- [Use case 2]

**Key files:**
- `SKILL.md` - [What's in it]
- `[prompt].prompt.md` - [What's in it]

**Time investment:** [hours]
**Outcome:** [What you get]

**Dependencies:** [Other skills]
**Next:** [Where to go after]
```

### Step 2: Update Related Skills

In any related skill's SKILL.md, add reference:

```markdown
## Related Skills

- **[Your New Skill]** - How it connects
```

### Step 3: Register MCP Resources

In the skill's SKILL.md section, list resources (even if not built):

```markdown
## MCP Resources

- `mcp://[skill-name]/[category]/[resource]` - [Description]
```

Then create issue/task to build actual MCP resources.

### Step 4: Cross-Link Prompts

If skill uses concepts from other skills:

```markdown
## Prerequisites

Before using this skill, complete:
- [Prerequisite Skill] - [Why it matters]

See [`[related-skill]/SKILL.md`](../../[related-skill]/SKILL.md) for details.
```

---

## Common Skill Patterns

### Pattern 1: Research Skill

**Structure:**
- SKILL.md: Framework + phases + common mistakes
- discovery.prompt.md: How to generate/find things
- validation.prompt.md: How to validate findings
- analysis.prompt.md: How to analyze results

**Example:** market-intelligence

---

### Pattern 2: Creation Skill

**Structure:**
- SKILL.md: Framework + deliverables + quality standards
- ideation.prompt.md: Generate ideas/concepts
- creation.prompt.md: Build/create the thing
- optimization.prompt.md: Refine and improve

**Example:** pod-designer

---

### Pattern 3: Strategy Skill

**Structure:**
- SKILL.md: Decision framework + scenarios
- assessment.prompt.md: Evaluate your situation
- planning.prompt.md: Create your plan
- execution.prompt.md: Execute the plan

**Example:** monetization-strategy

---

### Pattern 4: Tracking Skill

**Structure:**
- SKILL.md: Metrics framework + KPIs
- setup.prompt.md: Initialize tracking
- weekly.prompt.md: Weekly reviews
- monthly.prompt.md: Monthly analysis
- product-type-variants: Category-specific guidance

**Example:** conversion-metrics

---

## File Size Guidelines

**SKILL.md:**
- Minimum: 1,500 lines (comprehensive)
- Target: 2,500-3,500 lines (complete)
- Maximum: 4,500 lines (consider splitting if larger)
- Ratio: ~70% conceptual, ~30% templates/examples

**Prompt files:**
- Minimum: 300 lines per prompt
- Target: 800-1,200 per prompt
- Maximum: 2,000 per file (split if larger)
- Ratio: ~50% instruction, ~50% examples/output

---

## Maintenance & Updates

### Version Numbering

- **v0.x.x** - Pre-production (draft, testing)
- **v1.0.0** - Production release (stable, ready for users)
- **v1.x.x** - Updates (bug fixes, clarifications, new prompts)
- **v2.0.0** - Major revision (restructure, complete rewrite)

### Update Frequency

- **Quarterly review** - Check for outdated info
- **Annual update** - Refresh examples, incorporate feedback
- **As-needed** - Fix errors, add clarifications
- **User feedback** - Incorporate within 2 weeks of report

### Deprecation Process

If a skill becomes obsolete:

1. Mark as "Deprecated" in status
2. Document replacement skill
3. Add migration note to SKILL.md
4. Keep in repo for historical reference
5. Remove from active navigation

---

## Examples

### Complete Skill Structure (market-intelligence)

```
skills/market-intelligence/
├── SKILL.md (3,200 lines)
│   - Overview & concepts
│   - 5-phase research process
│   - Audience profiling template
│   - Niche scoring framework
│   - Common mistakes
│   - Next steps
│
├── niche-discovery.prompt.md (800 lines)
│   - PROMPT: Generate niche ideas
│   - Input requirements
│   - Expected output
│   - Tips
│
├── audience-profiling.prompt.md (700 lines)
│   - PROMPT: Profile target audience
│   - Demographics section
│   - Psychographics section
│   - Output format
│
├── validation-framework.prompt.md (600 lines)
│   - PROMPT: Validate demand signals
│   - Validation checklist
│   - Signal strength hierarchy
│   - Output format
│
└── competitive-analysis.prompt.md (500 lines)
    - PROMPT: Analyze competition
    - Gap identification
    - Differentiation framework
    - Output format
```

---

## Troubleshooting

### Problem: Skill feels too big

**Solution:** Split into two skills
- Core foundational concepts → Keep
- Advanced/optional concepts → New skill
- Add cross-reference between them

### Problem: Unclear what users should do

**Solution:** Make outcomes explicit
- Every section needs deliverable
- "Next Steps" should be specific actions
- Prompts should have clear outputs

### Problem: Too much content, hard to scan

**Solution:** Use aggressive formatting
- More headers (H3, H4)
- More bullet points
- More white space
- Move details to prompt files

### Problem: Prompts don't work with Claude

**Solution:** Test with actual Claude usage
- Paste prompt into Claude.ai
- Try 2-3 different contexts
- Refine based on results
- Include working examples

---

## Creation Workflow

### Week 1: Plan
- [ ] Define skill scope (one thing)
- [ ] Outline SKILL.md structure
- [ ] List key concepts/frameworks
- [ ] Identify prompt workflows
- [ ] Plan integration points

### Week 2: Draft
- [ ] Write SKILL.md draft
- [ ] Create 2 prompt files
- [ ] Test prompts with Claude
- [ ] Get feedback from others

### Week 3: Refine
- [ ] Incorporate feedback
- [ ] Add examples/templates
- [ ] Test complete workflow
- [ ] Verify all links work
- [ ] Run QA checklist

### Week 4: Launch
- [ ] Final proofread
- [ ] Add to INDEX.md
- [ ] Update related skills
- [ ] Create MCP resource placeholders
- [ ] Mark as "production-ready"

---

## Anti-Patterns to Avoid

❌ **Too broad scope**
- "Everything about marketing"
- Fix: Focus on one thing (landing pages OR ads, not both)

❌ **Duplicate content**
- Repeating concepts from other skills
- Fix: Reference other skills, link to them

❌ **Vague deliverables**
- "Learn about niches"
- Fix: "Create validated niche profile with audience data and competitive analysis"

❌ **No examples**
- Generic templates only
- Fix: Include real examples for each template

❌ **Unclear dependencies**
- Prerequisite skills not mentioned
- Fix: "Must complete X first" in "Related Skills"

❌ **Outdated MCP resources**
- Resources that don't exist
- Fix: Document actual paths once built

❌ **Poor scanability**
- Walls of text
- Fix: Headers every 2-3 paragraphs, lots of bullets

---

## Launch Checklist

Before marking skill as "production-ready":

- [ ] SKILL.md complete with all sections
- [ ] 2+ prompt files with working prompts
- [ ] Tested with Claude (prompts work)
- [ ] All links verified (internal + MCP)
- [ ] Added to skills/INDEX.md
- [ ] Related skills updated with cross-references
- [ ] MCP resources documented (placeholders OK)
- [ ] Version history: v0.1.0 with date
- [ ] Status set to "Production-ready"
- [ ] Proofread by author (spellcheck, grammar)
- [ ] Reviewed for accuracy (facts checked)

---

*Last updated: 2026-02-02*
*For updates, see: docs/references/skills-layout.md*
