# NoizuPromptLingo Skills System Index

**Complete navigation and overview of the modular passive income skills system.**

---

## Quick Start

**New to passive income?**
1. Start here: [`monetization-strategy`](#meta-skill-entry-point) - Choose your stream
2. Then: [`market-intelligence`](#core-skill-market-intelligence) - Validate your niche
3. Finally: Stream-specific skill (templates, content, or POD)

**Already know your stream?**
- AI Templates → [`ai-template-developer`](#stream-specific-skills)
- Content Publishing → [`content-publisher`](#stream-specific-skills)
- Print on Demand → [`pod-designer`](#stream-specific-skills)

---

## System Architecture

```
MONETIZATION STRATEGY (Choose your path)
         ↓
    [Choose stream]
         ↓
    ┌─────┴─────┬─────────────┐
    ↓           ↓             ↓
AI TEMPLATES  CONTENT       POD
   ↓           POD           ↓
   ↓      PUBLISHING         ↓
   ↓           ↓             ↓
   └─────┬─────────────┬─────┘
         ↓
    CORE SKILLS (All streams use these)
    ├── market-intelligence (find niche)
    ├── keyword-research (find topics/keywords)
    ├── product-concept-engineer (validate idea)
    ├── conversion-marketing (build landing pages + ads)
    └── conversion-metrics (track performance + economics)
```

---

## Skill Catalog

### Meta-Skill (Entry Point)

#### **monetization-strategy/**
Choose which income stream(s) to pursue

**When to use:**
- You're new to passive income
- Choosing between multiple streams
- Need a personalized roadmap

**Key files:**
- `SKILL.md` - Framework for choosing
- `assessment.prompt.md` - Personal skills assessment
- `stream-comparison.prompt.md` - Compare streams for your situation
- `roadmap-generator.prompt.md` - 90-day + 12-month roadmap

**Time investment:** 1-2 hours
**Outcome:** Decision on which stream + personalized roadmap

**Next:** Choose your stream

---

### Core Skills (Used by All Streams)

These skills are foundational and used regardless of which income stream you choose.

#### **market-intelligence/**
Identify, validate, and score underserved niches

**When to use:**
- Before building anything (validate market first!)
- To choose between multiple ideas
- To find your first profitable niche
- To understand your target audience deeply

**Key files:**
- `SKILL.md` - Complete market research framework
- `niche-discovery.prompt.md` - Generate and discover niches
- `audience-profiling.prompt.md` - Create detailed audience profiles
- `validation-framework.prompt.md` - Validate demand signals
- `competitive-analysis.prompt.md` - Analyze competition and gaps

**Time investment:** 5-10 hours for thorough niche research
**Outcome:** Validated niche with audience profile and competitive analysis

**Dependencies:** None
**Next:** `product-concept-engineer` (validate specific product idea)

---

#### **keyword-research/**
Find high-opportunity keywords and topics (SEO, search intent)

**When to use:**
- Planning content strategy
- Finding article topics with proven search demand
- Identifying underserved keywords
- SEO optimization planning

**Key files:**
- `SKILL.md` - Keyword research methodology
- `search-intent.prompt.md` - Classify search intent (informational, commercial, etc.)
- `long-tail-mining.prompt.md` - Discover long-tail keywords
- `serp-analysis.prompt.md` - Analyze competition for keywords

**Time investment:** 2-4 hours initial research
**Outcome:** List of high-opportunity keywords ranked by potential

**Dependencies:** `market-intelligence` (choose niche first)
**Primary use:** Content Publishing stream
**Next:** Use keywords to plan content strategy

---

#### **product-concept-engineer/**
Generate, validate, and scope product concepts

**When to use:**
- Validating that a specific product idea is viable
- Scoping out what to build before investing time
- Testing multiple product concepts in a niche
- Defining MVP (minimum viable product)

**Key files:**
- `SKILL.md` - Product concept development framework
- `ideation.prompt.md` - Batch generate product concepts
- `validation.prompt.md` - Validate demand signals for concept
- `scoping.prompt.md` - Define scope, requirements, MVP

**Time investment:** 3-5 hours per product concept
**Outcome:** Validated product concept with scope and requirements

**Dependencies:** `market-intelligence` (validated niche), `keyword-research` (if relevant)
**Next:** `conversion-marketing` (build landing page), Stream-specific skill (build product)

---

#### **conversion-marketing/**
Design and optimize landing pages, ad campaigns, and conversion funnels

**When to use:**
- Building a sales page for your product
- Creating ad copy for paid campaigns
- Optimizing conversion rates
- Understanding landing page economics (LTV, CAC)
- Planning conversion funnel

**Key files:**
- `SKILL.md` - Conversion marketing methodology
- `landing-pages.prompt.md` - Create high-converting landing pages
- `ad-campaigns.prompt.md` - Create platform-specific ad campaigns
- `conversion-economics.prompt.md` - Calculate LTV, CAC, payback period
- `ab-testing.prompt.md` - A/B testing and optimization framework

**Time investment:** 4-8 hours for full funnel
**Outcome:** Landing page + ad campaign + economics model

**Dependencies:** `product-concept-engineer` (have validated product)
**Used by:** All streams
**Next:** Implementation + metrics tracking

---

#### **conversion-metrics/**
Track projects with comprehensive metrics, KPIs, and conversion economics

**When to use:**
- Setting up project tracking
- Understanding what to measure for your stream
- Calculating ROI and profitability
- Optimizing funnel performance
- Monthly and weekly reviews

**Key files:**
- `SKILL.md` - Comprehensive metrics framework
- `core-flow.prompt.md` - Universal project lifecycle stages
- `kpi-frameworks.prompt.md` - KPIs by product type
- `conversion-definitions.prompt.md` - What counts as conversion per stream
- `economics-analysis.prompt.md` - LTV, CAC, margin calculations
- `funnel-optimization.prompt.md` - Stage-by-stage improvements
- `product-types/ai-templates-kpis.prompt.md` - AI-specific metrics
- `product-types/content-publishing-kpis.prompt.md` - Content-specific metrics
- `product-types/pod-kpis.prompt.md` - POD-specific metrics

**Time investment:** 1-2 hours setup + 15 min weekly
**Outcome:** Tracking system with universal + stream-specific metrics

**Dependencies:** None (use with any stream)
**Used by:** All streams

---

### Stream-Specific Skills

Choose one based on your income stream preference.

#### **ai-template-developer/**
Build and monetize AI prompt libraries, automation workflows, and templates

**When to use:**
- Building prompt templates, workflow systems, or automation products
- Creating digital products for Gumroad, Stan Store, or own platform
- Packaging technical knowledge as products

**Prerequisites:**
- ✅ `monetization-strategy` (chosen AI Templates)
- ✅ `market-intelligence` (validated niche)
- ✅ `product-concept-engineer` (validated product idea)
- ✅ `conversion-marketing` (have landing page)

**Key files:**
- `SKILL.md` - AI template development methodology
- `prompt-engineering.prompt.md` - Creating effective templates
- `packaging.prompt.md` - Bundling, documentation, delivery
- `pricing.prompt.md` - Pricing strategy and optimization

**Time investment:** 40-60 hours to first product launch
**Revenue potential:** $2,000-5,000/month Year 1
**Best for:** Technical founders with deep niche expertise

**MCP Resources:**
- `mcp://ai-templates/platforms/gumroad` - Gumroad setup and optimization
- `mcp://ai-templates/examples/top-sellers` - Successful product case studies
- `mcp://ai-templates/benchmarks/pricing` - Pricing data by niche

---

#### **content-publisher/**
Build authority and recurring revenue through technical writing, newsletters, and courses

**When to use:**
- Creating content-based revenue (newsletter, articles, courses)
- Building SEO authority in your niche
- Creating free-to-paid conversion funnels
- Growing an engaged audience

**Prerequisites:**
- ✅ `monetization-strategy` (chosen Content Publishing)
- ✅ `keyword-research` (identified high-opportunity topics)
- ✅ `market-intelligence` (understand audience)
- ✅ `conversion-marketing` (setup free→paid funnel)

**Key files:**
- `SKILL.md` - Content publishing methodology
- `article-structure.prompt.md` - Tutorial, analysis, comparison formats
- `newsletter-funnel.prompt.md` - Newsletter strategy and free→paid conversion
- `monetization.prompt.md` - Sponsorships, subscriptions, courses

**Time investment:** 80-120 hours to first monetized newsletter
**Revenue potential:** $2,500+/month Year 1 (long runway)
**Best for:** Writers, teachers, thought leaders

**MCP Resources:**
- `mcp://content-publishing/platforms/substack` - Newsletter setup and monetization
- `mcp://content-publishing/platforms/dev-to` - Dev.to growth strategy
- `mcp://content-publishing/benchmarks/growth` - Subscriber growth metrics

---

#### **pod-designer/**
Design and sell niche merchandise through print-on-demand fulfillment

**When to use:**
- Creating merchandise (t-shirts, hoodies, mugs, stickers, etc.)
- Building community artifacts
- Creating passive income through design
- Testing design ideas at scale

**Prerequisites:**
- ✅ `monetization-strategy` (chosen Print on Demand)
- ✅ `market-intelligence` (validated niche + inside jokes)
- ✅ `product-concept-engineer` (validated designs)

**Key files:**
- `SKILL.md` - POD design methodology
- `design-generation.prompt.md` - AI image prompt patterns and styles
- `product-optimization.prompt.md` - Print specs, mockups, sizing
- `listing-optimization.prompt.md` - Redbubble/Printify listing optimization

**Time investment:** 20-40 hours for first 10 designs
**Revenue potential:** $1,000+/month Year 1 (volume play)
**Best for:** Designers, niche community builders

**MCP Resources:**
- `mcp://pod/platforms/redbubble` - Redbubble setup and optimization
- `mcp://pod/style-library` - Design style templates and references
- `mcp://pod/print-specs` - Technical specs by product type

---

## Decision Tree

```
START: You have an idea for passive income
  │
  ├─ YES: "I know which stream I want"
  │   └─→ Go to Stream-Specific Skill (templates/content/POD)
  │
  └─ NO: "I'm not sure which stream to choose"
      └─→ Start: monetization-strategy/
          │
          ├─ Choose Primary Stream
          │   └─→ Go to Market Intelligence
          │
          └─ Choose Secondary Stream (optional)
              └─→ Plan when to add later
                    ↓
              market-intelligence/
              (Validate your niche)
                    ↓
              product-concept-engineer/
              (Validate your product idea)
                    ↓
              conversion-marketing/
              (Build landing page + ads)
                    ↓
              conversion-metrics/
              (Setup tracking)
                    ↓
              Stream-Specific Skill
              (Build the actual product)
                    ↓
              Launch & Track Performance
              (Use conversion-metrics for ongoing)
```

---

## Typical Workflows

### Template Developer Path (8-12 weeks to revenue)

1. `monetization-strategy` - Confirm AI Templates is right for you
2. `market-intelligence` - Find underserved template niche
3. `product-concept-engineer` - Validate product idea
4. `conversion-marketing` - Create sales page
5. `conversion-metrics` - Setup tracking
6. `ai-template-developer` - Create product
7. Launch on Gumroad
8. Track with `conversion-metrics` ongoing

### Content Publisher Path (12-20 weeks to first paid subscriber)

1. `monetization-strategy` - Confirm Content Publishing is right
2. `keyword-research` - Find high-opportunity topics
3. `market-intelligence` - Understand audience deeply
4. `conversion-marketing` - Plan free→paid funnel
5. `conversion-metrics` - Setup tracking
6. `content-publisher` - Create and publish content
7. Build audience on Dev.to, Medium, own newsletter
8. Monetize Substack subscription at week 12-16
9. Track with `conversion-metrics` ongoing

### POD Designer Path (6-10 weeks to first sale)

1. `monetization-strategy` - Confirm POD is right for you
2. `market-intelligence` - Find niche with strong community
3. `product-concept-engineer` - Generate design concepts
4. `pod-designer` - Create designs at scale
5. `conversion-metrics` - Setup tracking
6. Upload to Redbubble
7. Test and iterate designs
8. Track with `conversion-metrics` ongoing

---

## By Timeline

### Fast Track (4-8 weeks to revenue)
- **Best option:** AI Templates
- Use: `monetization-strategy` → `market-intelligence` → `product-concept-engineer` → `conversion-marketing` → `ai-template-developer`

### Standard Track (8-16 weeks to revenue)
- **Best option:** Mix of templates + POD + content
- Start with Templates or POD, add Content after first revenue

### Slow Build (16+ weeks, higher reward)
- **Best option:** Content Publishing + Templates
- Build audience first (16+ weeks), then monetize

---

## MCP Integration

The skill system integrates with MCP (Model Context Protocol) resources for:

- **Platform guides** - Detailed Gumroad, Substack, Redbubble setup
- **Templates** - Reusable templates for landing pages, product scopes
- **Benchmarks** - Industry conversion rates, pricing data, LTV ranges
- **Examples** - Case studies of successful products in niches

Access via Claude in your session:
```
@mcp platform-guides gumroad setup
@mcp templates landing-page ai-templates
@mcp benchmarks conversion-rates
```

(Full MCP integration documentation in CLAUDE.md)

---

## Skill Quality & Status

| Skill | Status | Last Updated | Version |
|-------|--------|---|---|
| monetization-strategy | Production-ready | 2026-02-02 | 0.1.0 |
| market-intelligence | Production-ready | 2026-02-02 | 0.1.0 |
| keyword-research | In development | TBD | 0.0.1 |
| product-concept-engineer | In development | TBD | 0.0.1 |
| conversion-marketing | In development | TBD | 0.0.1 |
| conversion-metrics | In development | TBD | 0.0.1 |
| ai-template-developer | In development | TBD | 0.0.1 |
| content-publisher | In development | TBD | 0.0.1 |
| pod-designer | In development | TBD | 0.0.1 |

---

## Conventions & Standards

For skill development and usage standards, see [`docs/reference/SKILL-GUIDELINE.md`](../reference/SKILL-GUIDELINE.md)

Key points:
- Each skill has `SKILL.md` + 2-4 `.prompt.md` files
- Prompts are invocable with Claude
- Consistent structure enables skill chaining
- MCP resources supplement skills with detailed platform guides

---

## Getting Help

**Questions about a specific skill?**
- Read the `SKILL.md` file in that skill's directory
- Use the prompts in the `.prompt.md` files
- Reference related skills for context

**Want to contribute or improve?**
- Follow conventions in `docs/references/skills-layout.md`
- Create new skills with same structure
- Reference existing skills to avoid duplication

---

## Next Steps

1. **Start here:** [`monetization-strategy/`](monetization-strategy/) if unsure of direction
2. **Or jump to:** Your stream-specific skill if you know what you want
3. **Track progress:** Use [`conversion-metrics/`](conversion-metrics/) for ongoing tracking
4. **Reference:** This INDEX anytime you need to navigate the system

---

*Last updated: 2026-02-02*
*Current status: Meta + Core skills launched, Stream-specific skills in development*
