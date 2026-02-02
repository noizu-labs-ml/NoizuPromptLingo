# Design Quality Rubrics

> Objective scoring criteria for evaluating design quality. Use these rubrics during reviews, handoffs, and quality gates.

---

## 1. How to Use Rubrics

### 1.1 Scoring Process

1. **Select appropriate rubric** based on deliverable type
2. **Score each criterion** using the provided scale
3. **Calculate weighted average** for overall score
4. **Document rationale** for each score
5. **Identify improvement areas** for scores below target

### 1.2 Scoring Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 10 | Exceptional | Exceeds all expectations, could be used as reference |
| 9 | Excellent | Meets all criteria with notable quality |
| 8 | Good | Meets criteria with minor room for improvement |
| 7 | Acceptable | Meets minimum standards, some issues |
| 6 | Needs Work | Below standard, requires revision |
| 5 | Poor | Significant issues, major revision needed |
| 1-4 | Unacceptable | Does not meet basic requirements |

### 1.3 Thresholds

| Context | Minimum | Target |
|---------|---------|--------|
| Client delivery | 7.0 | 8.5+ |
| Internal tools | 6.5 | 7.5+ |
| MVP/Prototype | 6.0 | 7.0+ |
| Production launch | 7.5 | 8.5+ |

---

## 2. Visual Design Rubric

### 2.1 Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Visual Hierarchy | 20% | Information importance is clear through size, color, position |
| Consistency | 15% | Elements follow established patterns throughout |
| Typography | 15% | Type choices support readability and hierarchy |
| Color Usage | 15% | Colors serve purpose, maintain contrast, support brand |
| Spacing & Layout | 15% | Whitespace is intentional, alignment is precise |
| Polish & Detail | 10% | Attention to detail, refined execution |
| Brand Alignment | 10% | Design reflects brand identity and guidelines |

### 2.2 Scoring Guide

