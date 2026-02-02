# AI Templates Agent

> Generates ideas, scopes, requirements, drafts, and revisions for AI template products. Focuses on high-margin niches with low competition.

---

## Agent Role Definition

```yaml
role: AI Template Product Developer
persona: |
  You are a product strategist specializing in AI-powered templates and tools.
  You understand both the technical implementation AND the market positioning.
  You focus on solving specific, painful problems for defined audiences.
  You prioritize templates that can command $97-$497 price points.
  
capabilities:
  - Market gap identification
  - Product scoping and requirements
  - Template structure design
  - Prompt engineering for templates
  - Pricing strategy
  - Launch copy and positioning

constraints:
  - Always validate ideas against market demand
  - Avoid saturated niches (generic ChatGPT prompts)
  - Focus on workflow transformation, not novelty
  - Consider implementation complexity vs. price point
```

---

## 1. Idea Generation Prompt

### 1.1 Market Gap Analysis

```markdown
## AI Template Idea Generation

I need you to generate AI template product ideas for the following context:

**Target Market:** [e.g., Indie designers, Small business owners, Developers]
**Problem Space:** [e.g., Client communication, Documentation, Creative workflows]
**My Strengths:** [e.g., Can build APIs, Technical writing, Design background]

### Research These Sources:
1. Gumroad trending in AI/productivity
2. Product Hunt AI tools (look for gaps)
3. Reddit complaints in target subreddits
4. Twitter/X threads about workflow pain points

### For Each Idea, Provide:

**Idea Name:** [Catchy, benefit-focused]

**The Problem:**
- Who has this problem? (specific persona)
- How painful is it? (1-10, with justification)
- How are they solving it now? (current alternatives)
- Why do current solutions fail?

**The Solution:**
- What does the template do?
- What AI capabilities does it leverage?
- What's the transformation? (before → after)

**Market Validation Signals:**
- Search volume indicators
- Competitor analysis (who else, what price, what gaps)
- Community discussions found

**Competitive Moat:**
- Why can't this be easily copied?
- What makes this defensible?

**Price Point Estimate:** $[X] - Justification

**Effort Estimate:** [Hours to MVP]

**Score:** [1-10 overall opportunity rating]

---

Generate 5 ideas ranked by opportunity score.
```

### 1.2 Niche Deep Dive

```markdown
## Niche Deep Dive: [NICHE NAME]

Analyze this niche for AI template opportunities:

**Niche:** [e.g., "AI for freelance copywriters"]

### Market Size
- Estimated audience size
- Willingness to pay (evidence)
- Growth trajectory

### Pain Point Mapping
| Pain Point | Severity | Current Solution | Gap |
|------------|----------|------------------|-----|
| | | | |

### Competitor Landscape
| Product | Price | Strengths | Weaknesses | Reviews |
|---------|-------|-----------|------------|---------|
| | | | | |

### Opportunity Matrix
| Opportunity | Effort | Impact | Priority |
|-------------|--------|--------|----------|
| | | | |

### Recommended Products (3-5)
For each:
- Product concept
- Unique angle
- Price point
- Launch sequence position
```

---

## 2. Product Scoping Prompt

```markdown
## Product Scope: [PRODUCT NAME]

### Overview
**Product:** [Name]
**Tagline:** [One line benefit statement]
**Target Customer:** [Specific persona]
**Price Point:** $[X]
**Platform:** [Gumroad/Stan/Own site]

### Problem Statement
[2-3 sentences describing the specific pain this solves]

### Solution Overview
[2-3 sentences describing what the product does]

### Detailed Requirements

#### Core Features (Must Have)
| Feature | Description | Implementation Notes |
|---------|-------------|---------------------|
| | | |

#### Nice to Have (v1.1)
| Feature | Description | Priority |
|---------|-------------|----------|
| | | |

#### Out of Scope (Future)
- [Feature 1]
- [Feature 2]

### Template Structure

```
[product-name]/
├── README.md                 # Setup instructions
├── quick-start.md            # 5-minute guide
├── templates/
│   ├── [template-1].md       # Core template
│   ├── [template-2].md       # Variation
│   └── examples/
│       ├── example-1.md      # Completed example
│       └── example-2.md      # Another example
├── prompts/
│   ├── system-prompts.md     # System prompts
│   └── user-prompts.md       # User prompt templates
├── workflows/
│   └── workflow-guide.md     # Step-by-step process
└── bonuses/
    └── [bonus-item].md       # Value-add content
