# Skills Guidelines

**Comprehensive guide for creating, structuring, and maintaining skills in the NoizuPromptLingo system.**

---

## Table of Contents

1. [Understanding Skill Structure](#part-1-understanding-skill-structure)
2. [Creating a New Skill](#part-2-creating-a-new-skill)
3. [Common Skill Patterns](#part-3-common-skill-patterns)
4. [Quality & Maintenance](#part-4-quality--maintenance)

---

# Part 1: Understanding Skill Structure

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

---

## Directory Structure

```
skills/
└── [skill-name]/
    ├── SKILL.md                      # Core skill definition (main file)
    ├── [prompt-name-1].prompt.md     # Prompt templates and frameworks
    ├── [prompt-name-2].prompt.md     # Each file ~500-2000 lines
    ├── EVAL/                         # Quality evaluation rules (REQUIRED)
    │   ├── rubric.md                 # Scoring rubric for outputs
    │   ├── examples.md               # Good/bad output examples
    │   └── checklist.md              # Validation checklist
    ├── FINE-TUNE/                    # Fine-tuning data (REQUIRED)
    │   ├── README.md                 # Fine-tuning goals and strategy
    │   └── training_data.parquet     # OASST format training dataset
    ├── MULTI-SHOT/                   # Example walkthroughs (REQUIRED)
    │   ├── index.yaml                # Index of all examples with metadata
    │   ├── [example-1].md            # YAML chat thread showing skill in action
    │   ├── [example-2].md            # Different scenario/complexity
    │   └── [example-3].md            # Another use case variant
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

Every skill has a `SKILL.md` file with this standardized structure.

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

### Prompt File Guidelines

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

## EVAL Folder (Quality Evaluation) - REQUIRED

Every skill **must** include an `EVAL/` folder that defines how to judge the quality of outputs when skill agents or users complete the skill.

**Note:** EVAL rules are executed and tracked using **Arize Phoenix** (evals platform). The markdown files in EVAL/ are designed to be compatible with Phoenix's evaluation framework.

### Directory Structure

```
EVAL/
├── rubric.md        # Scoring rubric for evaluating outputs
├── examples.md      # Examples of good and bad outputs
└── checklist.md     # Completion checklist
```

### rubric.md - Scoring Rubric

Defines quantitative and qualitative criteria for evaluating skill completion.

```markdown
# [Skill Name] - Evaluation Rubric

## Overall Scoring

| Score | Description |
|-------|---|
| **4** | Excellent - Exceeds requirements, thorough, actionable |
| **3** | Good - Meets all requirements, usable as-is |
| **2** | Fair - Missing some elements, needs minor revisions |
| **1** | Poor - Significant gaps, doesn't meet requirements |
| **0** | Incomplete - Not attempted or fundamentally flawed |

## Dimension 1: [Aspect Name]

**Weight:** 30%

| Level | Criteria |
|-------|---|
| 4 | [Excellent criteria] |
| 3 | [Good criteria] |
| 2 | [Fair criteria] |
| 1 | [Poor criteria] |
| 0 | [Missing/flawed] |

**Examples:**
- ✅ **4/4:** [Example of excellent output]
- ⚠️ **2/4:** [Example of fair output, what's missing]

## Dimension 2: [Aspect Name]

[Same structure]

## Dimension 3: [Aspect Name]

[Same structure]

## Final Score

`(Dim1_Score × 0.30) + (Dim2_Score × 0.35) + (Dim3_Score × 0.35) = TOTAL`

**Pass threshold:** 2.5+ out of 4.0
```

**Guidelines:**
- 3-5 dimensions (aspects to evaluate)
- Each dimension has clear 4-point scale (0-4)
- Include actual examples showing each level
- Make criteria observable and measurable (not vague)
- Weights should sum to 100%
- Define passing threshold explicitly
- **Phoenix compatibility:** Structure each dimension with:
  - Clear `metric_name` (e.g., "niche_validation")
  - Observable criteria for each score level
  - Examples that Phoenix evaluators can reference
  - Numerical scoring (not just descriptive)

### examples.md - Illustrative Examples

Shows what good, fair, and poor outputs look like.

```markdown
# [Skill Name] - Output Examples

## Example 1: [Specific Output Type]

### ✅ EXCELLENT (Score: 4/4)

[Show complete, excellent output]

**Why it works:**
- [Reason 1]
- [Reason 2]
- [Reason 3]

---

### ⚠️ FAIR (Score: 2/4)

[Show incomplete or partially correct output]

**What's missing:**
- [Missing element 1 - how to fix]
- [Missing element 2 - how to fix]

**How to improve:**
1. [Step 1]
2. [Step 2]

---

### ❌ POOR (Score: 0/4)

[Show fundamentally flawed output]

**Why it fails:**
- [Core problem 1]
- [Core problem 2]

**Correct approach:**
[Describe the right way to do this]
```

**Guidelines:**
- Include 2-3 different output types
- For each type, show all 3 levels: Excellent, Fair, Poor
- Be specific—use real data, not generic templates
- Explain reasoning, not just results
- Make it clear how to improve fair outputs

### checklist.md - Completion Checklist

Operational checklist for validating skill completion.

```markdown
# [Skill Name] - Completion Checklist

Use this checklist to verify skill completion before marking as done.

## Content Quality

- [ ] Output is specific to your situation (not generic template)
- [ ] All sections are filled in (no missing data)
- [ ] Formats follow skill requirements (tables, templates, structure)
- [ ] Examples are included (not just abstract descriptions)
- [ ] No contradictions or conflicting statements

## Depth & Completeness

- [ ] Covers all required aspects from SKILL.md
- [ ] Research/validation is adequate (not superficial)
- [ ] Next steps are clear and actionable
- [ ] Dependencies are documented (what flows from this?)

## Accuracy & Validity

- [ ] Data/facts are current (not outdated)
- [ ] Numbers/metrics are realistic (not inflated)
- [ ] Claims are substantiated (have evidence)
- [ ] Technical details are accurate (if applicable)

## Usability

- [ ] Output is understandable (clear language)
- [ ] Layout is scannable (headers, bullets, tables)
- [ ] Formatting is consistent (same style throughout)
- [ ] Ready to use immediately (doesn't need rewriting)

## Sign-off

- [ ] Output reflects your understanding (not copied verbatim)
- [ ] You can explain each section to someone else
- [ ] You're confident using this for next phase
```

**Guidelines:**
- Focus on operational validation (can I use this?)
- Make items binary (yes/no, not subjective)
- Include 3-4 categories
- 8-12 items total (scannable, not overwhelming)

### Arize Phoenix Integration

EVAL rules are designed to work with **Arize Phoenix** for execution and tracking:

1. **Rubric files** (`rubric.md`) are converted to Phoenix evaluation templates
2. **Each dimension** becomes a Phoenix `metric` with scoring rules
3. **Examples** (`examples.md`) serve as reference data for human or LLM evaluators
4. **Checklist** (`checklist.md`) provides additional validation logic

**Phoenix workflow:**
```
EVAL/rubric.md → Phoenix Template → Run Evaluations → Track Results
                 (auto-converted)    (human/LLM)      (dashboard)
```

For Phoenix setup, see: [Arize Phoenix Documentation](https://docs.arize.com/phoenix)

### Integration with SKILL.md

Add a section in SKILL.md:

```markdown
## Evaluation & Completion

When you finish this skill:

1. **Score your output** using the rubric in `EVAL/rubric.md`
2. **Compare examples** in `EVAL/examples.md` to your work
3. **Complete checklist** in `EVAL/checklist.md`

**Passing threshold:**
- Rubric score: 2.5+ out of 4.0
- Checklist: All items checked ✅

**Evaluation execution:** Arize Phoenix runs automated/human evaluations against these criteria.

See `EVAL/` folder for detailed evaluation criteria.
```

### Rubric Format for Arize Phoenix

When writing `EVAL/rubric.md`, structure dimensions to be Phoenix-compatible:

```markdown
## Dimension: [Metric Name]

**Phoenix Metric ID:** `[metric_name]` (lowercase, underscores)
**Weight:** 30%
**Type:** Numeric (0-4 scale)

| Score | Observable Criteria |
|-------|---|
| **4** | [Measurable, clear criteria that Phoenix evaluators can assess] |
| **3** | [Measurable criteria] |
| **2** | [Measurable criteria] |
| **1** | [Measurable criteria] |
| **0** | [Measurable criteria - completely missing/flawed] |

**Phoenix Examples:**
```json
{
  "metric": "niche_validation",
  "score": 4,
  "reason": "Output includes market size, demand signals, and competitive gaps"
}
```
```

This structure allows rubrics to be automatically converted to Phoenix evaluation templates.

---

## FINE-TUNE Folder (LLM Training Data) - REQUIRED

Every skill **must** include a `FINE-TUNE/` folder containing strategy and training data to improve LLM performance on skill-specific tasks.

### Directory Structure

```
FINE-TUNE/
├── README.md                 # Fine-tuning strategy and goals
└── training_data.parquet     # OASST format training dataset
```

### README.md - Fine-Tuning Strategy

Documents goals, approach, and recommendations for fine-tuning LLMs to improve skill execution.

```markdown
# [Skill Name] - Fine-Tuning Strategy

## Fine-Tuning Goals

### Goal 1: [Specific Capability]

**Target:** Improve LLM's ability to [specific task]

**Current gaps:**
- [What the base model struggles with]
- [What it gets wrong]

**Expected improvement:**
- [What fine-tuned model should do better]
- [Measurable quality improvements]

**Training approach:**
- [How training data addresses this gap]
- [What patterns to teach]

### Goal 2: [Specific Capability]
[Same structure]

## Dataset Overview

**File:** `training_data.parquet`
**Format:** OASST (Open Assistant Standard)
**Size:** [Number] training examples
**Total tokens:** [Approximate token count]

**Data distribution:**
- Example Type 1: [Count] examples
- Example Type 2: [Count] examples
- Example Type 3: [Count] examples

## Data Quality Notes

### Data Sources
- [Where examples came from]
- [How they were curated/validated]
- [Human review process]

### Quality Standards
- Each example meets EVAL criteria (score 3+)
- No duplicates
- Diverse examples (not repetitive)
- Examples follow skill conventions

### Potential Biases
- [Known limitations]
- [Underrepresented cases]
- [Edge cases missing]

## Fine-Tuning Recommendations

### Recommended Approaches

**Option 1: Full Fine-Tuning**
- Model: Claude or similar (if available for fine-tuning)
- Learning rate: [Recommendation]
- Epochs: [Recommendation]
- Cost: [Estimate if applicable]
- Time: [Estimate]

**Option 2: Low-Rank Adaptation (LoRA)**
- More efficient than full fine-tuning
- Recommended for resource constraints
- LoRA rank: [Recommendation]

**Option 3: In-Context Learning (ICL)**
- Use training examples as few-shot prompts
- Requires ~200-500 token budget per skill
- No training cost, only inference cost

### Hyperparameter Suggestions

```yaml
batch_size: 8-16
learning_rate: 2e-5 to 5e-5
num_epochs: 3-5
warmup_steps: 100-500
max_gradient_norm: 1.0
weight_decay: 0.01
```

### Success Metrics

**Primary:** EVAL rubric score improvement
- Current baseline: [e.g., 2.2/4.0]
- Target post-training: [e.g., 3.5/4.0]

**Secondary:** Speed and consistency
- Response time: [Target latency]
- Output consistency: [Variation metrics]

## Dataset Versioning

| Version | Date | Size | Approach | Notes |
|---------|------|------|----------|-------|
| v1.0 | 2026-02-02 | 150 examples | [Method] | Initial dataset |
| v1.1 | TBD | [Size] | [Method] | [Update notes] |

---

## Using This Dataset

### Python Example

```python
import pandas as pd

# Load training data
df = pd.read_parquet('training_data.parquet')

# OASST format: columns are 'prompt', 'response'
for idx, row in df.iterrows():
    prompt = row['prompt']
    response = row['response']
    # Use for fine-tuning...
```

### Data Format

See "OASST Format" section below.

---

## Future Improvements

What should be added to improve fine-tuning?

- [ ] Add [specific data type] examples
- [ ] Expand coverage of [edge case]
- [ ] Improve quality of [aspect]
- [ ] Include examples from [source]
```

**Guidelines:**
- Be specific about what the model should improve
- Document data sources and curation process
- Include realistic hyperparameter suggestions
- Note known gaps and limitations
- Provide versioning for dataset evolution

### training_data.parquet - OASST Format

Parquet file containing instruction-response pairs for fine-tuning LLMs.

**File format (OASST standard):**

| Column | Type | Description | Example |
|--------|------|---|---|
| `prompt` | string | Instruction/question for the LLM | "Identify 5 underserved niches in the AI tools market" |
| `response` | string | Expected/desired response | "Based on market analysis... [detailed response]" |
| `metadata` | string (JSON) | Optional metadata | `{"difficulty": "intermediate", "source": "skill_prompt"}` |

**Example parquet structure:**

```python
import pandas as pd

data = {
    'prompt': [
        'Generate 3 niche ideas for AI templates',
        'Profile the target audience for productivity tools',
        'Create a validation framework for niche demand',
        # ... more examples
    ],
    'response': [
        '1. AI interview prep templates for non-tech roles\n2. ...',
        'Demographics:\n- Age: 25-45\n- Income: $50k-150k+\n...',
        'Validation checklist:\n- [ ] Search volume >1000/mo\n- ...',
        # ... corresponding responses
    ],
    'metadata': [
        json.dumps({'difficulty': 'beginner', 'type': 'ideation'}),
        json.dumps({'difficulty': 'intermediate', 'type': 'research'}),
        json.dumps({'difficulty': 'intermediate', 'type': 'validation'}),
    ]
}

df = pd.DataFrame(data)
df.to_parquet('training_data.parquet')
```

### Dataset Composition Guidelines

**Minimum dataset size:** 100-150 examples
- Represents diverse use cases within skill
- Covers all major prompt types
- Includes edge cases and variations

**Example distribution (for research skill):**

```
ideation prompts:        30 examples (20%)
research/analysis:       40 examples (27%)
validation/evaluation:   35 examples (23%)
synthesis/summary:       25 examples (17%)
edge cases/exceptions:   20 examples (13%)
─────────────────────────────────────
Total:                  150 examples
```

### Data Quality Checklist

- [ ] Each prompt is clear and actionable
- [ ] Each response meets EVAL rubric criteria (3+/4.0)
- [ ] Responses are detailed enough to teach the model (200+ tokens)
- [ ] No duplicate or near-duplicate examples
- [ ] Diverse examples (not all same format)
- [ ] Covers skill scope completely
- [ ] Edge cases included
- [ ] Examples are recent/current (not outdated)
- [ ] No PII or sensitive information
- [ ] Metadata is accurate and consistent

### OASST Format Rationale

Using OASST (Open Assistant Standard) format allows:
- Compatibility with common fine-tuning frameworks
- Easy conversion to other formats (JSON, CSV, etc.)
- Standard dataset versioning and sharing
- Integration with evaluation pipelines
- Human-readable, inspectable data

---

## MULTI-SHOT Folder (Example Walkthroughs) - REQUIRED

Every skill **must** include a `MULTI-SHOT/` folder containing example walkthroughs that demonstrate the skill in action, showing how to use prompts to transform input data into desired outputs.

### Directory Structure

```
MULTI-SHOT/
├── index.yaml                 # Index of all examples with metadata
├── beginner-niche-validation.md     # Example walkthrough (beginner level)
├── intermediate-audience-profiling.md  # Example walkthrough (intermediate)
└── advanced-competitive-analysis.md    # Example walkthrough (advanced)
```

### index.yaml - Example Index

YAML file that catalogs all multi-shot examples with searchable metadata.

```yaml
# Multi-Shot Example Index for [Skill Name]
# Lists all example walkthroughs with metadata for discovery and filtering

examples:
  - id: "beginner-niche-validation"
    title: "Validating a New Niche Idea"
    description: "Complete walkthrough of validating a single niche idea from concept to validation report"

    # Complexity and scope
    complexity: "beginner"  # beginner | intermediate | advanced
    time_estimate: "45 minutes"
    skill_level_required: "none - start here"

    # What this example teaches
    learning_outcomes:
      - "How to use niche-discovery prompt"
      - "How to validate market demand signals"
      - "How to assess competitive landscape"

    # What makes this example valuable
    highlights:
      - "Shows real AI tools niche with actual market data"
      - "Demonstrates how to ask follow-up questions"
      - "Includes common mistakes to avoid"

    # Example input/context
    input_type: "niche idea + 2-3 constraints"
    input_example: "Niche: AI interview prep for non-technical roles | Budget: $500/month marketing"

    # Expected output/outcome
    output_type: "validated niche profile with demand signals"
    expected_outcome: "Niche score: 3.2/5.0 (viable, pursue further)"

    # File reference
    file: "beginner-niche-validation.md"

    # Metadata for indexing
    tags:
      - "niche-discovery"
      - "validation"
      - "single-niche"

    prerequisites: []  # No other skills required

  - id: "intermediate-audience-profiling"
    title: "Deep Audience Profiling for Multiple Segments"
    description: "Advanced audience research showing how to profile 3 different buyer segments in one workflow"

    complexity: "intermediate"
    time_estimate: "2 hours"
    skill_level_required: "Complete beginner example first"

    learning_outcomes:
      - "Segmenting audiences by buyer type"
      - "Creating personas from research"
      - "Identifying pain points and motivations"
      - "Mapping audience to monetization strategy"

    highlights:
      - "Shows parallel vs sequential research approaches"
      - "Demonstrates cost-benefit analysis of segments"
      - "Includes persona templates"

    input_type: "niche + list of potential buyer segments"
    input_example: "Niche: AI templates | Segments: individual developers, small agencies, enterprises"

    output_type: "3 detailed audience personas with segment scoring"
    expected_outcome: "Primary segment identified with 4.2/5.0 potential score"

    file: "intermediate-audience-profiling.md"

    tags:
      - "audience-profiling"
      - "personas"
      - "segmentation"
      - "multi-segment"

    prerequisites:
      - "beginner-niche-validation"

  - id: "advanced-competitive-analysis"
    title: "Comprehensive Competitive Landscape Mapping"
    description: "Full competitive analysis with positioning strategy for a mature market"

    complexity: "advanced"
    time_estimate: "3-4 hours"
    skill_level_required: "Complete both beginner and intermediate examples"

    learning_outcomes:
      - "Mapping full competitive landscape"
      - "Identifying white space opportunities"
      - "Creating positioning strategy"
      - "Building differentiation framework"

    highlights:
      - "Real competitive landscape example (20+ competitors)"
      - "Shows how to spot trends and market shifts"
      - "Includes competitor weakness analysis"

    input_type: "niche + validated audience segments"
    input_example: "Niche: AI templates | Audiences: developers, non-technical pros"

    output_type: "competitive positioning matrix + differentiation strategy"
    expected_outcome: "Blue ocean opportunity identified with 4.8/5.0 uniqueness score"

    file: "advanced-competitive-analysis.md"

    tags:
      - "competitive-analysis"
      - "positioning"
      - "differentiation"
      - "market-mapping"

    prerequisites:
      - "beginner-niche-validation"
      - "intermediate-audience-profiling"
```

**Guidelines:**
- 3-5 examples total (beginner, intermediate, advanced)
- Clear complexity levels for self-selection
- Specific learning outcomes for each example
- Highlights what makes this example valuable
- Prerequisites listed (what skills/examples should come first)
- Tags for searching and discovering related examples
- Time estimates realistic for actual skill execution

### example.md - Multi-Shot Walkthrough

Markdown file containing YAML-formatted chat thread showing skill execution step-by-step.

```markdown
# [Example Title]

**Complexity:** Beginner | Intermediate | Advanced
**Time:** ~45 minutes
**Outcome:** [What you'll have after completing this]

---

## Overview

[1-2 paragraphs explaining what this example demonstrates]

**You'll learn:**
- [Learning outcome 1]
- [Learning outcome 2]
- [Learning outcome 3]

**Starting point:**
- [What you have before starting]

**End result:**
- [What you'll produce]

---

## The Walkthrough

### Step 1: [Step Title]

[Brief explanation of what you're doing and why]

**User Input:**
```yaml
request: "Generate 3 niche ideas for AI templates"
context:
  constraints: "Budget $500/month, 20 hours/week time"
  interests: ["AI", "automation", "business tools"]
  experience: "10 years software engineering"
```

**Claude Response:**
```yaml
response: |
  Based on your background, here are 3 niche AI template opportunities:

  1. **AI Code Review Templates**
  - Target: Development teams at early-stage startups
  - Market size: $2.4B code review tools market
  - Entry barrier: Low (repackage existing frameworks)

  2. **AI Interview Preparation for Non-Tech Roles**
  - Target: Career changers, job seekers (non-technical)
  - Market size: $1.2B professional development
  - Differentiation: Unique angle (non-tech focus)

  3. **AI Documentation Generator Templates**
  - Target: Solo developers, small agencies
  - Market size: $800M technical documentation
  - Opportunity: Undersaturated niche

  My recommendation: Niche #2 - largest market + unique angle

reasoning: |
  - Niche #2 has proven demand (2.3M+ monthly searches)
  - Non-tech angle reduces competition significantly
  - Strong monetization path (premium courses + templates)
  - Aligns with your experience (can create authentic content)

next_steps: |
  - Validate audience depth (do people pay for this?)
  - Research 5 competitors in this space
  - Profile your target customer
```

**What this shows:**
- How the model generates multiple options
- Reasoning behind recommendations
- Structured output format
- Clear next steps

---

### Step 2: [Step Title]

[Explanation of next phase]

**User Input:**
```yaml
request: "Profile the target audience for niche #2"
follow_up: "I want to understand who would buy this, not just demographics"
data_provided:
  niche: "AI interview prep for non-technical roles"
  market_size: "$1.2B professional development"
```

**Claude Response:**
```yaml
response: |
  ## Target Audience Profile: Career Changers into Tech

  ### Primary Persona: "Anxious Career Changer" (Alicia)
  **Demographics:**
  - Age: 28-45
  - Income: $45k-$65k (looking to increase)
  - Education: Bachelor's (non-CS field)
  - Location: Distributed (40% urban, 60% suburban)

  **Psychographics:**
  - Fears: "Will I be good enough?" "Am I too old?"
  - Pain points: No CS background, interviews feel overwhelming
  - Motivations: Career stability, 40% salary increase, creative fulfillment
  - Decision style: Data-driven (wants proof this works)

  ### Buying Behavior:
  - Price sensitivity: Medium ($29-$99 products)
  - Purchase trigger: After first rejection or failed interview
  - Success metric: Landed 3 interviews in 2 weeks

  ### Where they hang out:
  - r/cscareerquestions (23k members, daily activity)
  - Dev.to (200k+ monthly visitors in career section)
  - LinkedIn learning community (5.2M followers)

  ### Monetization insights:
  - Willing to pay for: Templates + personal coaching
  - Won't pay for: Generic interview advice (free alternatives exist)
  - Optimal price: $47-$67 for template bundle

reasoning: |
  This audience is underserved - existing tools assume CS background.
  They're willing to pay premium for specialized, non-tech-specific prep.
  High confidence in this audience based on community size + engagement.

validation_steps: |
  1. Post your templates in r/cscareerquestions
  2. Track feedback and pricing tolerance
  3. Interview 5 career changers about willingness to pay
  4. Measure landing rate with your templates vs standard ones
```

**What this shows:**
- Multi-dimensional audience understanding (not just demographics)
- Specific pain points and buying triggers
- Real platforms where audience exists
- Monetization insights based on customer psychology
- Measurable validation approaches

---

### Step 3: [Step Title]

[Final phase - validation and decision]

**User Input:**
```yaml
request: "Create a validation checklist for this niche"
context: "I want to know before I invest 30 hours - is this real?"
constraints:
  budget: "$500 for validation research"
  time: "2 weeks before committing"
```

**Claude Response:**
```yaml
response: |
  ## Niche Validation Checklist

  ### Demand Validation (Required Score: 3/5+)

  - [ ] Search volume check
    - Google Trends: "AI interview prep" →  8.2/10 (strong)
    - "Interview practice non-tech" → 6.1/10 (moderate)
    - "Career change interview tips" → 7.8/10 (strong)
    - VERDICT: ✅ Demand signal strong

  - [ ] Community validation
    - r/cscareerquestions discussions mentioning "interview prep": 32/week
    - LinkedIn posts asking for interview help: 120+/week
    - Quora questions about career change interviews: 500+/week
    - VERDICT: ✅ Underserved audience confirmed

  ### Monetization Validation (Required Score: 2.5/5+)

  - [ ] Competitive pricing check
    - Interview Master (similar product): $49/month → 12k reviews, 4.2★
    - Prep.com (career focus): $29-79 → 5k reviews
    - Your estimated gap: "Non-tech specific" angle
    - VERDICT: ✅ $47-67 price point validated

  - [ ] Willingness to pay (conduct 5 interviews)
    - Question: "Would you pay $49 for templates specifically for non-tech career changers?"
    - Target score: 4/5 would say yes
    - VERDICT: ⏳ Pending (do interviews this week)

  ### Market Saturation (Required Score: 3.5/5+)

  - [ ] Direct competitor count
    - Google Search "AI interview prep templates": 2.1M results
    - But "non-tech specific interview prep": 89k results
    - Actual competitor count (viable offerings): 7 (not 100)
    - VERDICT: ✅ Low direct competition in your niche

  ### Final Score: 3.8/5.0 ✅ PURSUE THIS NICHE

scoring_logic: |
  Demand: 3.5/5 (strong audience, clear pain point)
  Monetization: 3.2/5 (pricing validated, need willingness-to-pay confirmation)
  Competition: 4.5/5 (huge white space in "non-tech specific" angle)

  Recommendation: Pursue with confidence. Complete willingness-to-pay validation before building.

next_phase: |
  Phase 1: Validate willingness to pay (2 weeks, $0)
  Phase 2: Build MVP template set (30 hours)
  Phase 3: Launch on Gumroad (week 4)
  Phase 4: Track metrics and iterate
```

**What this shows:**
- Concrete validation metrics vs vague "feels good"
- How to structure and score validation results
- Clear decision criteria for go/no-go
- Integration of multiple data sources
- Actionable next phases

---

## Key Takeaways

**What you learned:**
- [Key insight 1]
- [Key insight 2]
- [Key insight 3]

**Common mistakes to avoid:**
- ❌ [Mistake 1]
- ❌ [Mistake 2]

**Next steps:**
1. [Action 1 - what to do after this example]
2. [Action 2 - where to go next in skill]
3. [Action 3 - progression to intermediate]

---

## Questions This Raised

**"How would this change if I already had an audience?"**
The audience profiling would focus on segments within your existing community vs finding new markets...

**"What if competition is more intense than validation shows?"**
Follow the advanced example [link] for competitive positioning strategy...

---

*Example created: 2026-02-02*
*Skill version: v0.1.0*
```

**Guidelines for example.md:**
- Real, concrete data (not hypothetical)
- YAML chat format showing actual turn-taking
- 3-5 steps showing progression
- Each step explains what the skill accomplishes
- Demonstrates follow-up questions and reasoning
- Shows how to use outputs for next phase
- Includes "what this shows" callouts
- Highlights common mistakes and next steps
- Uses realistic time/scope expectations

### Multi-Shot Example Composition

**For each skill, create 3 examples:**

1. **Beginner Example** (entry point)
   - Simple, narrow scope
   - Single niche/idea/focus area
   - 30-60 minutes of work
   - No prerequisites
   - Shows "happy path" execution

2. **Intermediate Example** (build on basics)
   - Multiple segments or scenarios
   - Combines 2+ prompts from skill
   - 2-3 hours of work
   - Prerequisite: beginner example
   - Shows how to handle complexity

3. **Advanced Example** (mastery demonstration)
   - Complex real-world scenario
   - Shows decision-making with uncertainty
   - 3-4+ hours of work
   - Prerequisites: both simpler examples
   - Demonstrates edge cases and trade-offs

### Data Format in Examples

Each step should show YAML chat with:

```yaml
# User provides
request: "What the user asks for"
context: "Situation, constraints, previous outputs"
data_provided: "Any inputs or references"

# Claude provides
response: |
  [The actual response - can be long and structured]

reasoning: |
  [Why this approach - makes thinking visible]

next_steps: |
  [What comes after - clear progression]
```

This allows:
- Clear input → output mapping
- Visible reasoning and decision-making
- Copy-paste ready (users can follow along)
- Documentation of real skill execution
- Training data for fine-tuning

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

## Metadata & Indexing

### Version Numbering

- **v0.1.0** - Pre-production (draft, testing)
- **v1.0.0** - Production release (stable, ready for users)
- **v1.x.x** - Updates (bug fixes, clarifications, new prompts)
- **v2.0.0** - Major revision (restructure, complete rewrite)

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

## Content Guidelines

### Length
- **SKILL.md:** 2,000-4,000 lines (comprehensive but scannable)
  - Minimum: 1,500 lines
  - Target: 2,500-3,500 lines
  - Maximum: 4,500 lines (consider splitting if larger)
  - Ratio: ~70% conceptual, ~30% templates/examples

- **Prompt files:** 500-2,000 lines each
  - Minimum: 300 lines per prompt
  - Target: 800-1,200 per prompt
  - Maximum: 2,000 per file (split if larger)
  - Ratio: ~50% instruction, ~50% examples/output

### Writing Style
- **Active voice:** "Use this to X" not "This can be used to X"
- **Imperative where appropriate:** "Identify the niche" not "The niche should be identified"
- **Concrete examples:** Show actual examples, not vague descriptions
- **Scannable:** Use headers, bullets, tables extensively

### Content Reuse
- **Avoid duplication:** Link to other skills instead of repeating
- **Cross-reference:** Use "See [Skill] for [Topic]" pattern
- **Dependencies:** Clearly state if a skill requires others

---

# Part 2: Creating a New Skill

## Pre-Creation Checklist

Before starting a new skill, answer these questions:

- [ ] **Scope clear?** What exactly does this skill accomplish? (One thing, not multiple)
- [ ] **Fits system?** Does it fit the monetization/product/tracking framework?
- [ ] **Not duplicate?** Is there an existing skill that does this?
- [ ] **Dependencies clear?** What skills must users complete first?
- [ ] **Output defined?** What does successful completion look like?
- [ ] **MCP resources identified?** What external resources does it reference?

---

## Creation Workflow

### Week 1: Plan
- [ ] Define skill scope (one thing)
- [ ] Outline SKILL.md structure
- [ ] List key concepts/frameworks
- [ ] Identify prompt workflows
- [ ] Plan integration points
- [ ] **Plan EVAL folder structure** (what are success criteria?)
- [ ] **Plan FINE-TUNE strategy** (what LLM capabilities to improve?)
- [ ] **Plan MULTI-SHOT examples** (what use cases to demonstrate?)
  - [ ] Identify 3 examples (beginner, intermediate, advanced)
  - [ ] Define realistic input data for each
  - [ ] Outline expected outputs/outcomes

### Week 2: Draft
- [ ] Write SKILL.md draft
- [ ] Create 2 prompt files
- [ ] Test prompts with Claude
- [ ] Get feedback from others
- [ ] **Create EVAL/ folder with initial rubric** (draft scoring criteria)
- [ ] **Start collecting training data** (begin drafting 30-40 OASST examples)
  - [ ] Gather diverse examples from skill execution
  - [ ] Format as prompt-response pairs
  - [ ] Note difficulty and type metadata
- [ ] **Create beginner multi-shot example**
  - [ ] Execute skill end-to-end with real data
  - [ ] Document each step with YAML chat format
  - [ ] Write walkthrough explaining what/why

### Week 3: Refine
- [ ] Incorporate feedback
- [ ] Add examples/templates
- [ ] Test complete workflow
- [ ] Verify all links work
- [ ] Run QA checklist
- [ ] **Complete EVAL/ folder** (finalize rubric, examples, checklist)
  - [ ] `EVAL/rubric.md` with 3-5 dimensions
  - [ ] `EVAL/examples.md` with good/fair/poor samples
  - [ ] `EVAL/checklist.md` with verification items
  - [ ] Link EVAL from SKILL.md "Evaluation & Completion" section
- [ ] **Complete FINE-TUNE/ folder**
  - [ ] `FINE-TUNE/README.md` with goals and strategy
  - [ ] Finalize `training_data.parquet` (100-150 examples)
  - [ ] Verify all examples score 3+/4.0 on EVAL rubric
  - [ ] Document data sources and quality notes
- [ ] **Complete MULTI-SHOT/ folder**
  - [ ] Create `MULTI-SHOT/index.yaml` (all 3 examples indexed)
  - [ ] Finalize intermediate example
  - [ ] Finalize advanced example
  - [ ] Verify all examples are end-to-end executable
  - [ ] Test that someone can follow along and replicate

### Week 4: Launch
- [ ] Final proofread
- [ ] **Verify EVAL rules are clear and usable**
- [ ] **Verify FINE-TUNE data is complete and quality-reviewed**
- [ ] **Verify MULTI-SHOT examples work as documentation**
  - [ ] Examples show real outputs, not hypothetical
  - [ ] YAML format is properly parseable
  - [ ] Each example demonstrates distinct learning goal
  - [ ] Complexity progression is clear (beginner → advanced)
- [ ] Add to INDEX.md
- [ ] Update related skills
- [ ] Create MCP resource placeholders
- [ ] Mark as "production-ready"

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

❌ **Missing or vague EVAL rules**
- "Just do your best" or "I'll know it when I see it"
- Fix: Create clear rubric with 3+ dimensions, show examples, make checklist items verifiable

❌ **EVAL rules that are too strict**
- Rubric criteria impossible to achieve
- Fix: Base rubric on realistic skill completion (not perfection)

❌ **Missing or low-quality fine-tuning data**
- Training data is too small (<50 examples)
- Examples don't meet EVAL standards
- Repetitive or similar examples
- Fix: Collect 100-150 diverse examples, verify each against rubric

❌ **Fine-tuning goals that are too vague**
- "Improve skill performance" (what does that mean?)
- Fix: Specify measurable improvements (e.g., "increase niche validation score from 2.2 to 3.5")

❌ **Training data without metadata**
- No documentation of sources or curation process
- No notes on known gaps
- Fix: Include comprehensive README explaining data collection, quality, and limitations

❌ **Multi-shot examples that are hypothetical or idealized**
- "Perfect" examples that don't match real execution
- Outputs that are unrealistically polished
- No real data or specific details
- Fix: Use actual skill execution with real data, show thinking process

❌ **Multi-shot examples that are too similar**
- All 3 examples look nearly identical (same niche, same approach)
- No clear progression in complexity
- Fix: Each example should demonstrate distinct use case and learning goal

❌ **MULTI-SHOT/ folder without index.yaml**
- Examples scattered with no way to discover them
- No metadata or complexity labeling
- Users don't know which example to start with
- Fix: Create comprehensive index.yaml with searchable metadata

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

# Part 3: Common Skill Patterns

## Pattern 1: Research Skill

**Structure:**
- SKILL.md: Framework + phases + common mistakes
- discovery.prompt.md: How to generate/find things
- validation.prompt.md: How to validate findings
- analysis.prompt.md: How to analyze results

**Example:** market-intelligence

---

## Pattern 2: Creation Skill

**Structure:**
- SKILL.md: Framework + deliverables + quality standards
- ideation.prompt.md: Generate ideas/concepts
- creation.prompt.md: Build/create the thing
- optimization.prompt.md: Refine and improve

**Example:** pod-designer

---

## Pattern 3: Strategy Skill

**Structure:**
- SKILL.md: Decision framework + scenarios
- assessment.prompt.md: Evaluate your situation
- planning.prompt.md: Create your plan
- execution.prompt.md: Execute the plan

**Example:** monetization-strategy

---

## Pattern 4: Tracking Skill

**Structure:**
- SKILL.md: Metrics framework + KPIs
- setup.prompt.md: Initialize tracking
- weekly.prompt.md: Weekly reviews
- monthly.prompt.md: Monthly analysis
- product-type-variants: Category-specific guidance

**Example:** conversion-metrics

---

# Part 4: Quality & Maintenance

## Pre-Release Checklist

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

## Launch Checklist

Before marking skill as "production-ready":

### Content & Structure
- [ ] SKILL.md complete with all sections
- [ ] 2+ prompt files with working prompts
- [ ] **EVAL/ folder complete** (REQUIRED)
  - [ ] `EVAL/rubric.md` - Scoring rubric with 3-5 dimensions
  - [ ] `EVAL/examples.md` - Good/fair/poor examples for each output type
  - [ ] `EVAL/checklist.md` - Operational completion checklist
  - [ ] SKILL.md includes "Evaluation & Completion" section linking to EVAL/
- [ ] **FINE-TUNE/ folder complete** (REQUIRED)
  - [ ] `FINE-TUNE/README.md` - Fine-tuning strategy and goals
  - [ ] `FINE-TUNE/training_data.parquet` - 100-150 OASST format examples
  - [ ] Dataset meets quality standards (all examples score 3+/4.0 on EVAL rubric)
  - [ ] Metadata documented (data sources, curation process, limitations)
- [ ] **MULTI-SHOT/ folder complete** (REQUIRED)
  - [ ] `MULTI-SHOT/index.yaml` - Index of 3+ examples with metadata
  - [ ] `MULTI-SHOT/[beginner].md` - Beginner example walkthrough (30-60 min)
  - [ ] `MULTI-SHOT/[intermediate].md` - Intermediate example (2-3 hours)
  - [ ] `MULTI-SHOT/[advanced].md` - Advanced example (3-4+ hours)
  - [ ] All examples use YAML chat format with input → output mapping
  - [ ] Examples show real data and reasoning, not hypothetical scenarios

### Testing & Validation
- [ ] Tested with Claude (prompts work)
- [ ] EVAL rubric tested on sample outputs
- [ ] Examples in EVAL/ are realistic and useful
- [ ] Checklist items are verifiable (not vague)
- [ ] Fine-tuning dataset reviewed for quality
- [ ] Training data diversity verified (not repetitive)
- [ ] **Multi-shot examples tested end-to-end**
  - [ ] Can someone follow along and replicate results?
  - [ ] Outputs match real skill execution (not idealized)?
  - [ ] Each example demonstrates distinct use case?
  - [ ] YAML format is properly formatted and parseable?

### Integration
- [ ] All links verified (internal + MCP)
- [ ] Added to skills/INDEX.md
- [ ] Related skills updated with cross-references
- [ ] MCP resources documented (placeholders OK)

### Metadata & Polish
- [ ] Version history: v0.1.0 with date
- [ ] Status set to "Production-ready"
- [ ] Proofread by author (spellcheck, grammar)
- [ ] Reviewed for accuracy (facts checked)

---

## Maintenance & Updates

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

## Example: Complete Skill Structure

```
skills/market-intelligence/
├── SKILL.md (3,200 lines)
│   - Overview & concepts
│   - 5-phase research process
│   - Audience profiling template
│   - Niche scoring framework
│   - Common mistakes
│   - Evaluation & Completion (links to EVAL/)
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
├── competitive-analysis.prompt.md (500 lines)
│   - PROMPT: Analyze competition
│   - Gap identification
│   - Differentiation framework
│   - Output format
│
├── EVAL/ (150-300 lines total)
│   ├── rubric.md
│   │   - 4-point scoring scale (0-4)
│   │   - 4 dimensions (niche validation, research depth, audience clarity, actionability)
│   │   - Each dimension has observable criteria
│   │   - Weighted scoring (sum to 100%)
│   │   - Pass threshold: 2.5+/4.0
│   │
│   ├── examples.md
│   │   - Example 1: Niche Profile (Excellent, Fair, Poor samples)
│   │   - Example 2: Audience Profile (Excellent, Fair, Poor samples)
│   │   - Example 3: Validation Report (Excellent, Fair, Poor samples)
│   │   - For each: why it works/fails, how to improve
│   │
│   └── checklist.md
│       - Content Quality (5 items)
│       - Depth & Completeness (4 items)
│       - Accuracy & Validity (4 items)
│       - Usability (4 items)
│       - Sign-off (3 items)
│
├── FINE-TUNE/ (150 total)
│   ├── README.md (~1,500 lines)
│   │   - Fine-tuning goals (2-3 specific improvements)
│   │   - Dataset overview and composition
│   │   - Data quality notes and sources
│   │   - Recommended approaches (Full FT, LoRA, ICL)
│   │   - Hyperparameter suggestions
│   │   - Success metrics and baselines
│   │   - Dataset versioning
│   │
│   └── training_data.parquet (100-150 examples)
│       - OASST format: prompt + response columns
│       - Metadata: difficulty, type, source
│       - All examples score 3+/4.0 on EVAL rubric
│       - Diverse coverage of all prompt types
│       - ~250-500 tokens per response
│
└── MULTI-SHOT/ (1,500-2,500 lines total)
    ├── index.yaml
    │   - 3 examples indexed with metadata
    │   - Beginner: "Validating a Single Niche" (30-60 min)
    │   - Intermediate: "Deep Audience Profiling" (2-3 hours)
    │   - Advanced: "Competitive Landscape Mapping" (3-4 hours)
    │   - Each with: complexity, learning outcomes, highlights, prerequisites
    │
    ├── beginner-niche-validation.md (600 lines)
    │   - YAML chat showing niche validation end-to-end
    │   - Input: Single niche idea + constraints
    │   - Step 1: Generate validation questions
    │   - Step 2: Research demand signals
    │   - Step 3: Score and decide
    │   - Shows real data and reasoning
    │
    ├── intermediate-audience-profiling.md (700 lines)
    │   - YAML chat showing multi-segment profiling
    │   - Input: Niche + 3 buyer segments
    │   - Step 1: Profile each segment
    │   - Step 2: Create personas
    │   - Step 3: Score and rank segments
    │   - Shows cost-benefit analysis
    │
    └── advanced-competitive-analysis.md (800 lines)
        - YAML chat showing full competitive landscape
        - Input: Niche + validated audiences
        - Step 1: Map competitors (20+)
        - Step 2: Identify positioning gaps
        - Step 3: Create differentiation strategy
        - Shows market dynamics and positioning
```

---

## Evolution & Feedback

These guidelines will evolve as we learn what works best. When adding new skills:

1. Follow this structure
2. Document any deviations
3. Note feedback for future versions
4. Update this document if you find improvements

---

*Last updated: 2026-02-02*
*Consolidated from: skill-setup.md & skills-layout.md*
*EVAL framework designed for: Arize Phoenix evaluation platform*
*Fine-tuning data format: OASST (Open Assistant Standard) in Parquet*
*Multi-shot examples format: YAML chat threads with input → output mapping*