**Visual Hierarchy (20%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Eye naturally flows to key elements; hierarchy supports user goals perfectly |
| 7-8 | Clear primary/secondary/tertiary levels; minor improvements possible |
| 5-6 | Hierarchy exists but inconsistent; some elements compete for attention |
| 3-4 | Unclear what's important; user must work to find information |
| 1-2 | No discernible hierarchy; chaotic presentation |

**Consistency (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | All elements follow system perfectly; could generate style guide from design |
| 7-8 | Consistent with minor exceptions; patterns are clear |
| 5-6 | Some inconsistencies; mixing of styles or spacing |
| 3-4 | Frequent inconsistencies; appears designed by multiple people |
| 1-2 | No consistency; every element feels different |

**Typography (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Perfect readability; type scale creates clear hierarchy; excellent line lengths |
| 7-8 | Good readability; appropriate choices; minor issues |
| 5-6 | Readable but not optimal; some poor choices |
| 3-4 | Readability issues; poor font choices or sizing |
| 1-2 | Difficult to read; inappropriate fonts; no scale |

**Color Usage (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Colors perfectly support hierarchy and meaning; excellent contrast; brand-aligned |
| 7-8 | Good color usage; proper contrast; minor issues |
| 5-6 | Acceptable colors; some contrast issues; inconsistent application |
| 3-4 | Poor color choices; contrast failures; no clear system |
| 1-2 | Colors harm usability; severe contrast issues |

**Spacing & Layout (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Perfect rhythm; intentional whitespace; pixel-perfect alignment |
| 7-8 | Good spacing; minor alignment issues; clear grid |
| 5-6 | Acceptable spacing; some crowding or excess whitespace |
| 3-4 | Inconsistent spacing; alignment issues; no clear grid |
| 1-2 | Chaotic spacing; misaligned elements; no structure |

**Polish & Detail (10%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Every detail considered; shadows, borders, icons all refined |
| 7-8 | Well-polished with minor rough edges |
| 5-6 | Acceptable but could use more attention |
| 3-4 | Clearly unfinished; many rough elements |
| 1-2 | No attention to detail; draft quality |

**Brand Alignment (10%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Instantly recognizable as brand; extends guidelines thoughtfully |
| 7-8 | Clearly on-brand; follows guidelines |
| 5-6 | Generally on-brand; some inconsistencies |
| 3-4 | Weak brand connection; guidelines not followed |
| 1-2 | Off-brand; could be any company |

### 2.3 Visual Design Score Sheet

```markdown
## Visual Design Evaluation

**Project:** [Name]
**Evaluator:** [Name]
**Date:** [Date]

### Scores

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Visual Hierarchy | 20% | _/10 | _ |
| Consistency | 15% | _/10 | _ |
| Typography | 15% | _/10 | _ |
| Color Usage | 15% | _/10 | _ |
| Spacing & Layout | 15% | _/10 | _ |
| Polish & Detail | 10% | _/10 | _ |
| Brand Alignment | 10% | _/10 | _ |
| **TOTAL** | 100% | | **_/10** |

### Strengths
- [Strength 1]
- [Strength 2]

### Areas for Improvement
- [Area 1] - Impact: High/Medium/Low
- [Area 2] - Impact: High/Medium/Low

### Recommendation
- [ ] Approved
- [ ] Approved with minor revisions
- [ ] Requires revision and re-evaluation
```

---

## 3. UX Design Rubric

### 3.1 Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Task Completion | 25% | Users can accomplish goals efficiently |
| Information Architecture | 20% | Content is organized logically |
| Navigation | 15% | Users can find their way easily |
| Feedback & States | 15% | System communicates status clearly |
| Error Handling | 15% | Errors are prevented, caught, and recoverable |
| Accessibility | 10% | Design works for all users |

### 3.2 Scoring Guide

**Task Completion (25%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Primary tasks require minimal steps; flow is intuitive; no dead ends |
| 7-8 | Tasks completable; minor friction points |
| 5-6 | Tasks possible but require effort; some confusion |
| 3-4 | Difficult to complete tasks; many obstacles |
| 1-2 | Tasks cannot be completed; broken flows |

**Information Architecture (20%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Perfect organization; content where users expect; no redundancy |
| 7-8 | Good organization; minor improvements possible |
| 5-6 | Acceptable structure; some content hard to find |
| 3-4 | Confusing organization; illogical groupings |
| 1-2 | No clear structure; content scattered |

**Navigation (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Always know where you are; easy to get anywhere; consistent patterns |
| 7-8 | Good navigation; minor wayfinding issues |
| 5-6 | Navigable but requires learning; some inconsistency |
| 3-4 | Confusing navigation; easy to get lost |
| 1-2 | Cannot navigate; no clear paths |

**Feedback & States (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | System always communicates status; loading/success/error clear |
| 7-8 | Good feedback; minor gaps |
| 5-6 | Some feedback; missing states |
| 3-4 | Poor feedback; user often unsure of status |
| 1-2 | No feedback; silent failures |

**Error Handling (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Errors prevented; when occur, clear recovery path; helpful messages |
| 7-8 | Good error handling; minor gaps |
| 5-6 | Basic error handling; generic messages |
| 3-4 | Poor error handling; confusing messages |
| 1-2 | Errors crash experience; no recovery |

**Accessibility (10%)**

| Score | Criteria |
|-------|----------|
| 9-10 | WCAG AAA compliance; exceptional inclusive design |
| 7-8 | WCAG AA compliance; good accessibility |
| 5-6 | Basic accessibility; some gaps |
| 3-4 | Significant accessibility issues |
| 1-2 | Inaccessible; excludes users |

### 3.3 UX Design Score Sheet

```markdown
## UX Design Evaluation

**Project:** [Name]
**Evaluator:** [Name]
**Date:** [Date]

### Scores

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Task Completion | 25% | _/10 | _ |
| Information Architecture | 20% | _/10 | _ |
| Navigation | 15% | _/10 | _ |
| Feedback & States | 15% | _/10 | _ |
| Error Handling | 15% | _/10 | _ |
| Accessibility | 10% | _/10 | _ |
| **TOTAL** | 100% | | **_/10** |

### Key User Flows Evaluated
1. [Flow 1] - Score: _/10
2. [Flow 2] - Score: _/10

### Usability Issues Found
| Issue | Severity | Recommendation |
|-------|----------|----------------|
| [Issue] | High/Med/Low | [Fix] |

### Recommendation
- [ ] Approved
- [ ] Approved with minor revisions
- [ ] Requires revision and re-evaluation
```

---

## 4. Landing Page Rubric

### 4.1 Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Value Proposition | 25% | Benefit is clear and compelling |
| Visual Hierarchy | 20% | Eye flows to CTA; key info prominent |
| CTA Clarity | 20% | Action is obvious and compelling |
| Trust & Credibility | 15% | Social proof, professionalism |
| Mobile Experience | 10% | Works well on mobile devices |
| Page Speed | 10% | Loads quickly |

### 4.2 Scoring Guide

**Value Proposition (25%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Immediately clear what it is, who it's for, why it matters |
| 7-8 | Clear value; minor refinement possible |
| 5-6 | Value present but requires effort to understand |
| 3-4 | Unclear value; generic messaging |
| 1-2 | No clear value proposition |

**Visual Hierarchy (20%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Perfect flow: headline → value → CTA; no distractions |
| 7-8 | Good hierarchy; minor distractions |
| 5-6 | Hierarchy exists; some competing elements |
| 3-4 | Unclear hierarchy; eye wanders |
| 1-2 | No hierarchy; chaotic |

**CTA Clarity (20%)**

| Score | Criteria |
|-------|----------|
| 9-10 | CTA unmissable; action clear; low friction |
| 7-8 | Good CTA; minor improvements possible |
| 5-6 | CTA present but not compelling |
| 3-4 | CTA hidden or confusing |
| 1-2 | No clear CTA |

**Trust & Credibility (15%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Strong social proof; professional polish; trustworthy |
| 7-8 | Good credibility signals; minor gaps |
| 5-6 | Some trust elements; could be stronger |
| 3-4 | Weak credibility; raises concerns |
| 1-2 | No trust signals; appears untrustworthy |

**Mobile Experience (10%)**

| Score | Criteria |
|-------|----------|
| 9-10 | Excellent mobile design; easy to convert on phone |
| 7-8 | Good mobile experience; minor issues |
| 5-6 | Functional but not optimized |
| 3-4 | Poor mobile experience; hard to use |
| 1-2 | Broken on mobile |

**Page Speed (10%)**

| Score | Criteria |
|-------|----------|
| 9-10 | LCP <1.5s; instant feel |
| 7-8 | LCP <2.5s; good performance |
| 5-6 | LCP <4s; acceptable |
| 3-4 | LCP >4s; slow |
| 1-2 | Very slow; users will abandon |

### 4.3 Landing Page Score Sheet

```markdown
## Landing Page Evaluation

**URL:** [URL]
**Evaluator:** [Name]
**Date:** [Date]

### Scores

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Value Proposition | 25% | _/10 | _ |
| Visual Hierarchy | 20% | _/10 | _ |
| CTA Clarity | 20% | _/10 | _ |
| Trust & Credibility | 15% | _/10 | _ |
| Mobile Experience | 10% | _/10 | _ |
| Page Speed | 10% | _/10 | _ |
| **TOTAL** | 100% | | **_/10** |

### Conversion Prediction
Based on score, expected CVR range: [X-Y%]
(See conversion-benchmarks.md for calibration)

### Quick Wins (High impact, low effort)
1. [Improvement 1]
2. [Improvement 2]

### Major Issues
1. [Issue 1] - Must fix before launch
```

---

## 5. Component Library Rubric

### 5.1 Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| Completeness | 20% | All necessary components exist |
| Consistency | 20% | Components follow same patterns |
| Documentation | 20% | Usage, props, examples documented |
| Flexibility | 15% | Components adapt to various use cases |
| Accessibility | 15% | Components meet WCAG standards |
| Visual Quality | 10% | Components are well-designed |

### 5.2 Component Library Score Sheet

```markdown
## Component Library Evaluation

**Library:** [Name]
**Evaluator:** [Name]
**Date:** [Date]

### Scores

| Criterion | Weight | Score | Weighted |
|-----------|--------|-------|----------|
| Completeness | 20% | _/10 | _ |
| Consistency | 20% | _/10 | _ |
| Documentation | 20% | _/10 | _ |
| Flexibility | 15% | _/10 | _ |
| Accessibility | 15% | _/10 | _ |
| Visual Quality | 10% | _/10 | _ |
| **TOTAL** | 100% | | **_/10** |

### Components Reviewed
| Component | Complete | Documented | Accessible |
|-----------|----------|------------|------------|
| Button | ✓/✗ | ✓/✗ | ✓/✗ |
| Input | ✓/✗ | ✓/✗ | ✓/✗ |
| Card | ✓/✗ | ✓/✗ | ✓/✗ |

### Missing Components
- [Component 1]
- [Component 2]

### Documentation Gaps
- [Gap 1]
- [Gap 2]
```

---

## 6. Calibration Guidelines

### 6.1 Score Calibration

To ensure consistency across evaluators:

**Reference Examples:**

| Score | Example (Landing Page) |
|-------|------------------------|
| 9-10 | Stripe, Linear, Vercel |
| 7-8 | Most funded startups |
| 5-6 | Average SaaS |
| 3-4 | Template with no customization |
| 1-2 | Broken/abandoned |

### 6.2 Calibration Exercise

Before evaluating, reviewers should:
1. Score 3 reference examples independently
2. Compare scores and discuss differences
3. Align on interpretation of criteria
4. Document calibration decisions

### 6.3 Inter-Rater Reliability

For critical evaluations:
- Use 2+ independent evaluators
- Calculate average scores
- Flag items with >1.5 point difference
- Discuss and resolve discrepancies

---

## 7. Evaluation Templates

### 7.1 Quick Evaluation (5 min)

For rapid assessment:

```markdown
## Quick Eval: [Project]

**Date:** [Date]

| Area | Score (1-10) |
|------|--------------|
| First impression | _ |
| Clarity | _ |
| Usability | _ |
| Polish | _ |
| **Average** | **_** |

**One-line summary:** [Summary]
**Top issue:** [Issue]
```

### 7.2 Comprehensive Evaluation (30 min)

Use full rubric + this summary:

```markdown
## Comprehensive Evaluation: [Project]

**Date:** [Date]
**Evaluator:** [Name]
**Time spent:** [Duration]

### Scores Summary
| Rubric | Score |
|--------|-------|
| Visual Design | _/10 |
| UX Design | _/10 |
| [Other] | _/10 |
| **Overall** | **_/10** |

### Executive Summary
[2-3 sentence summary]

### Top 3 Strengths
1. [Strength]
2. [Strength]
3. [Strength]

### Top 3 Issues
1. [Issue] - Severity: High
2. [Issue] - Severity: Medium
3. [Issue] - Severity: Medium

### Recommendation
[Clear recommendation with rationale]
```

---

## References

- `heuristics.md` - Usability heuristic evaluation
- `automated-checks.md` - Automated quality checks
- `conversion-benchmarks.md` - Conversion rate expectations
- `PROCESS/quality-gates.md` - Where rubrics apply

---

*Version: 0.1.0*