```

### User Journey
1. **Purchase:** [What they see, feel]
2. **Onboarding:** [First 5 minutes]
3. **First Win:** [What success looks like]
4. **Ongoing Use:** [How they integrate it]

### Success Metrics
- Primary: [e.g., "User completes first output in <10 min"]
- Secondary: [e.g., "User returns within 7 days"]

### Technical Requirements
- AI model dependencies: [GPT-4, Claude, etc.]
- Integration requirements: [None/API/Zapier]
- User skill level: [Beginner/Intermediate/Advanced]

### Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| | | | |

### Timeline
| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Research | [X days] | Competitor analysis, user interviews |
| Draft | [X days] | First complete version |
| Review | [X days] | Internal testing, refinement |
| Polish | [X days] | Copy, examples, bonuses |
| Launch | [X days] | Platform setup, promotion |

**Total:** [X days/weeks]
```

---

## 3. First Draft Generation Prompt

```markdown
## Generate First Draft: [PRODUCT NAME]

Based on this scope:
[Paste scope document]

### Generate the following:

#### 1. README.md
- Welcome message (warm, confident)
- What's included (bulleted list)
- Quick start (3 steps max)
- Support info
- Legal/usage terms

#### 2. Quick Start Guide
- Step 1: [Setup]
- Step 2: [First use]
- Step 3: [Get result]
- Troubleshooting FAQ

#### 3. Core Templates
For each template:
- Purpose explanation
- When to use
- Template content with [PLACEHOLDERS]
- Example filled-in version
- Tips for best results

#### 4. Prompt Library
For each prompt:
- Prompt name
- Use case
- System prompt (if applicable)
- User prompt template
- Variables to customize
- Example output

#### 5. Workflow Guide
- Overview diagram (ASCII or description)
- Detailed steps
- Decision points
- Common variations
- Time estimates

#### 6. Bonus Content Ideas
- 3 bonus items that add perceived value
- Low effort to create
- High perceived value

### Quality Criteria
- [ ] Beginner-friendly language
- [ ] Specific, not generic
- [ ] Immediately actionable
- [ ] Includes concrete examples
- [ ] Addresses common objections/questions
```

---

## 4. Revision Prompt

```markdown
## Revision Request: [PRODUCT NAME]

### Current Version
[Paste current content]

### Feedback Received
[Paste feedback - user testing, self-review, etc.]

### Revision Type
- [ ] Clarity improvements
- [ ] Add missing content
- [ ] Restructure flow
- [ ] Enhance examples
- [ ] Fix technical issues
- [ ] Polish copy/tone

### Specific Changes Requested
1. [Change 1]
2. [Change 2]
3. [Change 3]

### Constraints
- Maintain: [What should stay the same]
- Avoid: [What not to do]
- Target length: [Word/page count]

### Output
Provide revised version with:
- Changes highlighted or noted
- Rationale for significant changes
- Any suggestions for further improvement
```

---

## 5. Launch Copy Generation

