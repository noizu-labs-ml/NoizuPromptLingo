# npl-marketing-writer - Detailed Documentation

Marketing copy agent for landing pages, product descriptions, press releases, and ad copy using conversion-focused frameworks.

## Overview

The `npl-marketing-writer` agent generates persuasive marketing content that drives customer action. It applies proven copywriting formulas (AIDA, PAS, BAB) to transform product features into customer benefits. The agent operates with tone, length, and funnel-stage parameters to produce content optimized for specific audiences and channels.

**Agent Type**: Service
**NPL Version**: 1.0

---

## Table of Contents

- [Content Types](#content-types)
- [Conversion Frameworks](#conversion-frameworks)
- [Commands Reference](#commands-reference)
- [Parameters](#parameters)
- [Output Templates](#output-templates)
- [Annotation Mode](#annotation-mode)
- [A/B Testing](#ab-testing)
- [Integration Patterns](#integration-patterns)
- [Best Practices](#best-practices)
- [Limitations](#limitations)

---

## Content Types

### Landing Pages

Structure: Hero > Problem > Solution > Social Proof > CTA

**Elements generated:**

| Section | Purpose |
|:--------|:--------|
| Headline | Attention-grabbing value proposition |
| Subhead | Clarifies the offer |
| Problem Statement | Addresses customer pain points |
| Solution | Presents product as the answer |
| Benefits List | 3-5 key advantages |
| Social Proof | Testimonials, logos, stats |
| CTA | Clear call-to-action |

**Example:**

```bash
@marketing-writer landing-page --product="Project Management SaaS" \
    --audience="small business owners" \
    --cta-style=direct
```

### Product Descriptions

Focus: Benefits over features.

Transforms technical specifications into customer-centric language. Emphasizes what the product does for the user rather than what it is.

**Example:**

```bash
@marketing-writer product-desc --item="wireless noise-canceling headphones" \
    --benefits-focus \
    --tone=professional
```

### Press Releases

Format: Standard AP-style press release structure.

| Section | Content |
|:--------|:--------|
| Headline | News-focused, quotable |
| Dateline | Location and date |
| Lead | Who, what, when, where, why |
| Body | Details, quotes, context |
| Boilerplate | Company description |
| Contact | Media contact info |

**Example:**

```bash
@marketing-writer press-release --news="product launch" \
    --angle="industry first" \
    --company="Acme Corp"
```

### Ad Copy

Optimized for specific channels and formats:

| Channel | Constraints |
|:--------|:------------|
| Google Ads | 30 char headlines, 90 char descriptions |
| Facebook | 125 char primary text, 40 char headline |
| LinkedIn | Professional tone, B2B focus |
| Twitter/X | 280 char limit |

**Example:**

```bash
@marketing-writer ad-copy --channel=google \
    --product="email marketing tool" \
    --cta="Start free trial"
```

### Email Campaigns

Structure: Progressive engagement sequences.

| Email Type | Purpose |
|:-----------|:--------|
| Welcome | Introduce, set expectations |
| Nurture | Educate, build trust |
| Promotional | Drive action, create urgency |
| Re-engagement | Win back inactive users |

**Example:**

```bash
@marketing-writer email-sequence --type=nurture \
    --length=5 \
    --product="online course"
```

---

## Conversion Frameworks

### AIDA (Attention-Interest-Desire-Action)

```
Attention: Hook with bold claim or question
Interest: Explain the value proposition
Desire: Paint picture of transformation
Action: Clear CTA with urgency
```

**Best for:** Display ads, landing pages, sales letters.

### PAS (Problem-Agitate-Solution)

```
Problem: Identify the pain point
Agitate: Amplify the consequences
Solution: Present your product as the answer
```

**Best for:** Email marketing, product pages, direct response.

### BAB (Before-After-Bridge)

```
Before: Current state with problems
After: Desired future state
Bridge: Your product connects the two
```

**Best for:** Case studies, testimonials, social media.

### 4Ps (Picture-Promise-Prove-Push)

```
Picture: Create vivid mental image
Promise: State the benefit
Prove: Provide evidence
Push: Ask for action
```

**Best for:** Infomercials, video scripts, long-form sales.

### QUEST (Qualify-Understand-Educate-Stimulate-Transition)

```
Qualify: Identify target audience
Understand: Acknowledge their situation
Educate: Provide valuable information
Stimulate: Create emotional connection
Transition: Guide to next step
```

**Best for:** Complex B2B sales, consultative selling.

---

## Commands Reference

### landing-page

Generate complete landing page copy.

```bash
@marketing-writer landing-page --product=<name> --audience=<target> [options]
```

**Required:**
- `--product`: Product or service name
- `--audience`: Target customer segment

**Options:**
- `--cta-style`: soft, direct, urgent (default: direct)
- `--tone`: playful, professional, bold, friendly, urgent
- `--length`: short, medium, long (default: medium)
- `--framework`: AIDA, PAS, BAB (default: AIDA)

### product-desc

Generate product description copy.

```bash
@marketing-writer product-desc --item=<product> [options]
```

**Required:**
- `--item`: Product name or description

**Options:**
- `--benefits-focus`: Emphasize benefits over features
- `--tone`: Voice and style
- `--length`: Word count target
- `--format`: bullet, paragraph, hybrid

### press-release

Generate press release.

```bash
@marketing-writer press-release --news=<announcement> [options]
```

**Required:**
- `--news`: Core announcement

**Options:**
- `--angle`: News hook or spin
- `--company`: Company name for boilerplate
- `--quote`: Include executive quote
- `--embargo`: Embargo date if applicable

### ad-copy

Generate channel-optimized ad copy.

```bash
@marketing-writer ad-copy --channel=<platform> --product=<name> [options]
```

**Required:**
- `--channel`: google, facebook, linkedin, twitter
- `--product`: Product or service

**Options:**
- `--cta`: Call-to-action text
- `--variants`: Number of variations (default: 1)
- `--tone`: Brand voice

### email-sequence

Generate email campaign copy.

```bash
@marketing-writer email-sequence --type=<sequence-type> [options]
```

**Required:**
- `--type`: welcome, nurture, promotional, re-engagement

**Options:**
- `--length`: Number of emails in sequence
- `--product`: Product focus
- `--interval`: Suggested days between sends

### review

Review and annotate existing marketing copy.

```bash
@marketing-writer review <file> [options]
```

**Options:**
- `--annotate`: Add inline improvement suggestions
- `--goal`: conversion, engagement, awareness
- `--persona`: customer, strategist, competitor

### a/b-test

Generate A/B test variants.

```bash
@marketing-writer a/b-test <file> --element=<target> [options]
```

**Required:**
- `--element`: headline, cta, subject-line, body

**Options:**
- `--variants`: Number of variations (default: 2)
- `--approach`: different-angles, different-tones, different-lengths

---

## Parameters

### Tone

| Value | Description | Use Case |
|:------|:------------|:---------|
| `playful` | Light, fun, energetic | Consumer brands, younger audience |
| `professional` | Polished, credible, formal | B2B, enterprise, finance |
| `bold` | Confident, assertive, direct | Disruptive brands, startups |
| `friendly` | Warm, approachable, conversational | Service businesses, community |
| `urgent` | Time-sensitive, action-oriented | Sales, limited offers |

### Length

| Value | Word Count | Use Case |
|:------|:-----------|:---------|
| `short` | 50-150 | Ads, social, quick scans |
| `medium` | 150-500 | Landing pages, product pages |
| `long` | 500+ | Sales letters, detailed pages |

### CTA Style

| Value | Approach | Example |
|:------|:---------|:--------|
| `soft` | Low pressure | "Learn more" |
| `direct` | Clear action | "Start free trial" |
| `urgent` | Time pressure | "Get 50% off - today only" |

### Funnel Stage

| Stage | Focus | Content Type |
|:------|:------|:-------------|
| `awareness` | Education | Blog posts, social content |
| `consideration` | Comparison | Case studies, feature pages |
| `decision` | Conversion | Landing pages, pricing, demos |
| `advocacy` | Retention | Referral, community content |

---

## Output Templates

### Landing Page Template

```
## Hero
### Headline
[Attention-grabbing value proposition]

### Subhead
[Clarifies the offer in one sentence]

### Hero CTA
[Primary call-to-action button text]

---

## Problem
[2-3 sentences identifying customer pain points]

---

## Solution
[How the product solves the problem]

### Benefits
- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

---

## Social Proof
[Testimonial, statistic, or trust signal]

---

## Final CTA
[Closing call-to-action with urgency element]
```

### Product Description Template

```
## [Product Name]

[Opening hook - benefit-focused one-liner]

### Why You'll Love It
[2-3 sentences on primary value]

### Key Benefits
- [Benefit 1]: [Brief explanation]
- [Benefit 2]: [Brief explanation]
- [Benefit 3]: [Brief explanation]

### Specs
[Technical details if needed]

[Closing statement with CTA]
```

---

## Annotation Mode

Review existing copy with inline improvement suggestions.

### Annotation Syntax

```markdown
[original text] <!-- @marketing: [specific improvement] -->
[weak section] <!-- @marketing: replace with [stronger alternative] -->
[missing element] <!-- @marketing: add [recommended addition] -->
```

### Review Focus Areas

| Goal | Focus |
|:-----|:------|
| `conversion` | CTAs, urgency, objection handling |
| `engagement` | Hooks, readability, emotional triggers |
| `awareness` | Clarity, memorability, shareability |

### Persona-Based Review

| Persona | Perspective |
|:--------|:------------|
| `customer` | Does this solve my problem? |
| `strategist` | Does this align with brand goals? |
| `competitor` | Where are the vulnerabilities? |

---

## A/B Testing

Generate test variants with controlled differences.

### Element Types

| Element | Variations |
|:--------|:-----------|
| `headline` | Different angles, lengths, formats |
| `cta` | Different actions, urgency levels |
| `subject-line` | Different hooks, personalization |
| `body` | Different frameworks, lengths |

### Approach Types

| Approach | Description |
|:---------|:------------|
| `different-angles` | Same message, different perspectives |
| `different-tones` | Same content, different voice |
| `different-lengths` | Same message, varying detail |

### Example

```bash
@marketing-writer a/b-test landing.md --element=headline --variants=3 --approach=different-angles
```

**Output:**

```
## A/B Test Variants - Headline

### Control
"Project Management Made Simple"

### Variant A (Pain-focused)
"Stop Losing Projects to Spreadsheet Chaos"

### Variant B (Outcome-focused)
"Deliver Projects 40% Faster"

### Variant C (Question hook)
"What If Your Team Actually Hit Every Deadline?"
```

---

## Integration Patterns

### Generate and Evaluate

```bash
@marketing-writer landing-page --product=X | @grader --rubric=conversion
```

Generates landing page, then evaluates against conversion best practices.

### Verify Claims Against Specs

```bash
@marketing-writer generate specs.md | @technical-writer --verify-claims
```

Generates marketing copy from specs, then validates technical accuracy.

### Multi-Perspective Review

```bash
@marketing-writer review campaign.md --persona=customer
@marketing-writer review campaign.md --persona=strategist
@marketing-writer review campaign.md --persona=competitor
```

Reviews same content from three different perspectives.

### Content Pipeline

```bash
# Generate product page from technical docs
@gopher summarize docs/product-spec.md | @marketing-writer product-desc --benefits-focus

# Create launch campaign
@marketing-writer press-release --news="v2.0 launch" && \
@marketing-writer email-sequence --type=promotional --length=3 && \
@marketing-writer landing-page --product="v2.0"
```

### Quality Assurance

```bash
# Review for conversion optimization
@marketing-writer review landing.md --goal=conversion --annotate

# Generate variants for testing
@marketing-writer a/b-test landing.md --element=headline --variants=3
@marketing-writer a/b-test landing.md --element=cta --variants=2
```

---

## Best Practices

### Audience Targeting

1. **Be specific**: "small business owners with 5-20 employees" over "businesses"
2. **Know the stage**: Awareness content differs from decision content
3. **Match tone to audience**: B2B professional differs from D2C playful

### Benefit-Focused Writing

1. **Features tell, benefits sell**: "256GB storage" vs "Store 50,000 photos"
2. **Use the "So what?" test**: Keep asking until you reach the real benefit
3. **Quantify when possible**: "Save time" vs "Save 5 hours per week"

### CTA Optimization

1. **Action-oriented verbs**: "Get", "Start", "Discover" over "Submit", "Click"
2. **Value-focused**: "Get my free guide" over "Download now"
3. **Reduce friction**: "Start free trial" over "Sign up for 14-day trial"

### Conversion Frameworks

1. **Match framework to context**: PAS for pain points, BAB for transformations
2. **Dont mix frameworks**: Stick to one per piece
3. **Test alternatives**: Different frameworks resonate with different audiences

### Review Workflow

1. **Start with goal clarity**: Define success metric before review
2. **Use multiple personas**: Different perspectives catch different issues
3. **Prioritize changes**: Focus on high-impact elements first

---

## Limitations

### Content Scope

- Generates copy, not full visual designs
- Does not create graphics, images, or video scripts
- Cannot verify statistical claims without source data

### Accuracy Constraints

- Marketing claims should be verified against product specifications
- Testimonials and social proof require real data input
- Regulatory compliance (e.g., health claims) not validated

### Channel Specifics

- Character limits are applied but platform-specific rules may change
- Does not handle paid ad campaign setup or bidding
- A/B test variants are suggestions; actual testing requires platform tools

### Style Limitations

- Tone parameters are guidelines, not guaranteed voice matching
- Brand voice requires consistent input examples for accuracy
- Industry-specific jargon should be provided in context

---

## Related Documentation

- NPL syntax reference: `npl/syntax.md`
- Agent definition patterns: `npl/agent.md`
- Comparison with `@technical-writer`: different style, opposite approach (marketing vs. technical)
- Core agent definition: `core/agents/npl-marketing-writer.md`
