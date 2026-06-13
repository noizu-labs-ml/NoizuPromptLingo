# Skill Creator Quick Start

**5-minute guide to creating a new skill. For full details, see [SKILL-GUIDELINE.md](SKILL-GUIDELINE.md)**

---

## Minimal Viable Skill Structure

```
skills/[skill-name]/
├── SKILL.md                          # ~2,500 lines - core definition
├── [primary].prompt.md               # ~800 lines - main workflow
├── [secondary].prompt.md             # ~700 lines - optional secondary
├── EVAL/
│   ├── rubric.md                     # Scoring rubric (3-5 dimensions, 0-4 scale)
│   ├── examples.md                   # Good/fair/poor examples for each output type
│   └── checklist.md                  # Operational validation checklist
├── FINE-TUNE/
│   ├── README.md                     # Fine-tuning strategy and goals
│   └── training_data.parquet         # 100-150 OASST format examples
└── MULTI-SHOT/
    ├── index.yaml                    # Metadata index for all examples
    ├── beginner-[name].md            # Beginner walkthrough (30-60 min)
    ├── intermediate-[name].md        # Intermediate (2-3 hours)
    └── advanced-[name].md            # Advanced (3-4+ hours)
```

---

## Before You Start - Pre-Creation Checklist

- [ ] **Scope clear?** One thing, not multiple topics
- [ ] **Not duplicate?** Check existing skills first
- [ ] **Dependencies clear?** What skills must users complete first?
- [ ] **Output defined?** What does success look like?

---

## 4-Week Creation Timeline

### Week 1: Plan (2-3 hours)
```bash
- Define scope: "What exactly does this skill accomplish?"
- Outline SKILL.md: sections and flow
- List key concepts/frameworks to teach
- Identify prompt workflows (what are the main steps?)
- Plan 3 multi-shot examples (beginner/intermediate/advanced)
- Sketch EVAL rubric: what are 3-5 quality dimensions?
```

### Week 2: Draft (8-10 hours)
```bash
- Write SKILL.md draft (don't perfectionism)
- Create 2 prompt files with working examples
- Test prompts with Claude (does it work?)
- Get feedback from 1-2 people
- Create beginner multi-shot example (real execution)
- Draft EVAL rubric (initial scoring dimensions)
- Start collecting fine-tuning examples (30-40 examples)
```

### Week 3: Refine (10-12 hours)
```bash
- Polish SKILL.md based on feedback
- Add examples/templates to prompts
- Complete EVAL folder:
  * Finalize rubric.md (3-5 dimensions, clear criteria)
  * examples.md (good/fair/poor for each output type)
  * checklist.md (verifiable items)
- Complete FINE-TUNE folder:
  * README.md (strategy + hyperparameters)
  * training_data.parquet (100-150 examples, all score 3+/4.0)
- Create intermediate multi-shot example
- Create advanced multi-shot example
- Create MULTI-SHOT/index.yaml
```

### Week 4: Launch (4-5 hours)
```bash
- Final proofread
- Verify all EVAL/FINE-TUNE/MULTI-SHOT folders complete
- Run skill validator tool (check structure)
- Add to skills/INDEX.md
- Update related skills with cross-references
- Mark as "production-ready"
```

**Total time commitment: 24-30 hours over 4 weeks (6-8 hours/week)**

---

## SKILL.md Structure (Simplified)

