# AI Templates - Operational Templates Reference

> Production-ready frameworks for scoping, pricing, launching, and optimizing AI template products. Use alongside `agent-playbook.md` for complete product development workflow.

---

## Table of Contents

- [1. Product Scoping Framework](#1-product-scoping-framework)
  - [1.1 Comprehensive Scope Template](#11-comprehensive-scope-template)
  - [1.2 Product Idea Backlog Template](#12-product-idea-backlog-template)
  - [1.3 First Draft Generation Checklist](#13-first-draft-generation-checklist)
- [2. Pricing Strategies](#2-pricing-strategies)
  - [2.1 First Product Pricing](#21-first-product-pricing)
  - [2.2 Portfolio Pricing](#22-portfolio-pricing)
  - [2.3 Subscription Tier](#23-subscription-tier)
  - [2.4 Bundle Strategy](#24-bundle-strategy)
- [3. Launch Copy Generation](#3-launch-copy-generation)
  - [3.1 Product Title & Tagline](#31-product-title--tagline)
  - [3.2 Product Description](#32-product-description)
  - [3.3 Feature Bullets](#33-feature-bullets)
  - [3.4 FAQ Section](#34-faq-section)
  - [3.5 Email Sequence](#35-email-sequence)
  - [3.6 Social Media Content](#36-social-media-content)
- [4. Pre-Launch Quality Checklist](#4-pre-launch-quality-checklist)
- [5. Listing Optimization](#5-listing-optimization)

---

## 1. Product Scoping Framework

### 1.1 Comprehensive Scope Template

```markdown
## Product Scope: [PRODUCT NAME]

### Overview
**Product:** [Name]
**Tagline:** [One line benefit statement]
**Target Customer:** [Specific persona with 2-3 descriptors]
**Price Point:** $[X]
**Platform:** [Gumroad / Stan / Etsy / Own site]
**Estimated Effort:** [X hours]

### Problem Statement
[2-3 sentences describing the specific pain this solves. Be specific about who suffers and why current solutions fail]

### Solution Overview
[2-3 sentences describing what the product does and the transformation it enables]

---

## Detailed Requirements

### Core Features (Must Have)

| Feature | Description | Implementation Notes |
|---------|-------------|---------------------|
| | | |

### Nice to Have (v1.1+)

| Feature | Description | Priority |
|---------|-------------|----------|
| | | High/Med/Low |

### Out of Scope (Future)
- [Feature 1 - reason]
- [Feature 2 - reason]

---

## Template Structure

```
[product-name]/
├── README.md                 # Setup instructions & overview
├── quick-start.md            # 5-minute getting started guide
├── templates/
│   ├── [template-1].md       # Core template (main deliverable)
│   ├── [template-2].md       # Alternative/variation
│   └── examples/
│       ├── example-1.md      # Completed example
│       └── example-2.md      # Another completed example
├── prompts/
│   ├── system-prompts.md     # System-level prompts for AI
│   └── user-prompts.md       # User-facing prompt templates
├── workflows/
│   └── workflow-guide.md     # Step-by-step process guide
└── bonuses/
    └── [bonus-item].md       # Value-add bonus content
```

---

## User Journey

1. **Purchase:** [What they see, feel, expect]
2. **Onboarding:** [First 5 minutes - quick win setup]
3. **First Win:** [What does success look like?]
4. **Ongoing Use:** [How they integrate it into their workflow]

---

## Technical Requirements

- **AI Model Dependencies:** [GPT-4o, Claude, Mistral, None]
- **Integration Requirements:** [None / API keys / Zapier / Custom setup]
- **User Skill Level:** [Beginner / Intermediate / Advanced]
- **System Requirements:** [Browser only / Desktop / Mobile / etc]

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|---------------------|
| | Low/Med/High | Low/Med/High | |

---

## Project Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Research | [X days] | Competitor analysis, content outline |
| Draft | [X days] | First complete version, templates, prompts |
| Review | [X days] | Internal testing, refinement, examples |
| Polish | [X days] | Copy editing, visual design, bonus content |
| Launch | [X days] | Platform setup, sales page, promotion |

**Total:** [X days/weeks]
```

### 1.2 Product Idea Backlog Template

```markdown
## AI Template Product Backlog

### In Development
| ID | Name | Status | Target Launch | Price | Owner |
|----|------|--------|---------------|-------|-------|
| | | 20% / 50% / 80% | [date] | $[X] | [name] |

### Validated (Ready to Build)
| ID | Name | Validation Score | Est. Effort | Price | Next Action |
|----|------|-------------------|-------------|-------|------------|
| | | [score]/10 | [X hours] | $[X] | [action] |

### Under Consideration
| ID | Name | Problem | Target Audience | Notes | Research Needed |
|----|------|---------|-----------------|-------|-----------------|
| | | | | | |

### Rejected (with reason)
| ID | Name | Rejection Reason | Date | Rationale |
|----|------|------------------|------|-----------|
| | | | | |

### Ideas Inbox (Unprocessed)
- [ ] [Idea 1] - [quick description]
- [ ] [Idea 2] - [quick description]
```

### 1.3 First Draft Generation Checklist

```markdown
## Generate First Draft: [PRODUCT NAME]

### 1. README.md
- **Welcome Message** (warm, confident, benefit-focused)
- **What's Included** (bulleted feature list)
- **Quick Start** (3 steps maximum to first success)
- **How to Use** (main usage instructions)
- **Support Info** (how to get help)
- **Legal/Usage Terms** (licensing, refund policy)

### 2. Core Templates
- [ ] Create the main template with placeholders
- [ ] Create 1-2 variations/alternatives
- [ ] Generate 2+ completed examples
- [ ] Add inline notes explaining sections

### 3. Prompts
**System-level:**
- [ ] Create system prompts for Claude, GPT-4, other AI
- [ ] Include specific instructions for best results
- [ ] Add temperature/parameter recommendations

**User-facing:**
- [ ] Create template prompts users will actually use
- [ ] Add [PLACEHOLDER] sections for user customization
- [ ] Include tips for best results with each prompt

### 4. Examples
- [ ] 2-3 complete worked examples
- [ ] Show before/after transformations
- [ ] Annotate with explanations
- [ ] Make relatable to target audience

### Quality Check
- [ ] All templates are editable (not locked)
- [ ] Examples are realistic and aspirational
- [ ] Prompts are tested with actual AI models
- [ ] No broken references or missing files
```

---

## 2. Pricing Strategies

### 2.1 First Product Pricing
- **Price:** $47 (accessible, validates market)
- **Goal:** 20-50 sales in first month
- **Success signal:** Refund rate < 10%, positive feedback

### 2.2 Portfolio Pricing
- **Price testing:** $27 (volume play), $97 (premium), $197 (high-value)
- **Position:** Premium products for underserved niches
- **Avoid:** Race-to-bottom pricing

### 2.3 Subscription Tier
Launch after 3+ products:
- **Monthly access:** $9-29/month
- **Value:** Early access, bundle discounts, private community
- **Expected:** 5-10% of customer base at $15/month = $100-300/month passive

### 2.4 Bundle Strategy

**When to bundle:**
- 3+ related products in same niche
- Customer feedback requests "everything"
- Need to boost average order value

**Bundle pricing formula:**
- Individual total: Sum of all product prices
- Bundle price: 60-70% of individual total
- Perceived savings: 30-40% off

**Bundle types:**
- **Niche bundle** — All products for one audience (e.g., "Complete Freelancer AI Toolkit")
- **Tier bundle** — Entry + standard + premium for one topic
- **Seasonal bundle** — Time-limited collection at deep discount

---

## 3. Launch Copy Generation

### 3.1 Product Title & Tagline

**Create 3 title options:**

Option A - Benefit-Focused:
- Format: "[Benefit] + [What it is]"
- Example: "AI Proposal Generator for Freelancers"

Option B - Curiosity-Inducing:
- Format: "How [X] achieves [result] using [method]"
- Example: "How to Write Proposals 10x Faster Using AI"

Option C - Power Words:
- Include: Transform, Master, Unlock, Automate, etc.
- Example: "The Ultimate AI Template System for [audience]"

**Tagline requirements:**
- Under 10 words
- Specific outcome, not generic
- For [target audience]

### 3.2 Product Description

Structure (300-500 words):
- **Hook** (problem agitation, why they need this)
- **Solution Introduction** (what you're offering)
- **What's Included** (bulleted feature list, 5-8 items)
- **Who It's For** (specific personas this helps)
- **Who It's NOT For** (be honest about limitations)
- **Social Proof Placeholder** (where testimonials go)
- **CTA** (specific call to action)

### 3.3 Feature Bullets

Format: **[Benefit]** - [Feature] -> [Outcome]

Examples:
- **Save 5+ hours weekly** - Pre-built templates -> Done-for-you starting points
- **Works with any AI** - Platform-agnostic prompts -> Use ChatGPT, Claude, or Gemini

Create 5-7 bullets per product.

### 3.4 FAQ Section

Must address these 7 questions:
1. Is this for me?
2. What do I need to use it?
3. How quickly will I see results?
4. What if I don't like it?
5. Will I get updates?
6. What AI models does this work with?
7. Do I need coding knowledge?

### 3.5 Email Sequence

**Email 1 - The Hook**
- Subject: Curiosity-driven
- Body: Problem + teaser of solution
- CTA: "See what's inside"

**Email 2 - The Body**
- Subject: Benefit-focused
- Body: Detailed benefits, use cases, results
- CTA: "Get it before [deadline]"

**Email 3 - The Close**
- Subject: Urgency or exclusivity
- Body: FOMO, last call, bonus for immediate action
- CTA: Strong CTA button

### 3.6 Social Media Content

**Twitter Thread Hook:**
- Opening tweet: Problem statement (1/X)
- Building tension/solution (2-5/X)
- CTA with link (final/X)

**LinkedIn Post:**
- Professional tone, benefit-focused headline
- 2-3 sentences max
- CTA: "DM for details" or link

**Short Tweet:**
- <280 characters, benefit + product name + link

**Story/Reel Script:**
- 15-30 seconds, hook in first 2 seconds
- Problem -> solution -> CTA with text overlays

---

## 4. Pre-Launch Quality Checklist

16-item checklist organized by category. Use before launching any product.

```markdown
## Pre-Launch Checklist: [PRODUCT NAME]

### Content Quality
- [ ] Solves a specific, validated problem (not vague)
- [ ] Beginner can use it successfully within 10 minutes
- [ ] Includes 3+ concrete, realistic examples
- [ ] Uses clear language (no jargon without explanation)
- [ ] User tested with 2+ real people (get feedback)

### Technical Quality
- [ ] All prompts tested with target AI (average rating 8+/10)
- [ ] No broken links, references, or file paths
- [ ] File structure is logical and easy to navigate
- [ ] Works offline (if applicable) or API requirements are clear

### Business Quality
- [ ] Price point validated against 3+ competitors
- [ ] Refund policy is clear and customer-friendly
- [ ] Support channel established (email, Discord, etc.)
- [ ] Update policy defined (when/how you'll improve it)
- [ ] Legal terms included (licensing, usage rights)

### Launch Quality
- [ ] Product page copy complete and edited
- [ ] Screenshots/mockups ready and professional
- [ ] Email sequence written and loaded
- [ ] Social posts scheduled (launch day + 3-5 days)
- [ ] Launch day plan defined (timing, promotions, monitoring)

---

### Sign-Off
- **Reviewer:** [Your name]
- **Review Date:** [Date]
- **Ready to Launch:** [ ] YES [ ] NO - Issues: [list]
```

---

## 5. Listing Optimization

### Gumroad-Specific Optimization

**Title:** Include primary keyword + benefit (max 80 chars)
**Description:** Front-load value proposition in first 2 lines (visible before "read more")
**Tags:** Use all available tag slots with search-relevant keywords
**Thumbnail:** High-contrast, readable text, show product preview
**Preview:** Include 2-3 sample pages/prompts as free preview

### A/B Testing Framework

Test one variable at a time in this priority order:
1. **Headline** — Biggest impact on click-through
2. **Price** — Test $X vs $X+20 for 2 weeks each
3. **Thumbnail** — Visual appeal drives discovery clicks
4. **Description opening** — First 2 lines determine read-through

**Measurement:**
- Run each variant for minimum 7 days or 100 views
- Track: views, click-through rate, conversion rate, revenue per visitor
- Winner needs >10% improvement to be statistically meaningful
