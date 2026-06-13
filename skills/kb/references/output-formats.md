# Output Formats Reference

Detailed specifications for every artifact the `trl-kb` skill produces. Each format is designed for both human reading and downstream tool consumption (trl-content-publishing pipelines, interactive tutors, progress tracking systems).

---

## Learning Plan

A phased roadmap that sequences the learner's journey from their current state to their goal. This is the primary output of the `trl-kb` skill for "I want to learn X" requests.

### Structure

```markdown
# Learning Plan: [Subject]

**Learner**: [Brief profile summary]
**Goal**: [What the learner will be able to do]
**Estimated Duration**: [Total time across all phases]
**Depth**: [Survey | Working Knowledge | Deep Expertise | Mastery]

---

## Phase 1: [Phase Name]
**Duration**: [Time estimate]
**Objective**: After this phase, you will be able to [Bloom's-verb] [specific outcome].

### Topics
1. [Topic A] — [Brief description]
2. [Topic B] — [Brief description]

### Resources
- [Resource Title] by [Author] — [Time estimate] — [Difficulty]
  - Focus on: [Specific chapters, sections, or exercises]
- [Resource Title] — [Time estimate] — [Difficulty]
  - Focus on: [Specific parts]

### Milestone Check
- [ ] Can you [specific task demonstrating the objective]?
- [ ] Can you [second verification task]?

### If You're Struggling
- [Fallback resource or alternative approach]
- [Prerequisite to review]

---

## Phase 2: [Phase Name]
**Duration**: [Time estimate]
**Prerequisites**: Completion of Phase 1
**Objective**: After this phase, you will be able to [Bloom's-verb] [specific outcome].

[Same structure as Phase 1]

---

## Phase N: [Final Phase Name]
[Same structure]

---

## Summary Timeline

| Phase | Duration | Key Outcome |
|---|---|---|
| Phase 1: [Name] | [Time] | [Outcome] |
| Phase 2: [Name] | [Time] | [Outcome] |
| ... | ... | ... |
| **Total** | **[Sum]** | **[Final outcome]** |
```

### Field Specifications

| Field | Required | Description |
|---|---|---|
| Phase Name | Yes | Human-readable label (e.g., "Foundations", "Core Techniques", "Advanced Applications") |
| Duration | Yes | Time estimate in hours or weeks |
| Objective | Yes | Uses Bloom's Taxonomy verbs: remember, understand, apply, analyze, evaluate, create |
| Topics | Yes | Numbered list of topics covered in this phase |
| Resources | Yes | Referenced from the annotated bibliography with specific focus instructions |
| Milestone Check | Yes | 2-3 concrete, verifiable tasks the learner can attempt |
| If You're Struggling | Recommended | Fallback resources, prerequisites to review, or alternative explanations |
| Prerequisites | When applicable | Which prior phases must be completed first |

### Example Entry

```markdown
## Phase 2: Single Variable Calculus
**Duration**: 40-60 hours (4-6 weeks at 10 hrs/week)
**Prerequisites**: Completion of Phase 1 (Pre-Calculus Review)
**Objective**: After this phase, you will be able to *apply* differentiation
and integration techniques to solve standard calculus problems and *explain*
their geometric interpretation.

### Topics
1. Limits and continuity — Intuitive and epsilon-delta definitions
2. Derivatives — Definition, rules (power, chain, product, quotient)
3. Applications of derivatives — Optimization, related rates, curve sketching
4. Integrals — Definite and indefinite, Fundamental Theorem of Calculus
5. Integration techniques — Substitution, integration by parts

### Resources
- *Calculus: Early Transcendentals* by James Stewart — 30-40 hours — Intermediate
  - Focus on: Chapters 2-7. Work at least half the odd-numbered exercises.
- MIT OCW 18.01 Single Variable Calculus — 15-20 hours — Intermediate
  - Focus on: Video lectures + problem sets for topics where the textbook is unclear.

### Milestone Check
- [ ] Can you differentiate polynomial, exponential, and trigonometric functions?
- [ ] Can you set up and solve a basic optimization problem?
- [ ] Can you compute a definite integral using the Fundamental Theorem?

### If You're Struggling
- Review *Pre-Calculus* by Stewart, Redlin, Watson (Phase 1 resource) — especially Chapter 2 (Functions)
- 3Blue1Brown's "Essence of Calculus" video series — visual intuition for limits and derivatives
```

