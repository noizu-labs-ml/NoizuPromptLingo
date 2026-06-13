---
name: trl-print-on-demand
description: >
  Used when user wants to design and sell niche merchandise through trl-print-on-demand fulfillment partners
  including apparel, accessories, stickers, and home goods. Use this skill when
  the user wants to create POD products, generate AI-assisted designs, set up
  a merch store, optimize product listings on Redbubble or similar platforms,
  build a merchandise brand, or monetize design skills — even if they don't say
  "print on demand." Also trigger when users mention t-shirt designs, merch,
  Redbubble, Printful, Printify, TeePublic, or selling physical products without
  inventory.
---

# Print on Demand

Design and sell niche merchandise through print fulfillment partners with zero inventory risk.

## Overview

The Print on Demand (POD) skill generates passive income by designing merchandise (apparel, home goods, accessories) and uploading to fulfillment platforms that handle production, shipping, and returns. Designs earn indefinitely with no per-unit cost until a customer orders.

**Core Value Proposition:**
- Zero inventory cost (print only when ordered)
- Passive income (designs earn indefinitely)
- Brand building (strengthens community identity)
- Minimal operational overhead
- Low barrier to entry

> For niche audience research, see **trl-market-intelligence** (`references/niche-research-templates.md`). For choosing POD vs. other revenue streams, see **trl-monetization-strategy** (`references/assessment.md`).

---

## Product Types and Platforms

### What You Can Sell

| Category | Margins | Volume | Best Platform |
|----------|---------|--------|---------------|
| **T-Shirts/Hoodies** | $5-10 | High | Redbubble, Printify |
| **Mugs/Drinkware** | $3-8 | Medium | Redbubble, Printful |
| **Stickers** | $1-3 | Very High | Redbubble, Printful |
| **Hats/Caps** | $4-8 | Medium | Printful, Printify |
| **Hoodies/Jackets** | $8-15 | Lower | Printful (quality) |
| **Accessories** | $2-6 | High | Redbubble |

### Platform Selection

**Redbubble (Recommended Start)**
- Built-in marketplace with large organic search traffic
- Upload design, Redbubble handles everything
- 10-20% default markup (note: Standard tier takes 50% of earnings; Premium takes 20%; Pro takes 0% -- see platform-comparison.md)
- Zero operational complexity

**Printful / Printify (Custom Brand)**
- Integrate with own store (Shopify, WooCommerce)
- 50-100%+ margin (you control pricing)
- Requires driving your own traffic
- Move here at $1K+/month on Redbubble

---

## Revenue Model

**Pricing Strategy:**
- Redbubble markup: 10-20% above base cost recommended (higher markups incur 50% excess fee on Standard/Premium tiers)
- Printify markup: 50-100%+ (no built-in traffic, higher margins)
- Volume play: High volume + modest margins vs. low volume + high margins

> **Important:** Redbubble's September 2025 tier restructure means Standard accounts lose 50% of earnings as platform fees. Effective margins are much lower than the markup suggests. See `conversion-engineer/references/platform-comparison.md` for full fee breakdown.

**Example Margins:**

| Product | Base Cost | Sell Price | Margin |
|---------|-----------|------------|--------|
| T-shirt | $5 | $19.99 | $8-10 |
| Hoodie | $12 | $39.99 | $15-18 |
| Sticker | $0.50 | $3.99 | $2-3 |

**Target Year 1:** $1,000/month = ~100 items sold/month at $10 avg margin

---

## Design Categories

### By Audience

| Audience | Example Angles | Why It Works |
|----------|---------------|--------------|
| Developers | "127.0.0.1", debugging humor, language-specific | Strong identity, inside jokes |
| Designers | Figma-inspired, design process humor | Community pride |
| Startups | Failure quotes, hustle culture (authentic) | Shared experience |
| Niche professions | Data scientists, DevOps, UX, PMs | Specific pain points |

### Winning Design Formulas

| Formula | Example | Why It Works |
|---------|---------|--------------|
| **Quote + Niche Identity** | "I'm a designer" + visual | Identity affirmation |
| **Problem + Punchline** | "Debugging" + absurd solution | Relatability + humor |
| **Inside Joke** | Localhost references, tech terms | Signals membership |
| **Minimalist Tech** | Simple geometric + concept | Designer appeal |
| **Brutalist Humor** | Intentionally "bad" design | Anti-establishment appeal |

> For detailed niche discovery workflows and product concept generation, see `references/agent-playbook.md`.

---

## Design Quality Standards

### Visual Requirements
- High contrast (readable at thumbnail size)
- Simple layout (not cluttered)
- Professional typography
- Consistent branding within series

### Technical Specifications
- 300 DPI for print
- CMYK color space
- Platform-specific dimensions (see prompt library for details)

### Marketing Requirements
- Clear product preview (mockup on actual product)
- Compelling, keyword-rich title
- Strategic tag selection (discoverable, not spammy)
- Description explaining why someone should buy

> For product-specific resolution specs and prompt templates, see `references/prompt-library.md`.

---

## AI Image Generation Workflow

### Process Summary

1. **Define concept** - audience, joke/message, target emotion
2. **Select style** - kawaii, vintage, minimalist, meme, fine art parody, cartoon, hand-drawn, typography
3. **Generate 5 prompt variations** per concept (different styles, compositions, perspectives)
4. **Select best** per product type (stickers favor kawaii; posters favor fine art)
5. **Refine** - iterate on winning variation with adjustments
6. **Export** - correct resolution and format per platform

