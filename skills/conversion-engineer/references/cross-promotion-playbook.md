# Cross-Promotion Playbook

> Concrete tactics for promoting between AI Templates, Content Publishing, and Print on Demand. The trl-conversion-engineer's core operational manual: when to cross-promote, what to say, and how to avoid being annoying.

---

## Table of Contents

1. [Why Cross-Promotion Works](#why-cross-promotion-works)
2. [The Three Bridges](#the-three-bridges)
3. [Bridge 1: Content to Templates](#bridge-1-content-to-templates)
4. [Bridge 2: Templates to Content](#bridge-2-templates-to-content)
5. [Bridge 3: Content to Merch (and Back)](#bridge-3-content-to-merch-and-back)
6. [Bridge 4: Templates to Merch](#bridge-4-templates-to-merch)
7. [Email Cross-Sell Sequences](#email-cross-sell-sequences)
8. [Timing: When to Cross-Promote](#timing-when-to-cross-promote)
9. [Audience Overlap Analysis](#audience-overlap-analysis)
10. [Anti-Patterns](#anti-patterns)
11. [Measurement Framework](#measurement-framework)

---

## Why Cross-Promotion Works

The three streams share an audience — technical professionals, creators, and builders who value efficiency and identity. Cross-promotion works because it's not selling to strangers; it's offering additional value to people who already trust you.

**The compounding effect:**
```
Month 1:  [Templates] → standalone sales
Month 3:  [Templates] + [Content] → articles drive template discovery
Month 6:  [Templates] + [Content] + [POD] → community identity reinforces all three
Month 12: Flywheel → each stream feeds the others without additional effort
```

**Key insight:** Cross-promotion is not advertising. It's **contextual relevance**. A reader finishing a Kubernetes debugging article who sees "I packaged my best debugging prompts into a kit" isn't being sold to — they're being helped.

---

## The Three Bridges

Every pair of streams has a natural bridge — a transition that feels helpful rather than promotional:

```
                    CONTENT
                   /       \
        Bridge 1  /         \  Bridge 3
        (funnel) /           \ (community)
               /               \
        TEMPLATES ←——————————→ MERCH
                   Bridge 4
                   (identity)
```

| Bridge | Direction | Mechanism | Conversion Rate |
|--------|-----------|-----------|-----------------|
| 1 | Content → Templates | Tutorial → "I packaged this into a product" | 2-5% of article readers |
| 2 | Templates → Content | Product readme → "Get weekly tips" | 8-15% of buyers |
| 3a | Content → Merch | Newsletter → "Show your [niche] pride" | 0.5-2% of subscribers |
| 3b | Merch → Content | Packaging/inserts → newsletter signup | 3-8% of buyers |
| 4 | Templates → Merch | Post-purchase → "Rep the community" | 1-3% of buyers |

---

## Bridge 1: Content to Templates

The highest-ROI bridge. Your articles demonstrate expertise; templates let readers shortcut to results.

### Tactic 1.1: The Tutorial Funnel

Write a tutorial that solves a problem manually, then offer a template that automates it.

**Pattern:**
1. Write a genuine, complete tutorial (no gating, no "subscribe for the rest")
2. At the end, after delivering full value: "I use a set of prompts that handle this automatically. I've packaged them as [Product Name] if you want to skip the manual steps."
3. Link to product with a subtle CTA — not a banner ad, just a sentence

**Example:**
> *"Debugging Production Kubernetes: A Systematic Approach"*
> ...full article with real debugging strategies...
> At the bottom: "I've distilled this into 15 structured prompts that walk you through each diagnostic step. The [K8s Debugging Prompt Kit](link) saves me about 30 minutes per incident."

**Why it works:** The article proved your competence. The template offer is congruent — same person, same topic, just packaged differently.

**Conversion benchmark:** 2-5% of article readers who reach the CTA click through; 10-20% of click-throughs purchase.

### Tactic 1.2: The Content Series Seed

Plan a 4-6 article series where the final article's natural conclusion is a product.

**Pattern:**
1. Article 1-3: Deep technical coverage of a topic area
2. Article 4: "How I automated [topic]" — introduces your tool/template
3. Follow-up: Product launch email to newsletter subscribers who engaged with the series

**Example:**
- Week 1: "Understanding CI/CD Pipeline Bottlenecks"
- Week 2: "5 Patterns for Faster Docker Builds"
- Week 3: "Monitoring CI/CD with Custom Dashboards"
- Week 4: "The DevOps Prompt Kit: 15 Prompts I Use Daily" (product launch)

### Tactic 1.3: The Footnote Method

For articles where a template exists but isn't the focus: add a single footnote-style mention.

**Pattern:**
> *Footnote: If you do this frequently, I've packaged [related prompts/templates] at [link]. But everything you need is in this article.*

**Why it works:** The "everything you need is in this article" removes sales pressure. People who want convenience will click; others don't feel manipulated.

---

## Bridge 2: Templates to Content

Template buyers are your most qualified content subscribers. They've already paid you — they trust you.

### Tactic 2.1: The Post-Purchase Newsletter Hook

Every template product should include a "stay updated" pathway to your newsletter.

**Where to place it:**
- **In the product readme/guide:** "For weekly tips on [topic], including updates to this template: [newsletter link]"
- **In the Gumroad post-purchase page:** Thank you message with newsletter CTA
- **In a follow-up email (Gumroad allows this):** 3 days after purchase, "Here's a bonus tip for getting more out of [product]" + newsletter CTA

**Example readme section:**
```markdown
## Stay Updated

I publish weekly deep-dives on [topic area] including:
- New prompt techniques as AI models evolve
- Use cases and workflows from other buyers
- Early access to new products

Subscribe at [newsletter link] (free tier available).
```

**Conversion benchmark:** 8-15% of buyers subscribe to newsletter.

### Tactic 2.2: The Update Email

When you update a product, email existing buyers. Include newsletter CTA.

**Pattern:**
- Subject: "[Product Name] v1.2 — 3 new prompts added"
- Body: Describe what's new, link to download update, CTA for newsletter at bottom
- Tone: Helpful update, not a sales pitch

### Tactic 2.3: The Bundle Tease

In product documentation, mention other products as "see also" — not upsells, related resources.

**Pattern:**
> "If you're also working on [adjacent topic], the [Other Product] covers that workflow. But for [this topic], you're all set with what's here."

---

## Bridge 3: Content to Merch (and Back)

The weakest individual bridge, but important for community building. Content subscribers who wear your merch become walking referrals.

### Tactic 3a.1: The Identity Drop

In your newsletter, occasionally mention merch as an identity signal — not as a purchase.

**Pattern (1x per month max):**
> "Side note: a few of you asked about the [logo/phrase] from my [article/video]. I put it on a shirt: [link]. Not trying to sell you a t-shirt — but if you're the kind of person who'd wear 'I debug in prod' to the office, it exists."

**Why it works:** Self-selection. The people who buy are the people who would evangelize you anyway.

### Tactic 3a.2: The Milestone Celebration

When your newsletter hits a milestone (100, 500, 1000 subscribers), release a limited-edition design.

**Pattern:**
- Design references an inside joke from the newsletter
- Limited-time availability (2 weeks)
- Mention in newsletter: "We hit [milestone]. I made a thing to mark it."

### Tactic 3b.1: The Merch-to-Newsletter Bridge

Include newsletter signup info on product packaging or in the Redbubble/store product description.

**Pattern (product description):**
> "Designed by [your name], who writes about [topic] at [newsletter link]. New designs drop in the newsletter first."

**Pattern (physical insert, Printful only):**
- Small card included with shipment: "[Your brand] — Weekly [topic] insights. [URL]"

---

## Bridge 4: Templates to Merch

The weakest direct bridge, but viable when your template community develops identity.

### Tactic 4.1: The Community Merch Drop

After 50+ template sales, you have a community. Give them something to wear.

**Pattern:**
- Design a shirt/sticker referencing the template's domain (not the product itself)
- Mention in post-purchase flow: "Rep the [community noun] — [link]"

**Example:** A DevOps prompt kit → "I kubectl in production" sticker

### Tactic 4.2: The Logo Sticker Giveaway

Include a free digital sticker download (PNG) with every template purchase. Physical version available on your POD store.

---

## Email Cross-Sell Sequences

### Sequence A: New Newsletter Subscriber (7 emails over 21 days)

| Day | Email | Cross-Sell Element |
|-----|-------|--------------------|
| 0 | Welcome + what to expect | None — deliver value first |
| 3 | Best article from archive | None |
| 7 | New article or tip | Footnote mention of relevant template |
| 10 | Deep-dive exclusive content | None |
| 14 | "What I'm working on" update | Mention product in development |
| 18 | New article with tutorial | CTA for related template at bottom |
| 21 | "Resources I recommend" roundup | Include your own products alongside others |

**Rules:**
- First 2 emails: ZERO cross-sell. Establish trust.
- Cross-sell is always at the bottom, never the headline
- Never more than 1 product mention per email
- Always provide standalone value even without the product

### Sequence B: Post-Template-Purchase (3 emails over 10 days)

| Day | Email | Purpose |
|-----|-------|---------|
| 0 | Purchase confirmation + quick start guide | Value delivery |
| 3 | "3 tips for getting more out of [product]" | Deepen usage + newsletter CTA |
| 10 | "What are you building?" check-in | Engagement + "related products" if relevant |

### Sequence C: Newsletter to Paid Tier (4 emails over 14 days)

| Day | Email | Content |
|-----|-------|---------|
| 0 | Free article teaser → "Full version for paid subscribers" | Show what they're missing |
| 4 | Exclusive data or research preview | Demonstrate paid-tier quality |
| 8 | "What paid subscribers got this month" summary | Social proof of value |
| 14 | Direct ask: "Here's what the paid tier includes" | Clear value proposition + pricing |

---

## Timing: When to Cross-Promote

### Too Early (Don't Do This)

| Stream State | Why Not |
|--------------|---------|
| 0 subscribers, 0 products | Nothing to cross-promote |
| Newsletter < 50 subscribers | Too few for merch to matter |
| 1 template, 0 articles | No content context for the template |
| First article just published | Earn trust before selling |

### Ready to Start

| Signal | Bridge to Activate |
|--------|-------------------|
| 3+ published articles + 1 template product | Content → Templates (Bridge 1) |
| 10+ template sales | Templates → Content (Bridge 2) |
| 200+ newsletter subscribers | Content → Merch (Bridge 3a) |
| 50+ template sales + active community | Templates → Merch (Bridge 4) |
| First Redbubble sale | Merch → Content (Bridge 3b) |

### Optimal Cadence

| Cross-Promotion Type | Maximum Frequency |
|---------------------|-------------------|
| Template mention in article | 1 per article (at the end) |
| Product mention in newsletter | 1 per issue, below the fold |
| Merch mention in newsletter | 1 per month |
| Newsletter CTA in product docs | Always present (passive) |
| Post-purchase email sequence | Once per customer per product |
| "New product" announcement to full list | 1 per product launch (max 2/month) |

---

## Audience Overlap Analysis

### Understanding Your Segments

Not all subscribers/customers are the same. Map them:

```
ALL SUBSCRIBERS
├── Free newsletter only (70-80%)
│   ├── Active readers (40%) → Target for template CTAs
│   ├── Passive/lurking (30%) → Re-engage or let be
│   └── Never opened (10-20%) → Prune after 90 days
├── Paid newsletter (5-15%)
│   └── Most likely template buyers → Cross-sell directly
├── Template buyers (10-20%)
│   ├── Also subscribed (50%) → Full flywheel
│   └── Purchase-only (50%) → Newsletter hook needed
└── Merch buyers (2-5%)
    └── Highest-identity segment → Community ambassadors
```

### Segment-Specific Tactics

| Segment | Best Cross-Sell | Why |
|---------|----------------|-----|
| Active free readers | Template (relevant to articles they read) | Trust established, need demonstrated |
| Paid subscribers | Templates at discount | Already paying you, highest trust |
| Template buyers (not subscribed) | Newsletter (post-purchase) | Warm audience, easy conversion |
| Template buyers (subscribed) | New products, merch, paid tier | Full trust, proven spending |
| Merch buyers | Newsletter | Identity-invested, will engage |

---

## Anti-Patterns

### What Kills Cross-Promotion

| Anti-Pattern | Why It Fails | Instead |
|--------------|-------------|---------|
| **Leading with the sell** | First email mentions a product → spam signal | Deliver 2-3 pure-value touchpoints first |
| **Every article is a funnel** | Readers feel manipulated → unsubscribe | Mix genuine articles (no CTA) with promotional ones (70/30) |
| **Banner ads in newsletter** | Feels like a billboard, not a person | Inline text mentions, conversational tone |
| **"Buy my stuff" social posts** | Ignored by algorithms, annoying to followers | Share the content; let the funnel work |
| **Identical cross-sell in every email** | Goes blind after 3rd time | Rotate products and angles |
| **Promoting merch to a technical audience before trust** | "Why is this engineer selling t-shirts?" | Wait until community identity is established |
| **Discounting too early** | Trains audience to wait for sales | Save discounts for bundles or milestones |
| **Cross-promoting unrelated products** | K8s readers don't want sourdough merch | Keep cross-promotion within niche |

### The 70/30 Rule

**70% of your content should have zero promotional intent.** No CTA, no product mention, no cross-sell. Pure value.

**30% can include contextually relevant cross-promotion.** Always at the bottom. Always congruent with the content.

If you find yourself exceeding 30%, you're eroding trust faster than you're building revenue.

---

## Measurement Framework

### Key Metrics Per Bridge

| Bridge | Metric | Target | Tracking Method |
|--------|--------|--------|-----------------|
| Content → Templates | Article-to-purchase rate | 0.5-2% of readers | UTM links per article |
| Templates → Content | Post-purchase subscribe rate | 8-15% of buyers | Gumroad → newsletter tracking |
| Content → Merch | Newsletter-to-merch rate | 0.5-1% per mention | UTM links in newsletter |
| Merch → Content | Insert-to-subscribe rate | 3-5% of orders | Dedicated landing page URL |
| Templates → Merch | Post-purchase merch rate | 1-3% of buyers | UTM in post-purchase email |

### Monthly Cross-Promotion Audit

Run this monthly as part of the portfolio review (see [portfolio-strategy.md](portfolio-strategy.md)):

```markdown
## Cross-Promotion Audit — [Month/Year]

### Bridge Activity
| Bridge | Mentions This Month | Clicks | Conversions | Rate |
|--------|--------------------:|-------:|------------:|-----:|
| Content → Templates | | | | % |
| Templates → Content | | | | % |
| Content → Merch | | | | % |
| Merch → Content | | | | % |
| Templates → Merch | | | | % |

### Content Mix
- Total content pieces published: ___
- Pieces with cross-sell element: ___ (target: <30%)
- Pieces with zero promotional intent: ___ (target: >70%)

### Audience Overlap
- Subscribers who are also buyers: ___% (growing/stable/declining)
- Buyers who are also subscribers: ___% (growing/stable/declining)

### Decisions
- Bridges to activate/deactivate: ___
- Content mix adjustment: ___
- New cross-sell tactics to test: ___
```

### Attribution Model

For tracking which bridge drove a conversion:

1. **UTM parameters on all cross-promotion links**
   - `utm_source=newsletter|product_readme|post_purchase|merch_insert`
   - `utm_medium=email|in_product|packaging`
   - `utm_campaign=[product_name]`

2. **Dedicated landing pages per bridge**
   - `yoursite.com/from-newsletter` → template store
   - `yoursite.com/from-[product]` → newsletter signup
   - `yoursite.com/community` → merch store

3. **Survey on purchase** (if platform supports)
   - "How did you find this?" — Newsletter / Article / Other product / Social

---

*This is the trl-conversion-engineer's core operational manual. For portfolio-level strategy and monthly reviews, see [portfolio-strategy.md](portfolio-strategy.md). For platform pricing and fees, see [platform-comparison.md](platform-comparison.md).*

---

*Version: 0.1.0*