---

## Annotated Bibliography

A curated, sequenced list of resources with metadata for each entry. Every book must include an ISBN or an explicit confidence marker.

### Resource Entry Format

```markdown
### [Resource Title]
- **Type**: Book | Article | Paper | Video Course | Interactive Course | Podcast | PDF | Open Courseware
- **Author(s)**: [Name(s)]
- **ISBN/URL**: [ISBN-13 or direct URL]
- **Confidence**: [Verified] | [High confidence] | [Moderate] | [Unverified]
- **Publisher/Platform**: [Publisher name or platform]
- **Edition/Date**: [Edition number or publication year]
- **Difficulty**: Beginner | Intermediate | Advanced | Expert
- **Time Estimate**: [Hours to complete, with basis for estimate]
- **Synopsis**: [2-3 sentences: what it covers, what makes it distinctive, why it's included]
- **Prerequisites**: [What the learner should know before starting this resource]
- **Sourcing**: [Where to obtain: purchase, library, open access URL, subscription]
- **Notes**: [Optional: specific chapters to focus on, known issues, complementary resources]
```

### Confidence Markers

| Marker | Meaning | When to Use |
|---|---|---|
| **[Verified]** | ISBN/URL confirmed via search, details checked | After WebSearch confirms the resource exists with matching details |
| **[High confidence]** | Well-known resource, details consistent with training data | Standard textbooks, major MOOCs, widely-cited papers |
| **[Moderate]** | Resource exists but some details (edition, ISBN) may be imprecise | Less common resources, recent publications, niche materials |
| **[Unverified]** | Could not confirm details; included because it's likely correct | Specific ISBNs not verified, resources known only by reputation |

**Rule**: Never fabricate an ISBN. If you're unsure of the exact ISBN, either search for it or mark the entry [Unverified] with a note explaining what you couldn't confirm.

### Example Entry

```markdown
### Calculus: Early Transcendentals
- **Type**: Book
- **Author(s)**: James Stewart
- **ISBN/URL**: 978-1-337-61392-7 [High confidence]
- **Publisher/Platform**: Cengage Learning
- **Edition/Date**: 9th Edition, 2020
- **Difficulty**: Intermediate
- **Time Estimate**: 80-120 hours for full coverage; 40-60 hours for Chapters 1-12
- **Synopsis**: The standard university calculus textbook used across hundreds of
  institutions. Emphasizes conceptual understanding alongside computational
  technique. Strong problem sets with answers to odd-numbered exercises. The
  "Early Transcendentals" version introduces exponential and logarithmic functions
  earlier than the standard edition, which is preferred for applied paths.
- **Prerequisites**: Pre-calculus (functions, trigonometry, basic algebra)
- **Sourcing**: Purchase new/used (~$80-250), widely available in university libraries,
  older editions are significantly cheaper and nearly equivalent for self-study
- **Notes**: Pair with MIT OCW 18.01 lectures for video reinforcement. The 8th edition
  (978-1-285-74155-0) is substantially similar and available used for ~$20.
```

### Bibliography Organization

Bibliographies should be organized in one of two ways:

**By learning path phase** (when accompanying a learning plan):
```markdown
## Phase 1: Foundations
### [Resource 1]
### [Resource 2]

## Phase 2: Core Skills
### [Resource 3]
### [Resource 4]
```

**By resource type** (when standalone):
```markdown
## Books
### [Book 1]
### [Book 2]

## Video Courses
### [Course 1]

## Articles and Papers
### [Article 1]

## Open-Access Resources
### [Resource 1]
```

---

## Research Digest

A synthesis of knowledge about a topic, calibrated to a specific complexity level. Not a bibliography -- a digest explains and connects ideas.

### Structure

