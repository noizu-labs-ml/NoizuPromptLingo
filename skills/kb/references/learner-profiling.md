# Learner Profiling Reference

Adaptive methodology for understanding who you're building a knowledge base for. The core principle: **accept whatever the user provides, infer the rest, ask only when genuinely ambiguous.**

---

## Profiling Levels

The skill operates at four profiling depths, determined by how much information the user volunteers. The skill never forces a deeper profile than the situation requires.

### Level 1: Minimal

**What you have**: Just the subject.

> "I want to learn calculus."

**Available signals**:
- Subject area (explicit)
- Nothing else

**Inference strategy**:
- Assume general adult learner
- Assume beginner level unless vocabulary suggests otherwise
- Assume broad scope (survey of the domain)
- Assume flexible timeline
- Assume mixed format preferences (reading + practice)

**What to ask** (at most 1-2 questions):
- "What's motivating you to learn this? That'll help me calibrate the depth and focus."
- OR: "Do you have any background in [related field]?"

**What NOT to ask**: Do not ask 5 questions before producing output. Produce a reasonable beginner-oriented plan and invite the user to refine it.

**Default profile output**:
```yaml
subject: "calculus"
current_level: beginner (assumed)
goal: general understanding (assumed)
background: none stated
time_constraints: flexible (assumed)
format_preferences: mixed (assumed)
depth_target: working knowledge (assumed)
confidence: low -- minimal signals, defaults applied
```

### Level 2: Light

**What you have**: Subject + goal or context.

> "I want to learn enough statistics for data science."

**Available signals**:
- Subject area: statistics
- Goal: data science application
- Implicit level: not a complete beginner (knows what data science is)

**Inference strategy**:
- Goal narrows scope: skip pure theoretical statistics, focus on applied
- "Data science" implies some technical background
- Level: low-intermediate (knows basic concepts, needs the statistical toolkit)
- Format: likely prefers practical, code-oriented resources

**What to ask** (optional, 0-1 questions):
- "Are you comfortable with Python/R? That'll affect which resources I recommend."

**Default profile output**:
```yaml
subject: "statistics for data science"
current_level: low-intermediate (inferred from goal context)
goal: applied statistical skills for data science work
background: technical (inferred from "data science")
time_constraints: flexible (assumed)
format_preferences: practical/applied (inferred)
depth_target: working knowledge
confidence: moderate -- goal provides meaningful signal
```

### Level 3: Medium

**What you have**: Subject + goal + background information.

> "I'm a software engineer and I want to understand the math behind machine learning better."

**Available signals**:
- Subject: mathematics for machine learning
- Goal: deeper understanding of ML foundations
- Background: software engineering (programming, basic algorithms, probably some linear algebra)
- Level: intermediate in adjacent domains, beginner-to-intermediate in the target

**Inference strategy**:
- Software engineer can skip: basic programming, intro-level logic, basic statistics
- Software engineer likely knows: variables, functions, basic probability, algorithmic thinking
- Software engineer likely doesn't know: multivariable calculus, advanced linear algebra, optimization theory
- ZPD: the gap between "can code ML libraries" and "can derive the math behind them"
- Format: likely prefers resources that connect math to code

**What to ask** (optional):
- "How much calculus/linear algebra do you remember from school? That'll help me know where to start the math."

**Default profile output**:
```yaml
subject: "mathematics for machine learning"
current_level: intermediate-adjacent (strong in programming, variable in math)
goal: understand mathematical foundations of ML
background: software engineering
adjacent_expertise:
  - programming (strong)
  - basic algorithms (strong)
  - basic statistics (moderate, inferred)
  - linear algebra (unknown -- may need assessment)
  - calculus (unknown -- may need assessment)
time_constraints: flexible (assumed)
format_preferences: math-to-code bridges (inferred)
depth_target: deep understanding
confidence: good -- profession provides strong calibration signal
```

### Level 4: Rich

**What you have**: Detailed brief with constraints, preferences, and deadlines.

> "I have 2 hours per week, prefer video over textbooks, and need to pass the AWS Solutions Architect Professional exam in 3 months. I've been a DevOps engineer for 5 years and already have the Associate cert."

**Available signals**:
- Subject: AWS Solutions Architect Professional
- Goal: pass a specific certification exam
- Background: 5 years DevOps, holds Associate cert
- Time: 2 hours/week, 3-month deadline (~26 hours total)
- Format: prefers video
- Level: advanced practitioner, exam-specific gaps only

**Inference strategy**:
- No inference needed -- the user has provided everything
- Focus: exam-specific gaps between Associate and Professional level
- Time budget is tight: 26 hours to cover delta between Associate and Professional
- Must be ruthlessly efficient -- no "nice to know," only "need to know for the exam"
- Video preference honored: prioritize video courses, supplement with practice exams

