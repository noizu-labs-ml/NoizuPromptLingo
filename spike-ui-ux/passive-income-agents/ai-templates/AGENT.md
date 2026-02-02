# AI Templates Agent

> Generate ideas, scope requirements, create first drafts, and iterate on AI template products for platforms like Gumroad, Etsy, and Stan Store.

---

## 1. Agent Role & Context

### 1.1 Agent Identity

```yaml
role: AI Template Product Developer
expertise:
  - Prompt engineering for various LLMs
  - Workflow automation
  - Technical documentation
  - Product packaging and pricing
  
target_platforms:
  - Gumroad (primary, quick launch)
  - Etsy (discovery, search traffic)
  - Stan Store (bundles, creator economy)
  - Lemonsqueezy (SaaS-style, subscriptions)

pricing_tiers:
  entry: $17-27      # Simple templates, single use case
  standard: $47-67   # Comprehensive, multiple use cases
  premium: $97-197   # Systems, training included
  enterprise: $297+  # Custom, with support
```

### 1.2 High-Opportunity Niches

Based on market research (278% YoY growth, 73% of sellers aren't AI experts):

| Niche | Competition | Price Point | Your Advantage |
|-------|-------------|-------------|----------------|
| **AI for Creative Pros** | Low | $47-97 | Can code real tools |
| **Small Business Ops** | Low | $97-197 | Automation expertise |
| **Developer Tools** | Medium | $27-67 | Domain authority |
| **Educational Materials** | Low | $47-97 | Technical depth |
| **Content Creation** | High | $17-47 | Differentiate with quality |

---

## 2. Idea Generation Prompts

### 2.1 Niche Exploration

```markdown
## PROMPT: Explore AI Template Niche

I want to explore AI template opportunities in the [NICHE] space.

**Research Parameters:**
- Target audience: [AUDIENCE]
- Their key pain points: [PAIN_POINTS or "identify"]
- Budget level: [entry/standard/premium]
- Existing solutions: [COMPETITORS or "research"]

**Generate:**
1. **5 specific template ideas** with:
   - Product name
   - One-line value proposition
   - Primary use case
   - Estimated price point
   - Differentiation angle

2. **Market opportunity assessment:**
   - Search volume indicators
   - Competition level
   - Growth trajectory
   - Seasonal factors

3. **Quick validation signals:**
   - Where to test demand
   - Minimum viable version
   - Success metrics

**Format as actionable product concepts, not vague ideas.**
```

### 2.2 Problem-First Ideation

```markdown
## PROMPT: Problem-to-Product Ideation

Starting from real problems, generate AI template product ideas.

**Problem Domain:** [DOMAIN]
**Target User:** [USER_TYPE]

**Process:**
1. List 10 specific, painful tasks in this domain
2. For each task, identify:
   - Time typically spent
   - Skill required
   - Current solutions (if any)
   - AI automation potential (1-10)

3. For top 5 automation opportunities, create product concepts:
   - Template name
   - Before/after scenario
   - Core prompts included
   - Bonus materials
   - Price justification

**Prioritize problems where:**
- Manual process takes 30+ minutes
- Requires expertise user doesn't have
- Done repeatedly (weekly/monthly)
- Output has clear business value
```

### 2.3 Competitive Gap Analysis

```markdown
## PROMPT: Find Gaps in Existing Products

Analyze the AI template market for [NICHE] and find underserved opportunities.

**Research:**
1. Search Gumroad for "[NICHE] AI template" - note:
   - Top 10 products by sales/reviews
   - Price points
   - What's included
   - Customer complaints/requests

2. Search Etsy for "[NICHE] ChatGPT prompts" - note:
   - Bestsellers
   - Gaps in offerings
   - Quality issues

3. Check ProductHunt for AI tools in space

**Identify:**
- Features competitors miss
- Quality gaps (poor prompts, no instructions)
- Price gaps (missing tiers)
- Audience gaps (underserved segments)
- Format gaps (video, interactive, etc.)

**Generate 3 product concepts that fill these gaps.**
```

### 2.4 Trend-Based Ideation

```markdown
## PROMPT: Trend-Driven Template Ideas

Research current trends and generate timely AI template products.

**Trend Sources to Check:**
- Google Trends for [KEYWORDS]
- Twitter/X discussions in [NICHE]
- Reddit communities: [SUBREDDITS]
- YouTube trending in category
- ProductHunt launches

**For each identified trend:**
1. Trend description
2. Longevity assessment (fad vs. lasting)
3. Template opportunity
4. Speed to market requirement
5. Product concept

**Prioritize trends that:**
- Have 6+ month runway
- Align with existing skills
- Can launch within 2 weeks
- Have clear buyer intent
```

---

## 3. Scope & Requirements

### 3.1 Product Scoping Template

```markdown
## PROMPT: Scope AI Template Product

Create a complete product scope for: [PRODUCT_IDEA]

**Product Definition:**
- Name: 
- Tagline (max 10 words):
- Target buyer:
- Primary use case:
- Price point:
- Platform:

**Core Deliverables:**
1. **Primary prompts** (list each with purpose)
2. **Supporting materials:**
   - Quick start guide
   - Use case examples
   - Customization instructions
   - Troubleshooting FAQ

3. **Bonus items** (justify each):
   - Why included
   - Perceived value

**Technical Requirements:**
- LLM compatibility (GPT-4, Claude, etc.)
- Input requirements
- Output format
- Edge cases to handle

**Success Criteria:**
- Buyer can use within [X] minutes
- Achieves [OUTCOME] for user
- Minimal support requests
```

### 3.2 Requirements Document

```markdown
## PROMPT: Generate Requirements Document

Create detailed requirements for: [PRODUCT_NAME]

**Functional Requirements:**

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-01 | | Must | |
| FR-02 | | Must | |
| FR-03 | | Should | |
| FR-04 | | Could | |

**Content Requirements:**

| Component | Word Count | Format | Purpose |
|-----------|------------|--------|---------|
| Main prompts | | | |
| Instructions | | | |
| Examples | | | |

**Quality Requirements:**
- Prompt success rate: >90%
- Time to first result: <5 min
- Customization effort: <15 min
- Support documentation: Complete

**Packaging Requirements:**
- File formats
- Naming conventions
- Folder structure
- Delivery method
```

### 3.3 Competitive Positioning

```markdown
## PROMPT: Position Against Competitors

Define positioning for [PRODUCT_NAME] against alternatives.

**Direct Competitors:**
| Competitor | Price | Strengths | Weaknesses |
|------------|-------|-----------|------------|
| | | | |

**Our Differentiation:**
- Primary differentiator:
- Secondary differentiators:
- Proof points:

**Positioning Statement:**
For [TARGET_USER] who [PAIN_POINT],
[PRODUCT_NAME] is a [CATEGORY]
that [KEY_BENEFIT].
Unlike [COMPETITOR],
we [DIFFERENTIATION].

**Messaging Hierarchy:**
1. Headline:
2. Subhead:
3. Key benefits (3):
4. Social proof:
5. CTA:
```

---

## 4. First Draft Creation

### 4.1 Prompt Template Creation

```markdown
## PROMPT: Create Core Prompts

Generate the main prompts for [PRODUCT_NAME].

**For each prompt, provide:**

### Prompt [N]: [Name]

**Purpose:** [What this accomplishes]

**Prompt Text:**
```
[Full prompt with placeholders marked as {{PLACEHOLDER}}]
```

**Variables:**
| Placeholder | Description | Example |
|-------------|-------------|---------|
| {{VAR1}} | | |

**Expected Output:**
[Description of what user should receive]

**Customization Notes:**
- How to modify for different use cases
- What to adjust for different LLMs

**Example Input → Output:**
Input: [Example]
Output: [Example result]

---

**Create prompts for:**
1. [Core use case 1]
2. [Core use case 2]
3. [Core use case 3]
4. [Bonus use case]
```

### 4.2 Documentation Draft

```markdown
## PROMPT: Create Product Documentation

Generate complete documentation for [PRODUCT_NAME].

**Quick Start Guide (1 page):**
- Prerequisites
- 3-step getting started
- First success in 5 minutes
- Where to get help

**Full User Guide:**
1. **Introduction**
   - What's included
   - Who this is for
   - What you'll achieve

2. **Setup**
   - Requirements
   - Recommended tools
   - Configuration

3. **Core Prompts**
   - Prompt 1: [Name]
     - When to use
     - How to use
     - Tips for best results
   - [Repeat for each]

4. **Advanced Usage**
   - Customization guide
   - Combining prompts
   - Integration ideas

5. **Troubleshooting**
   - Common issues
   - FAQ
   - Getting help

**Format:** Clean, scannable, with examples throughout.
```

### 4.3 Sales Page Draft

```markdown
## PROMPT: Create Sales Page Copy

Write sales page copy for [PRODUCT_NAME] at [PRICE_POINT].

**Structure:**

### Above the Fold
- Headline (benefit-focused)
- Subhead (specificity)
- Hero visual description
- Primary CTA

### Problem Section
- Pain point articulation
- Cost of status quo
- Failed alternatives

### Solution Section
- Product introduction
- How it works (3 steps)
- Key features → benefits

### Social Proof
- Testimonial placeholders
- Use case examples
- Results/outcomes

### What's Included
- Full component list
- Value stack
- Bonuses with value

### Pricing
- Price anchoring
- Value justification
- Guarantee

### FAQ
- 5-7 common questions
- Objection handling

### Final CTA
- Urgency (if authentic)
- Risk reversal
- Clear button copy

**Tone:** Confident, specific, no hype.
```

---

## 5. Revision & Iteration

### 5.1 Prompt Testing & Refinement

```markdown
## PROMPT: Test and Refine Prompts

Systematically improve prompts for [PRODUCT_NAME].

**For each prompt, conduct:**

### Test Protocol
1. Run prompt 5x with different inputs
2. Document outputs
3. Rate each output (1-10)
4. Identify failure modes

### Analysis
| Test | Input | Output Quality | Issues |
|------|-------|----------------|--------|
| 1 | | /10 | |
| 2 | | /10 | |
| 3 | | /10 | |
| 4 | | /10 | |
| 5 | | /10 | |

**Average Score:** /10
**Pass Threshold:** 8/10

### Refinement
If score <8:
1. Identify pattern in failures
2. Hypothesize fix
3. Modify prompt
4. Re-test

**Refined Prompt:**
```
[Updated prompt text]
```

**Changelog:**
- [What changed and why]
```

### 5.2 Documentation Review

```markdown
## PROMPT: Review and Improve Documentation

Critique and improve documentation for [PRODUCT_NAME].

**Review Criteria:**

| Criterion | Score (1-10) | Issues | Fixes |
|-----------|--------------|--------|-------|
| Clarity | | | |
| Completeness | | | |
| Scannability | | | |
| Examples | | | |
| Visual aids | | | |
| Accuracy | | | |

**Specific Feedback:**

### Quick Start Guide
- [Feedback]

### Full Guide
- [Feedback by section]

### Troubleshooting
- [Feedback]

**Revised Sections:**
[Provide rewritten sections for anything scoring <8]
```

### 5.3 Sales Copy Optimization

```markdown
## PROMPT: Optimize Sales Copy

Improve conversion potential of sales copy for [PRODUCT_NAME].

**Analysis:**

### Headline Test
Current: "[HEADLINE]"
Score: /10
Issues: [Issues]
Alternatives:
1. [Option]
2. [Option]
3. [Option]

### Value Proposition Clarity
- Is benefit clear in 5 seconds? Y/N
- Is target audience clear? Y/N
- Is differentiation clear? Y/N

### Objection Handling
Missing objections:
- [Objection 1]
- [Objection 2]

### CTA Strength
Current: "[CTA]"
Improvements:
- [Suggestion]

**Revised Copy Sections:**
[Provide optimized versions]
```

---

## 6. Product Categories & Examples

### 6.1 Prompt Packs

**Structure:**
- 10-50 prompts around theme
- Organized by use case
- Quick reference card
- Customization guide

**Example Products:**
- "50 LinkedIn Post Prompts for Developers"
- "Complete Blog Writing Prompt System"
- "Customer Service Response Templates"

**Price Range:** $17-47

### 6.2 Workflow Templates

**Structure:**
- Multi-step process
- Decision trees
- Input/output templates
- Automation instructions

**Example Products:**
- "Content Calendar Creation System"
- "Code Review Automation Workflow"
- "Client Onboarding AI System"

**Price Range:** $47-97

### 6.3 Complete Systems

**Structure:**
- Multiple workflows integrated
- Custom GPT/Assistant instructions
- Video walkthrough
- Templates + prompts + guides

**Example Products:**
- "AI-Powered Business Operations Kit"
- "Complete Freelancer AI Toolkit"
- "SaaS Launch Automation System"

**Price Range:** $97-197

### 6.4 Tools + Templates (Hybrid)

**Structure:**
- Actual code/scripts
- API integrations
- Templates for non-technical use
- Setup guides

**Example Products:**
- "Notion + AI Integration Pack"
- "Automated Report Generator"
- "AI Meeting Assistant Setup Kit"

**Price Range:** $67-297 (SaaS potential)

---

## 7. Launch Checklist

### 7.1 Pre-Launch

```markdown
## Pre-Launch Checklist

**Product Quality:**
- [ ] All prompts tested (>8/10 average)
- [ ] Documentation complete
- [ ] Examples included
- [ ] Troubleshooting covers common issues

**Assets:**
- [ ] Product mockup images
- [ ] Preview/sample content
- [ ] Thumbnail (1200x628)
- [ ] Logo/branding

**Sales Page:**
- [ ] Headline A/B options
- [ ] Full copy written
- [ ] FAQ complete
- [ ] Pricing finalized

**Technical:**
- [ ] Files organized and named
- [ ] Delivery method tested
- [ ] Payment processing verified
- [ ] Email sequence ready
```

### 7.2 Launch Day

```markdown
## Launch Day Checklist

- [ ] Product live on platform
- [ ] Purchase flow tested
- [ ] Sales page live
- [ ] Social announcement posted
- [ ] Email to list (if applicable)
- [ ] Communities notified
- [ ] Analytics tracking verified
```

### 7.3 Post-Launch

```markdown
## Post-Launch (Week 1)

- [ ] Monitor for support requests
- [ ] Collect early feedback
- [ ] Request reviews from buyers
- [ ] Track conversion rate
- [ ] Identify optimization opportunities
- [ ] Plan iteration based on feedback
```

---

## 8. Tracking Integration

### 8.1 Product Entry Template

```markdown
## Product: [NAME]

**Status:** Idea | In Development | Launched | Retired
**Platform:** Gumroad | Etsy | Stan | Other
**URL:** [link]
**Launch Date:** [date]

**Financials:**
- Price: $
- Sales: 
- Revenue: $
- Refunds: 

**Performance:**
- Views: 
- Conversion Rate: %
- Rating: /5

**Notes:**
- [Learnings, feedback, ideas]

**Next Actions:**
- [ ] [Action item]
```

### 8.2 Backlog Entry Template

```markdown
## Idea: [NAME]

**Added:** [date]
**Priority:** High | Medium | Low
**Niche:** [category]
**Estimated Price:** $
**Effort:** [hours/days]

**Concept:**
[Brief description]

**Validation:**
- [ ] Searched competitors
- [ ] Checked demand signals
- [ ] Estimated market size

**Next Step:** [What's needed to move forward]
```

---

## References

- `tracking/ai-templates-tracker.md` - Full product and idea tracker
- `content-marketing.md` - Content to drive template sales
- `print-on-demand.md` - Complementary income stream

---

*Version: 0.1.0*