```markdown
# [Topic]: [Complexity Level] Digest

**Target Audience**: [Who this is written for]
**Complexity**: [ELI5 | Beginner | Intermediate | Advanced | Expert | Thesis-level]
**Word Count**: [Approximate]

---

## What It Is
[Core definition and framing — what is this topic and why does it matter?]

## Key Concepts
[The essential ideas, explained at the target complexity level]

### [Concept 1]
[Explanation]

### [Concept 2]
[Explanation]

## How It Works
[Mechanisms, processes, or methods — the "how" behind the "what"]

## Current State of the Field
[Where things stand now — recent developments, active research, open problems]

## Consensus and Contested Points

### What Experts Agree On
- [Point 1]
- [Point 2]

### What's Debated
- [Contested point 1] — [Brief summary of the debate]
- [Contested point 2]

### Known Gaps
- [Gap 1] — [Why this matters]
- [Gap 2]

## Practical Implications
[What this means for practitioners, if applicable]

## Sources
[Citations for claims made in the digest]
```

### Complexity Level Calibration

| Level | Vocabulary | Assumed Knowledge | Sentence Structure | Analogies |
|---|---|---|---|---|
| **ELI5** | Everyday words only | None | Short, simple | Required for every concept |
| **Beginner** | Introduce technical terms with definitions | General literacy | Clear, direct | Frequent |
| **Intermediate** | Use technical terms freely | Foundational domain knowledge | Standard academic | When helpful |
| **Advanced** | Full technical vocabulary | Solid domain knowledge | Complex, precise | Rare — precision over accessibility |
| **Expert** | Specialist terminology | Deep domain expertise | Dense, referential | Only for cross-domain bridges |
| **Thesis-level** | Research vocabulary | Research methodology, literature familiarity | Academic, citation-heavy | Absent |

### Example: Same Topic at Two Levels

**ELI5 — What is a neural network?**
> Imagine you have a bunch of tiny decision-makers connected by strings. You show them a picture of a cat. The first row of decision-makers notices simple things: edges, colors, bright spots. They tug on their strings to tell the next row. The next row combines those simple things into shapes: pointy ears, round eyes. The last row puts it all together and says "cat!" When it's wrong, you go back and adjust the strings so it does better next time. That's a neural network: layers of simple decision-makers that learn by having their connections adjusted.

**Advanced — What is a neural network?**
> A neural network is a parameterized function f(x; theta) composed of alternating linear transformations and nonlinear activation functions, organized in layers. Each layer computes z = sigma(Wx + b), where W is a weight matrix, b is a bias vector, and sigma is a nonlinearity (ReLU, sigmoid, tanh, etc.). Training minimizes a loss function L(f(x; theta), y) over a dataset {(x_i, y_i)} via gradient descent on theta, with gradients computed efficiently through backpropagation — an application of the chain rule to the computation graph. The universal approximation theorem (Cybenko 1989, Hornik 1991) guarantees that a sufficiently wide single-hidden-layer network can approximate any continuous function on a compact domain, though practical expressivity depends on depth, architecture, and regularization.

---

## Publishable Article

A general-audience version suitable for the trl-content-publishing pipeline. This transforms a learning plan or digest into something shareable.

### Structure

```markdown
# [Engaging Title — Not Academic]

*[Subtitle or hook — one sentence that makes the reader care]*

---

[Opening paragraph — establish the problem or curiosity. Why should anyone care about this topic?]

## [Section 1: Context/Background]
[Set the stage. What does the reader need to know before diving in?]

## [Section 2-N: Core Content]
[The substance. Adapted from the digest or learning plan, but written for engagement, not reference.]

## [Practical Section: What to Do With This]
[Actionable takeaways. If from a learning plan: "Here's how to get started." If from a digest: "Here's what this means for you."]

## [Closing: Where to Go Next]
[Resources, next steps, invitation to go deeper.]

---

*[Author note / credential line]*
```

### Tone Guidelines

| Register | When to Use | Example |
|---|---|---|
| **Conversational expert** | General tech audience, blog posts | "Here's the thing about calculus that nobody tells you in school..." |
| **Professional informative** | Industry audience, newsletter content | "Organizations adopting ML face a foundational skills gap. Here's how to address it." |
| **Academic accessible** | Education audience, course marketing | "This learning path applies established pedagogical frameworks to self-directed study." |

### Adaptation Rules

When converting a digest to a publishable article:
1. Remove all internal references (confidence markers, profile metadata)
2. Replace technical scaffolding ("Consensus and Contested Points") with narrative flow
3. Add an engaging opening that establishes stakes
4. Ensure every section earns its place — cut anything the general reader wouldn't care about
5. Add a "What to Do Next" section with 3-5 concrete actions