```markdown
# [Skill Name]

**One-sentence tagline**

---

## Overview

[2-3 paragraphs explaining what this skill does]

**Core Purpose:**
- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

---

## When to Use This Skill

- When you [situation 1] → [outcome]
- When you [situation 2] → [outcome]
- When you [situation 3] → [outcome]

---

## Core Concepts

[2-3 key concepts with detailed explanation]

### Framework/Model

[Table, matrix, or visual framework]

---

## [Process Name] Process

### Phase 1: [Name]
**Goal:** [Specific outcome]
[Explanation]

### Phase 2: [Name]
[Same structure]

---

## Templates

```
[Copy-paste ready template]
```

---

## Common Mistakes to Avoid

| Mistake | Why It Fails | Fix |
|---------|---|---|
| [Mistake] | [Impact] | [Prevention] |

---

## Next Steps

### Immediate
1. [Action 1]
2. [Action 2]

### Short-term
3. [Action 3]

---

## Related Skills

- **[Skill]** - Prerequisite
- **[Skill]** - Complementary

---

## Evaluation & Completion

See `EVAL/` folder for scoring rubric and examples.

---

## Version History

- **v0.1.0** (2026-02-02) - Initial [skill name]
- **Status:** Production-ready

---

[One sentence about where to start]
```

---

## Prompt File Structure

```markdown
# [Prompt Category]

Use this prompt to [accomplish X].

---

## PROMPT: [Specific Title]

[Context: what user should provide]

### What to Provide

```
[Input format or example]
```

### The Prompt

[The actual instruction for Claude]

### Expected Output

```
[Example output showing format]
```

### Tips for Best Results

1. [Tip 1]
2. [Tip 2]

### Related Prompts

- `[other-prompt].prompt.md` - When to use
```

---

## EVAL Folder Checklist

### rubric.md
```markdown
## [Dimension Name]

**Weight:** 30%

| Score | Criteria |
|-------|----------|
| **4** | [Specific observable criteria] |
| **3** | [Criteria] |
| **2** | [Criteria] |
| **1** | [Criteria] |
| **0** | [Missing/flawed] |

**Pass threshold:** 2.5+ out of 4.0
```

**Guidelines:**
- 3-5 dimensions total
- Each dimension 0-4 scale
- Observable, measurable criteria (not vague)
- Weights sum to 100%
- Include examples showing each level

### examples.md
For each output type:
- ✅ **Excellent (4/4)** - Show great example + why it works
- ⚠️ **Fair (2/4)** - Show incomplete example + what's missing
- ❌ **Poor (0/4)** - Show flawed example + correct approach

### checklist.md
- Binary items (yes/no, not subjective)
- 3-4 categories
- 10-15 items total
- Operational focus (can I use this?)

---

## FINE-TUNE Folder Checklist

### README.md
```markdown
# [Skill] - Fine-Tuning Strategy

## Goals

### Goal 1: [Improvement]
- Current gap: [What base model struggles with]
- Target: [What fine-tuned model should do]
- Training approach: [How data teaches this]

## Dataset Overview

**Size:** [Number] examples
**Format:** OASST (prompt + response)

**Distribution:**
- Type 1: X examples
- Type 2: Y examples

## Recommendations

**Approach:** Full fine-tuning / LoRA / In-context learning

**Hyperparameters:**
```yaml
batch_size: 8-16
learning_rate: 2e-5 to 5e-5
epochs: 3-5
```

**Success metrics:**
- EVAL rubric: 2.2 → 3.5 (target improvement)
- Consistency: [Expected variance reduction]
```

### training_data.parquet
```python
import pandas as pd

data = {
    'prompt': ['instruction 1', 'instruction 2', ...],
    'response': ['response 1', 'response 2', ...],
    'metadata': ['{"difficulty":"beginner", "type":"X"}', ...]
}

df = pd.DataFrame(data)
df.to_parquet('training_data.parquet')
```

**Requirements:**
- 100-150 examples minimum
- All examples score 3+/4.0 on EVAL rubric
- Diverse (cover all use cases)
- Real data (not hypothetical)

---

## MULTI-SHOT Folder Checklist

### index.yaml
```yaml
examples:
  - id: "beginner-example"
    title: "Title"
    description: "What this teaches"
    complexity: "beginner"
    time_estimate: "45 minutes"
    file: "beginner-example.md"
    prerequisites: []

  - id: "intermediate-example"
    title: "Title"
    description: "What this teaches"
    complexity: "intermediate"
    time_estimate: "2 hours"
    file: "intermediate-example.md"
    prerequisites: ["beginner-example"]

  - id: "advanced-example"
    title: "Title"
    description: "What this teaches"
    complexity: "advanced"
    time_estimate: "3-4 hours"
    file: "advanced-example.md"
    prerequisites: ["beginner-example", "intermediate-example"]
```