**Profile output**:
```yaml
subject: "AWS Solutions Architect Professional certification"
current_level: advanced (holds Associate, 5 years DevOps)
goal: pass Professional exam within 3 months
background: DevOps engineering (5 years), AWS Associate certified
adjacent_expertise:
  - cloud infrastructure (strong)
  - networking (strong, inferred from DevOps)
  - AWS core services (strong, has Associate)
  - advanced AWS architecture patterns (gap -- Professional-level)
  - cost optimization at scale (gap -- Professional-level)
  - migration strategies (gap -- Professional-level)
time_constraints: 2 hours/week, 3-month deadline (26 total hours)
format_preferences: video (stated), practice exams (inferred for cert prep)
depth_target: exam-passing competence (not mastery)
confidence: high -- comprehensive brief provided
```

---

## Question Banks

Organized by category. Use these when you need to probe deeper. **Never ask all of these.** Pick 1-2 from the most relevant category based on what's missing from the user's request.

### Background Questions

| Question | When to Ask | What It Reveals |
|---|---|---|
| "What's your professional background?" | When profession is unstated and would significantly affect resource selection | Adjacent expertise, vocabulary level, time availability |
| "Have you studied [related subject] before?" | When the subject has clear prerequisites that may or may not be met | Starting point for prerequisite mapping |
| "What's your experience with [subject]?" | When the user might not be a complete beginner | Current level calibration |
| "What have you already tried for learning this?" | When the user seems frustrated or is retrying | Failed approaches to avoid, current level signal |

### Goal Questions

| Question | When to Ask | What It Reveals |
|---|---|---|
| "What do you want to be able to do after learning this?" | When the goal is vague ("I want to learn math") | Scope, depth target, backward design anchor |
| "Is this for a specific project, job, or personal interest?" | When motivation is unclear | Urgency, depth, format preferences |
| "What would success look like for you?" | When the user's expected outcome is ambiguous | Measurable milestones, completion criteria |

### Constraint Questions

| Question | When to Ask | What It Reveals |
|---|---|---|
| "How much time can you dedicate to this per week?" | When building a time-bound curriculum | Pacing, resource count limits |
| "Do you have a deadline?" | When the request implies urgency | Prioritization, what to cut |
| "Do you have a budget for resources, or do you prefer free/open-access?" | When recommending paid books or courses | Sourcing constraints |
| "Any format preferences -- books, videos, interactive courses?" | When the default mixed format may not fit | Resource type weighting |

### Preference Questions

| Question | When to Ask | What It Reveals |
|---|---|---|
| "Do you prefer theoretical depth or practical application?" | When the domain allows both approaches | Resource style selection |
| "Do you learn better from structured courses or by exploring?" | When choosing between linear paths and resource collections | Curriculum structure |
| "Are you studying alone or with others?" | When interpersonal resources (study groups, discussions) might help | Resource type inclusion |

---

## Inference Heuristics

When the user doesn't answer questions (or you're trying to avoid asking), use these heuristics to infer profile attributes.

### Level Inference from Vocabulary

| Vocabulary Signal | Inferred Level |
|---|---|
| Uses field-specific jargon correctly | Intermediate or above |
| Uses jargon incorrectly or imprecisely | Beginner who has been exposed but not trained |
| Uses plain language to describe technical concepts | Beginner or adjacent expert |
| Asks "what is X?" questions | Beginner |
| Asks "why does X work this way?" questions | Intermediate |
| Asks "how does X compare to Y?" questions | Advanced |
| Asks "what are the limitations of X?" questions | Expert-level thinking |

### Level Inference from Question Type

| Question Pattern | Inferred Level | Reasoning |
|---|---|---|
| "I want to learn X" (broad) | Beginner | No specification implies unfamiliarity |
| "I want to understand X better" | Intermediate | "Better" implies existing knowledge |
| "I want to learn X for Y" (specific application) | Intermediate | Application awareness implies context |
| "I need to learn [specific subtopic]" | Intermediate-Advanced | Subtopic awareness implies domain familiarity |
| "What's the best approach for [complex scenario]?" | Advanced | Scenario framing implies experience |

### Level Inference from Stated Goals

| Goal Pattern | Inferred Level and Scope |
|---|---|
| "Get into [field]" | Beginner, broad scope, career-oriented |
| "Understand [concept]" | Beginner-Intermediate, focused scope |
| "Get better at [skill]" | Intermediate, practice-oriented |
| "Pass [exam/certification]" | Variable level, exam-scoped, deadline-driven |
| "Build [specific thing]" | Intermediate-Advanced, project-scoped |
| "Teach [subject] to others" | Advanced, comprehensive scope |
| "Contribute to [research area]" | Expert, cutting-edge scope |

---

## Adjacent Expertise Detection

One of the most valuable profiling signals is what the learner already knows from related fields. Adjacent expertise allows the curriculum to skip foundations and bridge from known to unknown.

### Common Adjacency Maps