```markdown
## Generate Launch Copy: [PRODUCT NAME]

**Product:** [Name]
**Price:** $[X]
**Platform:** [Gumroad/etc.]
**Target:** [Specific persona]

### Generate:

#### 1. Product Title (3 options)
- Benefit-focused
- Curiosity-inducing
- Include power words

#### 2. Tagline (3 options)
- Under 10 words
- Specific outcome
- For [audience]

#### 3. Product Description
Structure:
- Hook (problem agitation)
- Solution introduction
- What's included (bullet list)
- Who it's for
- Who it's NOT for
- Social proof placeholder
- CTA

#### 4. Feature Bullets (5-7)
Format: [Benefit] - [Feature] - [Outcome]

#### 5. FAQ Section (5-7 questions)
Address:
- Is this for me?
- What do I need to use it?
- How quickly will I see results?
- Refund policy?
- Updates included?

#### 6. Email Sequence (3 emails)
- Email 1: Launch announcement
- Email 2: Case study/results
- Email 3: Last chance + bonus

#### 7. Social Posts (5 variations)
- Twitter thread hook
- LinkedIn post
- Short tweet
- Quote graphic text
- Story/reel script
```

---

## 6. High-Potential Niches (Pre-Researched)

### Tier 1: Underserved, High Demand

| Niche | Pain Point | Price Range | Competition |
|-------|------------|-------------|-------------|
| AI for Creative Professionals | Human-AI collaboration workflows | $97-$197 | Low |
| Small Business Operations | Documentation, SOPs, customer service | $147-$297 | Medium-Low |
| Developer Learning Materials | Code explanation, concept teaching | $47-$97 | Medium |
| Technical Writing Automation | API docs, README generation | $97-$197 | Low |
| Client Communication | Proposals, updates, difficult convos | $47-$97 | Medium |

### Tier 2: Growing Opportunity

| Niche | Pain Point | Price Range | Competition |
|-------|------------|-------------|-------------|
| AI for Solopreneurs | Business planning, market research | $97-$197 | Medium |
| Educational Content Creation | Lesson plans, assessments | $47-$147 | Medium |
| Legal Document Templates | Contracts, policies (non-legal-advice) | $147-$497 | Low |
| Financial Analysis Templates | Forecasting, reporting | $197-$497 | Low |
| Research Synthesis | Literature review, summarization | $47-$97 | Medium |

---

## 7. Product Idea Backlog Template

```markdown
## AI Template Product Backlog

### In Development
| ID | Name | Status | Target Launch | Price |
|----|------|--------|---------------|-------|
| | | | | |

### Validated (Ready to Build)
| ID | Name | Validation Score | Est. Effort | Price |
|----|------|------------------|-------------|-------|
| | | | | |

### Under Consideration
| ID | Name | Problem | Target Audience | Notes |
|----|------|---------|-----------------|-------|
| | | | | |

### Rejected (with reason)
| ID | Name | Rejection Reason | Date |
|----|------|------------------|------|
| | | | |

### Ideas Inbox (Unprocessed)
- [ ] [Idea 1]
- [ ] [Idea 2]
```

---

## 8. Quality Checklist

Before launching any template:

```markdown
## Pre-Launch Checklist: [PRODUCT NAME]

### Content Quality
- [ ] Solves a specific, validated problem
- [ ] Beginner can use within 10 minutes
- [ ] Includes 3+ concrete examples
- [ ] No jargon without explanation
- [ ] Tested with real users (2+ people)

### Technical Quality
- [ ] All prompts tested with target AI
- [ ] No broken links or references
- [ ] File structure is logical
- [ ] Works offline (if applicable)

### Business Quality
- [ ] Price validated against competitors
- [ ] Refund policy clear
- [ ] Support channel established
- [ ] Update policy defined
- [ ] Legal terms included

### Launch Quality
- [ ] Product page copy complete
- [ ] Screenshots/previews ready
- [ ] Email sequence loaded
- [ ] Social posts scheduled
- [ ] Launch day plan defined
```

---

## References

- `PROJECT-TRACKER.md` - Track your template portfolio
- `NICHE-RESEARCH.md` - Market analysis framework
- `../INDEX.md` - Overall strategy

---

*Version: 0.1.0*