### Prompt Structure

```
[Style] + [Subject] + [Action/State] + [Details] + [Technical Requirements]
```

### Key Style Options

| Style | Best For | Audience |
|-------|----------|----------|
| Kawaii/Cute | Stickers, mugs | Younger, gift buyers |
| Vintage/Retro | T-shirts, posters | Hipsters, design-conscious |
| Minimalist Vector | Premium tees, tech accessories | Professionals |
| Meme/Internet | Casual tees, stickers | Gen Z, meme-literate |
| Fine Art Parody | Posters, canvas prints | Art lovers, ironic humor |
| Bold Typography | Statement tees | Message-driven buyers |

> For complete style templates, negative prompt library, and example generation sessions, see `references/prompt-library.md`.

---

## Tagging and SEO Strategy

### Redbubble Tags (max 15)

1. Core niche keyword ("developer", "designer")
2. Specific technology ("python", "react", "figma")
3. Product type ("t-shirt", "hoodie", "mug")
4. Audience stage ("startup", "enterprise", "indie")
5. Humor/vibe ("funny", "minimalist", "vintage")
6. Use case ("gift", "office", "casual")
7-8. Long-tail keywords for uniqueness

### Example Tags: "Debugging Shirt"

developer, debugging, programming, t-shirt, software-engineer, funny-shirt, computer-humor, tech-apparel

### Listing Optimization

- Title: 60-140 characters, front-load keywords
- Description: 200-300 words, hook + what makes it special + CTA
- Categories: Primary + secondary for maximum discovery
- Price: Test different points; compare competitors

> For listing generation templates and batch workflows, see `references/agent-playbook.md`.

---

## Common Design Mistakes

| Mistake | Why It Fails | Fix |
|---------|--------------|-----|
| Tiny text on shirt | Unreadable at distance | Make text 3x larger |
| Too many colors | Expensive to print, cluttered | Stick to 2-3 colors |
| Unclear messaging | People don't get the joke | Add context, make obvious |
| No product mockups | Hard to visualize on product | Use platform mockup tools |
| Trendy designs | Dated in 6 months | Timeless concepts last longer |
| Spammy keywords | Flagged by algorithm | Use natural, relevant tags |

---

## Platform Expansion Path

### Phase 1: Passive Discovery (Redbubble)
- Upload designs, let algorithms work
- No marketing effort needed
- Good for testing which designs resonate
- **Target:** $500/month

### Phase 2: Branded Store (Shopify + Printify)
- Custom branding, higher margins
- Drive traffic via newsletter/content
- More control over customer experience
- **Target:** $1,000+/month

### Phase 3: Multi-Channel
- Keep Redbubble for passive income
- Use branded store for community/premium
- Newsletter exclusively promotes branded version
- **Target:** $2,000+/month

---

## Success Metrics

| Phase | Timeline | Designs | Sales | Revenue |
|-------|----------|---------|-------|---------|
| Launch | First 30 days | 10-20 | 2-5 | First sales |
| Growth | Months 2-3 | 30-50 | 10-20/mo | $100-200/mo |
| Scale | Months 4-12 | 75-100 | 100+/mo | $800-1,200/mo |

**Scale phase signals:**
- Consistent bestsellers (80/20 rule: 20% of designs = 80% of revenue)
- Ready for 2nd platform (branded version)

---

## Cross-Sell Synergies

| With | Synergy |
|------|---------|
| **AI Templates** | Template community = natural audience for branded merch |
| **Content Publishing** | Newsletter audience = built-in buyer pool |
| **Both** | Reader finds blog -> subscribes -> sees merch -> wears shirt -> organic promotion |

---

## Quick Start Checklist

- [ ] Choose target audience
- [ ] Research existing designs on Redbubble (what's selling)
- [ ] Identify underserved design angle
- [ ] Create first 5 designs using AI generation workflow
- [ ] Upload to Redbubble
- [ ] Optimize titles, tags, descriptions
- [ ] Share with relevant communities
- [ ] Track performance using project tracker
- [ ] Remove underperformers after 3 months
- [ ] Create 5 more designs in winning style
- [ ] After $500/month: expand to branded store

> Track all designs, niches, and sales in `assets/project-tracker.md`.

---

## Related Skills

| Skill | When to Invoke | Key File |
|-------|---------------|----------|
| **trl-market-intelligence** | Before choosing a niche -- audience profiling and competition analysis | `references/niche-research-templates.md` |
| **trl-monetization-strategy** | Before choosing POD as your stream -- compare options | `references/assessment.md` |
| **trl-conversion-engineer** | When coordinating POD with other streams -- sequencing, portfolio tracking | `references/platform-comparison.md` |
| **trl-ai-templates** | When your template community is large enough for cross-promotion | `SKILL.md` |
| **trl-content-publishing** | When your newsletter audience can drive merch sales | `SKILL.md` |
| **trl-user-experience-engineer** | When building a branded store or optimizing product pages | `references/outputs/landing-pages.md` |

## Bundled Resources

| File | Type | When to Read |
|------|------|-------------|
| `references/agent-playbook.md` | Reference | Niche discovery, product ideation, listing optimization, batch workflows |
| `references/prompt-library.md` | Reference | AI image generation: style templates, negative prompts, technical specs |
| `assets/project-tracker.md` | Template | Tracking designs, niches, sales, A/B tests, weekly/monthly reviews |

---

*Version: 0.1.0*