### [example].md - YAML Chat Format
```markdown
# [Example Title]

**Complexity:** Beginner | Intermediate | Advanced
**Time:** ~45 minutes

---

## Overview

[What this demonstrates]

---

## Step 1: [Title]

[Brief explanation]

**User Input:**
```yaml
request: "What user asks"
context: "Situation/constraints"
```

**Claude Response:**
```yaml
response: |
  [Actual response showing skill in action]

reasoning: |
  [Why this approach]

next_steps: |
  [What comes after]
```

---

## Key Takeaways

- [Learning outcome 1]
- [Learning outcome 2]
- [Learning outcome 3]

---

## Next Steps

1. [Action 1]
2. [Action 2]
```

---

## Launch Checklist

Before marking skill "production-ready":

**Content**
- [ ] SKILL.md complete (all sections)
- [ ] 2+ prompt files with examples
- [ ] All internal links work

**EVAL**
- [ ] rubric.md - 3-5 dimensions, clear criteria
- [ ] examples.md - good/fair/poor examples
- [ ] checklist.md - 10-15 verifiable items

**FINE-TUNE**
- [ ] README.md - strategy and hyperparameters
- [ ] training_data.parquet - 100-150 examples, all 3+/4.0
- [ ] Metadata documented (sources, limitations)

**MULTI-SHOT**
- [ ] index.yaml - all 3 examples indexed
- [ ] beginner.md - 30-60 min walkthrough
- [ ] intermediate.md - 2-3 hour walkthrough
- [ ] advanced.md - 3-4+ hour walkthrough
- [ ] YAML format valid and parseable

**Polish**
- [ ] Proofread
- [ ] Run skill validator tool
- [ ] Added to skills/INDEX.md
- [ ] Related skills updated

---

## Anti-Patterns: Don't Do This

❌ **Skill scope too broad**
- "Everything about marketing"
- Fix: Focus on one thing (landing pages OR ads, not both)

❌ **No examples or templates**
- Generic instruction only
- Fix: Include copy-paste ready templates with real examples

❌ **Vague EVAL criteria**
- "Good quality"
- Fix: Observable criteria (e.g., "Includes market size AND demand signals AND 3+ competitors")

❌ **Fine-tuning data quality issues**
- Examples that don't meet EVAL standards
- Repetitive or similar examples
- Fix: Verify each example scores 3+/4.0, ensure diversity

❌ **Multi-shot examples that are hypothetical**
- Perfect idealized examples
- No real data or complexity
- Fix: Use actual skill execution with real data

---

## Common Questions

**Q: How long does this really take?**
A: 24-30 hours over 4 weeks (6-8 hours/week). First skill takes longer, second skill 50% faster.

**Q: Can I create a skill with fewer examples?**
A: Minimum: 1 prompt file, 1 multi-shot example (beginner). Recommended: 2+ prompts, 3 examples.

**Q: Do all sections in SKILL.md need to be long?**
A: No. "Core Concepts" can be skipped for practical skills. "Templates" can be skipped if skill has no reusable templates.

**Q: How do I validate my skill is good?**
A: Run the skill validator tool. Have someone new follow your multi-shot examples - can they replicate results?

**Q: Where do I put the skill?**
A: Create `skills/[skill-name]/` directory. Use lowercase with hyphens (e.g., `skills/market-intelligence/`)

---

## Need Help?

- **Full details:** See [SKILL-GUIDELINE.md](SKILL-GUIDELINE.md)
- **Validator tool:** Run `python tools/skill_validator.py skills/[skill-name]/`
- **Questions:** Check SKILL-GUIDELINE.md troubleshooting section

---

*Quick Start - 5 minute overview*
*For comprehensive guide, see SKILL-GUIDELINE.md*
