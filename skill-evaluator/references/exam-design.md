# Exam Design Guide

## Philosophy

Exams test *understanding* not *recall*. A skill that can parrot its documentation verbatim but can't apply its methodology to novel situations is a skill that fails in practice. Exams probe the gap between "knows the docs" and "understands the domain."

## Question Types

### Multiple Choice

Multiple-choice questions are efficient for broad coverage. Each question has:
- A stem (the question)
- One correct answer
- 2-3 distractors (plausible wrong answers)
- A distractor type classification

#### Distractor Taxonomy

| Type | Description | Example |
|------|-------------|---------|
| `close_confusion` | Almost correct, missing a nuance | Correct: "Use this skill for X *when Y*" / Distractor: "Use this skill for X" |
| `wrong_domain` | Right idea, wrong skill | Correct: "This skill handles X" / Distractor: "Related skill handles X" |
| `fabricated` | Plausible but not in docs | Correct: "Step 1 is X" / Distractor: "Step 1 is Y" (sounds reasonable) |
| `over_generalized` | Too broad, misses specificity | Correct: "For {specific case}" / Distractor: "For any case" |
| `under_generalized` | Too narrow | Correct: "Works for A, B, C" / Distractor: "Only works for A" |
| `inverted_logic` | Right facts, wrong conclusion | Correct: "Because X, do Y" / Distractor: "Because X, do Z" |

#### Question Categories

**Trigger Precision** — Tests whether the skill knows when it should activate:
```yaml
- id: mc-trigger-001
  question: "A user asks 'Help me optimize my landing page conversion rate.' Which skill fires?"
  options:
    - id: a
      text: "trl-skill-engineer"
      correct: false
      distractor_type: wrong_domain
    - id: b
      text: "trl-user-experience-engineer"
      correct: true
    - id: c
      text: "trl-seo-guru"
      correct: false
      distractor_type: close_confusion
    - id: d
      text: "trl-conversion-engineer"
      correct: false
      distractor_type: close_confusion
  probes: [trigger_discrimination]
```

**Process Knowledge** — Tests whether the skill knows its own methodology:
```yaml
- id: mc-process-001
  question: "In the skill's architecture phase, what should be selected before designing the file tree?"
  options:
    - id: a
      text: "Trigger language"
      correct: false
      distractor_type: inverted_logic
    - id: b
      text: "Skill archetype"
      correct: true
    - id: c
      text: "Quality criteria"
      correct: false
      distractor_type: wrong_domain
    - id: d
      text: "MCP tools"
      correct: false
      distractor_type: fabricated
  probes: [process_order]
```

**Boundary Knowledge** — Tests scope limits:
```yaml
- id: mc-boundary-001
  question: "A user invokes the skill to build a complete web application. What should the skill do?"
  options:
    - id: a
      text: "Build the web application as requested"
      correct: false
      distractor_type: over_generalized
    - id: b
      text: "Explain this is outside scope and suggest appropriate skills"
      correct: true
    - id: c
      text: "Build only the skill-related components"
      correct: false
      distractor_type: under_generalized
    - id: d
      text: "Ask for clarification on what parts relate to the skill's domain"
      correct: false
      distractor_type: close_confusion
  probes: [scope_boundary]
```

**Edge Case Reasoning** — Tests handling of unusual inputs:
```yaml
- id: mc-edge-001
  question: "A user provides a filled skill-brief-worksheet but two requirements contradict each other. What should the skill do?"
  options:
    - id: a
      text: "Pick the first requirement and proceed"
      correct: false
      distractor_type: under_generalized
    - id: b
      text: "Flag the contradiction and ask the user to resolve it"
      correct: true
    - id: c
      text: "Ignore both requirements"
      correct: false
      distractor_type: fabricated
    - id: d
      text: "Proceed with both and let the user see the result"
      correct: false
      distractor_type: over_generalized
  probes: [edge_case, ambiguity_handling]
```

### Essay Questions

Essay questions test application and reasoning. They are scored against expected elements using a weighted rubric.

#### Question Design Principles

