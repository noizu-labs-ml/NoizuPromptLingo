# Platform Setup — Gumroad

> Step-by-step guide from "decided to sell" to "listing live" on Gumroad. For current pricing and fee comparisons across all platforms, see [conversion-engineer/references/platform-comparison.md](../../conversion-engineer/references/platform-comparison.md).

---

## Table of Contents

1. [Why Start on Gumroad](#why-start-on-gumroad)
2. [Account Setup](#account-setup)
3. [Product Creation](#product-creation)
4. [Pricing Strategy](#pricing-strategy)
5. [Sales Page Optimization](#sales-page-optimization)
6. [Thumbnail & Cover Design](#thumbnail--cover-design)
7. [SEO & Discoverability](#seo--discoverability)
8. [Analytics Setup](#analytics-setup)
9. [First Launch Checklist](#first-launch-checklist)
10. [Post-Launch Operations](#post-launch-operations)

---

## Why Start on Gumroad

Gumroad is the recommended first platform for digital product launches:

- **Zero monthly fee** — You only pay when you sell
- **Built-in Discover marketplace** — Passive traffic from day one
- **Merchant of Record** — Handles VAT/GST/sales tax globally (since Jan 2025)
- **Simple setup** — Product can be live in under an hour
- **Audience tools** — Email, follow system, affiliate program built in

**The tradeoff:** Higher per-transaction fees (10% + $0.50 + payment processing) than alternatives. This is acceptable when you're testing product-market fit. Move to lower-fee platforms after $2K/month.

> For full fee breakdown and comparison with Lemon Squeezy, Stan Store, and Etsy, see [platform-comparison.md](../../conversion-engineer/references/platform-comparison.md).

---

## Account Setup

### Step 1: Create Your Account

1. Go to `gumroad.com` and sign up with email
2. Choose a username that matches your brand/niche (this becomes `[username].gumroad.com`)
3. Verify email

### Step 2: Complete Your Profile

| Field | Guidance |
|-------|---------|
| **Display name** | Your name or brand name (what buyers see) |
| **Bio** | 1-2 sentences: who you are, what you sell, why buyers should trust you |
| **Profile picture** | Professional headshot or clean brand logo (400x400px minimum) |
| **Cover image** | Banner showing your niche/brand (1280x400px recommended) |
| **Social links** | Twitter/X, GitHub, newsletter — builds credibility |

### Step 3: Payment Setup

1. Navigate to Settings > Payments
2. Connect a bank account (direct deposit) or PayPal
3. Gumroad pays out on Fridays for sales through the prior Wednesday
4. Set your country for tax purposes

### Step 4: Tax Information

1. Go to Settings > Tax Info
2. **US residents:** Complete W-9 form
3. **Non-US residents:** Complete W-8BEN form
4. Gumroad handles VAT/GST collection for you (Merchant of Record)
5. You're still responsible for income tax reporting in your jurisdiction

### Step 5: Custom Domain (Optional)

If you want `products.yourdomain.com` instead of `you.gumroad.com`:
1. Settings > Custom Domain
2. Add a CNAME record pointing to `discover.gumroad.com`
3. Wait for DNS propagation (can take 24-48 hours)

---

## Product Creation

### Step 1: Choose Product Type

| Type | Best For | Delivery |
|------|----------|----------|
| **Digital product** | Prompt libraries, templates, guides | File download |
| **Membership** | Subscription template updates | Recurring access |
| **Course** (Gumroad term) | Video + file bundles | Drip content |

For your first AI template product, choose **Digital product**.

### Step 2: Create the Product

1. Dashboard > New Product
2. **Product name:** Clear, benefit-driven (e.g., "The DevOps Prompt Kit: 15 CI/CD Automation Prompts")
3. **Price:** Set using the pricing strategy below
4. **Upload files:**
   - Primary deliverable (ZIP containing prompts/templates)
   - Bonus files (if any — quick-start guide, video walkthrough)
   - Keep total file size under 5GB

### Step 3: Structure Your Deliverable

Recommended file structure inside the ZIP:

```
devops-prompt-kit/
├── README.md                  # Quick start, what's included, how to use
├── prompts/
│   ├── 01-pipeline-diagnosis.md
│   ├── 02-docker-optimization.md
│   ├── ...
│   └── 15-incident-response.md
├── examples/
│   ├── example-output-01.md
│   └── example-output-02.md
├── CHANGELOG.md               # Version history (for future updates)
└── LICENSE.md                  # Usage terms
```

**Rules:**
- README.md is the first thing a buyer reads — make it good
- Each prompt file is self-contained (context, prompt, expected output, variations)
- Include 2-3 real example outputs so buyers know what to expect
- CHANGELOG.md signals you'll update the product (builds trust)

### Step 4: Set Up Content Tab

Gumroad's "Content" tab lets you add rich text to the post-purchase page:

- Quick-start instructions (so buyer doesn't need to unzip immediately)
- Link to a Loom walkthrough video (2-3 minutes)
- Link to your newsletter signup
- Support email/contact

---

## Pricing Strategy

### First Product Pricing

```
Testing the market?     → $27-47  (low friction, high volume potential)
Confident in the niche? → $47-97  (standard for quality digital products)
Premium/comprehensive?  → $97-197 (requires strong positioning + proof)
```

### Pricing Principles

1. **Don't charge too little.** $9 products signal low quality. $27 is the floor for anything substantial.
2. **Price on value, not effort.** "15 prompts that save 2 hours/week" is worth $97 even if they took you a weekend to write.
3. **Round to psychological price points:** $27, $37, $47, $67, $97, $147, $197, $297.
4. **Offer a 30-day money-back guarantee.** This increases conversion more than it increases refunds. Gumroad makes refunds easy.

### Tiered Pricing (Advanced)

Once you have 2+ products, consider bundles:

| Tier | Contents | Price | Anchor Effect |
|------|----------|-------|---------------|
| Single product | 1 template kit | $47 | Base price |
| Bundle (2-3 products) | Multiple kits | $97 | "Save $44" — drives bundle purchase |
| All-access | Everything + future products | $197 | Makes bundle look like the deal |

### Discount Strategy

- **Launch discount:** 20% off for first 48 hours (creates urgency)
- **Bundle discount:** 15-30% off vs buying individually (drives higher AOV)
- **Never discount more than 30%** — it devalues the product
- **No perpetual sales** — time-limited only

---

## Sales Page Optimization

The Gumroad product page IS your sales page. Every field matters.

### Product Description Structure

Write the description in this order:

**1. The Hook (First 2 sentences)**
```
Stop spending hours debugging CI/CD pipelines from scratch.
These 15 battle-tested prompts give you a systematic diagnostic
workflow for any pipeline failure.
```

**2. The Pain (What life looks like without this)**
```
Sound familiar?
- Pipeline fails at 2 AM, you're grep-ing through 500 lines of logs
- Every incident feels like starting from zero
- Junior devs can't debug without a senior hand-holding
```

**3. The Promise (What they get)**
```
This kit gives you:
✓ 15 structured prompts for every stage of CI/CD debugging
✓ Works with Claude, ChatGPT, or any LLM
✓ Each prompt includes context, variables, and expected output format
✓ 3 real-world examples with actual diagnostic output
```

**4. Social Proof (If available)**
```
"Cut our mean time to resolution by 40%." — Staff Engineer, Fortune 500
```

**5. What's Included (Specific inventory)**
```
Inside the kit:
- 15 prompts organized by diagnostic stage (triage → root cause → fix)
- Quick-start README with 5-minute setup
- 3 complete worked examples
- Lifetime updates (v1.2 added Kubernetes-specific prompts)
```

**6. Guarantee**
```
30-day money-back guarantee. If these prompts don't save you time,
I'll refund you — no questions asked.
```

**7. FAQ (Address objections)**
```
Q: Does this work with Claude/ChatGPT/etc.?
A: Yes. All prompts are model-agnostic with notes on optimal models.

Q: What if I need help?
A: Email me at [email]. I respond within 24 hours.
```

### Description Formatting Tips

- Use bullet points and bold for scannability
- Keep paragraphs to 2-3 sentences max
- Add line breaks between sections
- Use checkmarks (✓) for the "what you get" list
- Bold the most important benefit

---

## Thumbnail & Cover Design

Your thumbnail is the first visual impression. On Gumroad Discover and in social shares, it's the only thing people see before clicking.

### Specifications

| Asset | Size | Format |
|-------|------|--------|
| Product thumbnail | 1280 x 720px (16:9) | PNG or JPG |
| Cover image (profile) | 1280 x 400px | PNG or JPG |

### Design Principles

1. **Readable at small size.** Your title must be legible at 200px wide (social preview size).
2. **High contrast.** Dark background + light text OR light background + dark text. Avoid mid-tones.
3. **Minimal elements.** Product name + 1 visual element + your brand. That's it.
4. **No stock photos.** Use clean typography, simple icons, or abstract shapes.
5. **Consistent across products.** Use the same layout/colors across all products for brand recognition.

### Quick Thumbnail Template

```
┌──────────────────────────────────┐
│                                  │
│    [ICON or simple graphic]      │
│                                  │
│    THE DEVOPS PROMPT KIT         │  ← Product name (large, bold)
│    15 CI/CD Automation Prompts   │  ← Subtitle (smaller)
│                                  │
│    ────────────────────          │
│    by [Your Name]                │  ← Author (small)
│                                  │
└──────────────────────────────────┘
```

### Tools for Non-Designers

- **Canva** (free tier) — Use "Digital Product Mockup" templates
- **Figma** (free tier) — More control, steeper learning curve
- **AI generation** — Use DALL-E or Midjourney for abstract backgrounds, then overlay text in Canva

---

## SEO & Discoverability

### Gumroad Discover

Gumroad's built-in marketplace (Discover) drives traffic to products based on:

1. **Tags** — Up to 5 tags per product. Choose carefully.
2. **Category** — Select the most specific relevant category.
3. **Sales velocity** — Products with recent sales rank higher.
4. **Ratings** — 5-star products get promoted.
5. **Description keywords** — Gumroad indexes your full description.

### Tag Strategy

Choose 5 tags that balance volume and specificity:

| Tag Type | Example | Purpose |
|----------|---------|---------|
| **Broad niche** | "DevOps" | Catch-all traffic |
| **Specific niche** | "CI/CD" | Targeted audience |
| **Product type** | "prompts" or "templates" | Product discovery |
| **Use case** | "automation" | Intent matching |
| **Tool/technology** | "Kubernetes" or "Docker" | Specific search matching |

### External SEO

If using a custom domain or linking from your site:

- **Page title:** [Product Name] — [Benefit] | [Your Brand]
- **Meta description:** 155 characters summarizing the product's value proposition
- **Canonical URL:** Your Gumroad product page
- **Backlinks:** Link from your articles, newsletter, GitHub profile

---

## Analytics Setup

### Gumroad Built-in Analytics

Gumroad provides:
- **Views:** Product page visits
- **Sales:** Units sold + revenue
- **Conversion rate:** Sales / views
- **Traffic sources:** Where visitors come from
- **Geographic data:** Where buyers are located

Track weekly:
| Metric | Week 1 | Week 2 | Week 3 | Week 4 |
|--------|--------|--------|--------|--------|
| Views | | | | |
| Sales | | | | |
| Conversion % | | | | |
| Revenue | | | | |
| Refunds | | | | |
| Top source | | | | |

### UTM Parameter Setup

For all links to your product, use UTM parameters:

```
https://you.gumroad.com/l/devops-prompts?utm_source=newsletter&utm_medium=email&utm_campaign=launch
https://you.gumroad.com/l/devops-prompts?utm_source=devto&utm_medium=article&utm_campaign=k8s-tutorial
```

This tells you which content drives sales — critical for knowing where to write more.

### Target Benchmarks

| Metric | Good | Great | Investigate If |
|--------|------|-------|---------------|
| Page conversion rate | 5-10% | 10-20% | <3% |
| Refund rate | <5% | <2% | >10% |
| 5-star rating | >4.0 | >4.5 | <3.5 |
| Repeat buyer rate | >10% | >20% | 0% after 3 months |

---

## First Launch Checklist

### Pre-Launch (1-2 weeks before)

- [ ] Product files finalized, tested, ZIP created
- [ ] Gumroad product page created with all fields completed
- [ ] Sales page description written using the structure above
- [ ] Thumbnail designed and uploaded
- [ ] Price set (with launch discount configured if using one)
- [ ] 5 tags selected
- [ ] Category selected
- [ ] FAQ section addresses top 3 objections
- [ ] 30-day money-back guarantee mentioned
- [ ] Post-purchase content tab configured (quick-start + newsletter CTA)
- [ ] Test purchase completed (use Gumroad's test mode)
- [ ] Download works correctly and files are intact

### Launch Day

- [ ] Publish the product (flip from "Unpublished" to "Published")
- [ ] Share on social media (Twitter/X, LinkedIn, relevant subreddits)
- [ ] Send newsletter announcement (if you have subscribers)
- [ ] Post in relevant communities (be helpful, not spammy)
- [ ] Activate launch discount (if using one)
- [ ] Monitor first 24 hours for any file/purchase issues

### Post-Launch (First Week)

- [ ] Track views, sales, conversion daily
- [ ] Respond to any customer emails within 24 hours
- [ ] Ask first 3 buyers for feedback (email personally)
- [ ] Post a "lessons learned from building this" article (content→template bridge)
- [ ] Assess: on track for 10+ sales in first 30 days?

### Post-Launch (First Month)

- [ ] Weekly metrics review (views, sales, conversion, refunds)
- [ ] Incorporate buyer feedback into v1.1 update
- [ ] Plan next product based on what worked
- [ ] Log everything in `assets/project-tracker.md`

---

## Post-Launch Operations

### Product Updates

When you improve the product:
1. Upload new files to Gumroad (replaces existing)
2. Update CHANGELOG.md inside the ZIP
3. Gumroad notifies existing buyers of the update
4. Post an update note on the product page
5. Consider emailing buyers directly with "what's new"

### Customer Support

- Respond within 24 hours (set an email filter)
- If someone asks a question that 3+ people have asked, add it to the FAQ
- If someone requests a refund, process it immediately — happy ex-customers don't leave bad reviews
- Track common questions — they reveal product improvement opportunities

### When to Raise the Price

| Signal | Action |
|--------|--------|
| Consistent sales at current price + low refund rate | Raise by $10-20 |
| Conversion rate > 15% | Price is too low — raise it |
| Adding significant new content | Raise price + notify buyers they got in early |
| Competitor at higher price with worse product | Match or exceed their price |

### When to Move Off Gumroad

| Signal | Next Platform |
|--------|---------------|
| Revenue > $2K/month (fees are eating margin) | Own site + Stripe or Lemon Squeezy |
| Selling subscriptions/SaaS features | Lemon Squeezy (license keys, API) |
| Need advanced analytics/A/B testing | Own site + custom analytics |
| Multiple products + courses + bookings | Stan Store (flat monthly vs %) |

> See [platform-comparison.md](../../conversion-engineer/references/platform-comparison.md) for detailed fee comparison and migration triggers.

---

*Version: 0.1.0*