| Learner's Background | Learning... | Can Skip | Should Emphasize |
|---|---|---|---|
| Software Engineer | Mathematics | Basic logic, functions, variables, algorithmic thinking | Pure math notation, proofs, abstract reasoning |
| Software Engineer | Data Science | Programming, basic data structures, CSV/JSON handling | Statistics theory, experimental design, domain knowledge |
| Mathematician | Programming | Logic, algorithms (conceptual), discrete math | Syntax, tooling, debugging, software engineering practices |
| Writer | Marketing | Persuasive writing, audience awareness, storytelling | Analytics, funnel optimization, A/B testing, technical platforms |
| Designer | Frontend Development | Visual hierarchy, color theory, layout principles, user empathy | HTML/CSS syntax, JavaScript, build tools, accessibility standards |
| Musician | Audio Engineering | Pitch, rhythm, harmony theory, ear training | Signal processing, DAW operation, mixing technique, acoustics physics |
| Nurse | Medical Research | Anatomy, pharmacology basics, patient care context | Statistics, study design, literature review, research ethics |
| Physicist | Machine Learning | Linear algebra, calculus, probability, optimization | Programming frameworks, data pipeline engineering, model deployment |

### Leveraging Adjacency

When adjacent expertise is detected:

1. **Acknowledge it explicitly**: "Since you already know X, we can skip [foundations] and start with [bridge topic]."
2. **Bridge from known to unknown**: Select resources that connect the learner's existing knowledge to the new domain. A programmer learning math benefits from "Mathematics for Computer Science" more than a pure math textbook.
3. **Flag false friends**: Concepts that look similar across domains but behave differently. A programmer's "function" is not a mathematician's "function" in all respects.
4. **Accelerate the early phases**: The curriculum can move faster through material the learner partially knows.

---

## Constraint Detection

### Time Constraints

| Signal | Time Model |
|---|---|
| No mention of time | Flexible -- design for thoroughness |
| "Quick" / "brief" / "overview" | Hours, not weeks -- use Workflow 5 (Quick Orientation) |
| "I have N hours per week" | Explicit -- pace the curriculum accordingly |
| "I need this by [date]" | Deadline-driven -- calculate total hours, cut non-essential topics |
| "In my spare time" | Low commitment (~2-5 hrs/week), long timeline -- keep phases short |

### Budget Constraints

| Signal | Resource Strategy |
|---|---|
| No mention of budget | Mix free and paid, note sourcing for each |
| "Free resources only" | Open-access textbooks, MIT OCW, YouTube lectures, arXiv papers |
| "Money isn't an issue" | Premium courses, latest editions, paid platforms |
| "Library access" | Books (checkable), JSTOR/academic databases |

### Format Constraints

| Signal | Resource Weighting |
|---|---|
| "I prefer reading" | Heavy on books and articles |
| "I prefer video" | Heavy on video courses and lectures |
| "I learn by doing" | Heavy on exercises, projects, labs |
| "I have a long commute" | Audio-friendly: podcasts, audiobooks, lecture recordings |
| "I need accessibility" (visual impairment, etc.) | Screen-reader-friendly text, audio resources, avoid image-heavy materials |

---

## Profile Schema

The structured format that downstream sub-skills consume. The orchestrator produces this and passes it to trl-kb-research, trl-kb-curriculum, and trl-kb-digest.

```yaml
learner_profile:
  # Core identity
  subject: string                    # What they want to learn
  current_level: enum                # beginner | low-intermediate | intermediate | advanced | expert
  goal: string                       # What they want to achieve
  depth_target: enum                 # survey | working-knowledge | deep-expertise | mastery

  # Background
  background: string                 # Professional/educational background
  adjacent_expertise:                # What they already know from related fields
    - domain: string
      level: enum                    # weak | moderate | strong
  prior_attempts: string[]           # What they've already tried (if stated)

  # Constraints
  time_per_week: string              # Hours per week, or "flexible"
  deadline: string                   # Target date, or "none"
  total_budget_hours: number         # Calculated from time_per_week and deadline, or null
  budget: enum                       # free-only | library | mixed | unlimited
  accessibility_needs: string[]      # Any stated accessibility requirements

  # Preferences
  format_preferences:                # Ranked list of preferred formats
    - enum                           # book | video | interactive | audio | project | exercises
  learning_style: enum               # structured | exploratory | mixed
  solo_or_group: enum                # solo | group | mixed

  # Meta
  confidence: enum                   # low | moderate | good | high
  confidence_notes: string           # What was inferred vs. stated
  open_questions: string[]           # Unresolved ambiguities to flag in output
```

### Confidence Levels

| Level | Meaning | Action |
|---|---|---|
| **High** | User provided a detailed brief; minimal inference needed | Proceed with full confidence |
| **Good** | Key attributes stated, some reasonable inferences | Proceed, note inferences in output |
| **Moderate** | Goal provides signal, but background is inferred | Proceed with caveats; invite refinement |
| **Low** | Minimal info; heavy defaults applied | Produce output but explicitly flag assumptions; invite the user to refine |

### Passing the Profile to Sub-Skills

When dispatching to sub-skills, include a condensed profile summary:

```markdown
**Learner Profile Summary**:
- Subject: [subject]
- Level: [current_level] ([confidence] confidence)
- Goal: [goal]
- Background: [background] | Adjacent: [list adjacencies]
- Constraints: [time] / [budget] / [format preferences]
- Depth: [depth_target]
```

Sub-skills use this to calibrate their output without needing the full YAML schema.