1. **Specific scenario, not abstract** — "Given a user who wants X with constraints Y and Z..." beats "Describe how to handle a user request"
2. **Multiple correct approaches** — Essay questions should allow for valid variations, not one exact answer
3. **Scorable elements** — Define concrete things the response should contain
4. **Realistic context** — Use realistic inputs, not toy examples

#### Rubric Design

```yaml
scoring_rubric:
  completeness: 0.40   # Covers all expected_elements
  accuracy: 0.30       # Claims are correct per skill docs
  order: 0.15          # Steps are in logical order
  nuance: 0.15         # Catches non-obvious points
```

Weights should reflect what matters most for the question type:
- **Process questions**: weight `order` higher (0.25)
- **Decision questions**: weight `nuance` higher (0.25)
- **Boundary questions**: weight `accuracy` higher (0.40)

#### Scoring Procedure

For each expected element:
1. Search the response for evidence of the element
2. If found: mark as addressed, check accuracy of the claim
3. If not found: mark as missed
4. `completeness` = elements addressed / total elements
5. `accuracy` = correct claims / total claims made
6. `order` = fraction of steps in correct relative order
7. `nuance` = fraction of non-obvious points captured (0 if no nuance elements exist)

#### Example Essay Questions

**Process Application:**
```yaml
- id: es-process-001
  question: >
    A user wants to create a skill for generating API documentation from OpenAPI specs.
    They've provided: the target audience (junior developers), 3 example use cases,
    and a list of 5 MCP tools they want integrated. Walk through the skill-building
    process from discovery through validation, describing what you'd do at each phase.
  difficulty: hard
  expected_elements:
    - "Analyze domain (API documentation, OpenAPI specs)"
    - "Profile audience (junior developers = need more guidance)"
    - "Map use cases against archetype options"
    - "Select archetype (likely catalog or workflow)"
    - "Design trigger language distinguishing from general writing skills"
    - "Plan MCP tool integration (which tools, how they're used)"
    - "Generate scaffold with file tree"
    - "Write agent playbook"
    - "Create worked examples"
    - "Quality audit against rubric"
  scoring_rubric:
    completeness: 0.40
    accuracy: 0.25
    order: 0.20
    nuance: 0.15
```

**Ambiguity Resolution:**
```yaml
- id: es-ambiguity-001
  question: >
    A user invokes the skill with: 'I need a skill for handling user authentication.'
    This is ambiguous — it could mean: (a) a skill that generates auth code,
    (b) a skill that evaluates auth implementations, or (c) a skill that designs
    auth architectures. How should the skill resolve this ambiguity?
  difficulty: medium
  expected_elements:
    - "Identify that the request is ambiguous"
    - "Enumerate the possible interpretations"
    - "Present assumptions as choices to the user"
    - "Recommend a default path based on context clues"
    - "Explain the trade-offs between interpretations"
  scoring_rubric:
    completeness: 0.35
    accuracy: 0.30
    reasoning_quality: 0.20
    practicality: 0.15
```

## Battery Composition

A full exam battery should cover:

| Category | MC Count | Essay Count | Weight |
|----------|----------|-------------|--------|
| Trigger precision | 4-6 | 0-1 | 15% |
| Process knowledge | 4-6 | 1-2 | 25% |
| Boundary/scope | 3-5 | 1 | 20% |
| Edge case handling | 3-5 | 1-2 | 20% |
| Cross-reference awareness | 2-3 | 0-1 | 10% |
| Self-containment | 2-3 | 0-1 | 10% |

Total: 18-28 MC + 3-7 essay questions per skill.

## Difficulty Distribution

| Level | Fraction | Purpose |
|-------|----------|---------|
| Easy | 30% | Verify basic comprehension |
| Medium | 45% | Test application of knowledge |
| Hard | 20% | Test edge cases and nuance |
| Adversarial | 5% | Test robustness against misleading inputs |

Adversarial questions include: contradictory instructions, scope-stretching requests, inputs designed to trigger the wrong skill, and trick questions with subtle gotchas.