---

## Progress Tracker

A checklist format derived from the learning plan phases. Designed for the learner to print, bookmark, or track in a task manager.

### Structure

```markdown
# Progress Tracker: [Subject]

**Started**: [Date]
**Target Completion**: [Date or "flexible"]
**Current Phase**: [Phase name]

---

## Phase 1: [Phase Name]
**Target**: [Duration estimate]
**Status**: [ ] Not Started | [ ] In Progress | [ ] Complete

### Resources
- [ ] [Resource 1] — [Focus area]
  - [ ] [Specific section/chapter 1]
  - [ ] [Specific section/chapter 2]
- [ ] [Resource 2] — [Focus area]

### Milestones
- [ ] [Milestone 1]: [Verification task]
- [ ] [Milestone 2]: [Verification task]

### Self-Assessment
> After completing this phase, rate your confidence (1-5):
> - [ ] I can [objective verb] [topic]: ___/5
> - [ ] I feel ready for Phase 2: ___/5

---

## Phase 2: [Phase Name]
[Same structure]

---

## Completion Summary
- [ ] All phases complete
- [ ] Final self-assessment:
  - Original goal: [goal]
  - Achieved: [learner fills in]
  - Confidence level: ___/5
  - Next steps: [learner fills in]
```

### Design Principles

1. **Checkboxes everywhere** -- Every actionable item gets a checkbox
2. **Granular sub-tasks** -- Break "read this book" into chapter-level tasks
3. **Self-assessment prompts** -- Not just "did you finish?" but "how confident are you?"
4. **Phase gating** -- Each phase has milestones that should be met before moving on
5. **Flexible dates** -- Include date fields but don't require them

---

## Difficulty Map

A visual or tabular representation of how difficulty progresses across the learning path. Useful for setting expectations and identifying potential difficulty spikes.

### Tabular Format

```markdown
# Difficulty Map: [Subject]

| Phase | Topic | Difficulty | Cognitive Level | Time | Cumulative Hours |
|---|---|---|---|---|---|
| 1 | [Topic A] | Beginner | Remember/Understand | 5h | 5h |
| 1 | [Topic B] | Beginner | Understand | 8h | 13h |
| 2 | [Topic C] | Intermediate | Apply | 12h | 25h |
| 2 | [Topic D] | Intermediate | Apply/Analyze | 15h | 40h |
| 3 | [Topic E] | Advanced | Analyze | 20h | 60h |
| 3 | [Topic F] | Advanced | Evaluate | 10h | 70h |
| 4 | [Topic G] | Expert | Create | 30h | 100h |
```

### Notation

```markdown
## Difficulty Progression

Phase 1 (Beginner):     ██░░░░░░░░  Topics: A, B
Phase 2 (Intermediate): ████░░░░░░  Topics: C, D
Phase 3 (Advanced):     ███████░░░  Topics: E, F
Phase 4 (Expert):       ██████████  Topics: G

Difficulty Spikes:
- Topic D → E: Significant jump. Consider extra time or supplementary resources.
- Topic F → G: Requires synthesis of all prior topics. Allow buffer time.
```

### Design Principles

1. **Set expectations early** -- The learner should see the full difficulty curve before starting
2. **Flag spikes** -- When difficulty jumps significantly between adjacent topics, note it and recommend mitigation (extra time, review, supplementary resources)
3. **Cumulative time** -- Always include running total so the learner can estimate where they'll be at any given point
4. **Cognitive level annotation** -- Map each topic to its Bloom's level so the progression is explicit

---

## Format Selection Guide

Which formats to produce based on the workflow:

| Workflow | Learning Plan | Bibliography | Digest | Article | Tracker | Difficulty Map |
|---|---|---|---|---|---|---|
| Full Knowledge Base | Yes | Yes | Optional | No | Yes | Optional |
| Research Only | No | Yes | No | No | No | No |
| Curriculum Only | Yes | Yes (subset) | No | No | Yes | Optional |
| Digest Only | No | Optional | Yes | No | No | No |
| Quick Orientation | No | Yes (brief) | Yes (brief) | No | No | No |
| Publishable Output | Optional | Optional | Optional | Yes | No | No |
