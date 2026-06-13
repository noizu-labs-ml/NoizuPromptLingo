# Legal Basics for Digital Products

> Licensing, redistribution, refunds, and tax fundamentals for selling digital products online. Actionable guidance for solo creators and small teams.

**Disclaimer:** This document is educational guidance, not legal advice. Laws vary by jurisdiction and change over time. Consult a qualified attorney and/or tax professional for your specific situation. Last reviewed: 2026-03-25.

---

## Table of Contents

- [1. Digital Product Licensing](#1-digital-product-licensing)
  - [1.1 License Types](#11-license-types)
  - [1.2 Choosing Your License](#12-choosing-your-license)
  - [1.3 Writing License Terms](#13-writing-license-terms)
  - [1.4 Enforcement Realities](#14-enforcement-realities)
- [2. Redistribution Policies](#2-redistribution-policies)
  - [2.1 What Redistribution Means](#21-what-redistribution-means)
  - [2.2 Anti-Redistribution Protections](#22-anti-redistribution-protections)
  - [2.3 Platform-Specific Redistribution Rules](#23-platform-specific-redistribution-rules)
- [3. Refund Policies](#3-refund-policies)
  - [3.1 Why You Need a Clear Refund Policy](#31-why-you-need-a-clear-refund-policy)
  - [3.2 Common Refund Models](#32-common-refund-models)
  - [3.3 Platform-Enforced Refund Policies](#33-platform-enforced-refund-policies)
  - [3.4 Handling Refund Requests](#34-handling-refund-requests)
- [4. Tax Basics](#4-tax-basics)
  - [4.1 US Tax Obligations](#41-us-tax-obligations)
  - [4.2 Sales Tax on Digital Goods](#42-sales-tax-on-digital-goods)
  - [4.3 International Considerations](#43-international-considerations)
  - [4.4 Record Keeping](#44-record-keeping)
- [5. Essential Legal Pages](#5-essential-legal-pages)
- [6. Checklist](#6-checklist)

---

## 1. Digital Product Licensing

### 1.1 License Types

When you sell a digital product, you are selling a **license to use** the product -- not ownership of the intellectual property. The license defines what the buyer can and cannot do.

| License Type | What the Buyer Gets | Typical Use | Price Signal |
|-------------|-------------------|-------------|-------------|
| **Personal Use** | Use for themselves, their own projects, not for client work | Templates, personal productivity tools, self-education | $ (base price) |
| **Commercial Use** | Use in work-for-hire, client projects, or products they sell | Templates, prompts, design assets used in client deliverables | $$ (2-5x personal) |
| **Extended/Enterprise** | Unlimited seats, sub-licensing to team members, white-labeling | Teams, agencies, resellers | $$$ (5-20x personal) |
| **Open/Unrestricted** | No restrictions (essentially public domain or CC0) | Community building, lead generation | Free or donation |

### 1.2 Choosing Your License

**For prompt libraries, template packs, and workflow tools:**

The most common and practical approach is a **two-tier model**:

1. **Standard License** (default, included in base price)
   - Personal use: unlimited
   - Commercial use: yes, in projects you create for clients
   - Redistribution: no (cannot resell the templates themselves)
   - Modification: yes (expected -- the buyer adapts them)
   - Number of users: 1 person (the buyer)

2. **Team License** (higher price tier)
   - Everything in Standard
   - Number of users: up to N people (commonly 5, 10, or "unlimited team")
   - Internal sharing within one organization permitted

**For courses and educational content:**

- Standard License: one person, one account, non-transferable
- Team/Cohort License: for companies buying access for multiple employees

**What NOT to overthink:**

- Do not create 5+ license tiers. Two or three is the maximum before buyer confusion sets in.
- Do not try to restrict "inspiration." If someone reads your prompt template and writes their own from scratch, that is not infringement. License what is concrete, not what is conceptual.

### 1.3 Writing License Terms

Your license terms must be **included in the product itself** (a LICENSE.md or README), **displayed on the sales page**, and **linked in the purchase confirmation email**.

**Essential elements:**

```markdown
## License Agreement

By purchasing [PRODUCT], you agree to the following terms:

### What You CAN Do
- Use the [templates/prompts/materials] for personal and commercial projects
- Modify and adapt the materials to fit your needs
- Use the materials in client work you are paid to produce

### What You CANNOT Do
- Redistribute, resell, or share the materials as-is or as part of a competing product
- Claim authorship of the original materials
- Share your account/download link with others (each user needs their own license)

### Team Use
- This license covers ONE individual
- For team use (2+ people), purchase the Team License at [link]

### Updates
- You receive all future updates to this product at no additional cost
- Updates are delivered via [Gumroad library / email / etc.]

### Refund Policy
[See your refund terms -- Section 3]
```

**Keep it plain language.** Legalese alienates buyers. Courts have consistently held that plain-language terms are just as enforceable as formal legal writing, and they reduce disputes because buyers actually read them.

### 1.4 Enforcement Realities

Be honest about what you can and cannot enforce:

**Realistically enforceable:**
- DMCA takedowns on platforms where your product is being resold (Gumroad, Etsy, etc.)
- Cease-and-desist letters for clear-cut redistribution (someone selling your exact product)
- Platform bans (report violators to the marketplace)

**Difficult to enforce:**
- Someone using your prompt templates "inspired by" yours but rewritten
- A buyer sharing their download with a colleague informally
- Use in contexts you cannot observe (internal corporate use)

**Practical approach:** Write clear terms, include the license in the product, and accept that small-scale leakage happens. Focus your enforcement energy on cases where someone is clearly reselling your work for profit. For everything else, the existence of clear terms deters most good-faith buyers from overstepping.

---

## 2. Redistribution Policies

### 2.1 What Redistribution Means

Redistribution is when a buyer takes your product and makes it available to others in a form substantially similar to the original. This includes:

- Reselling the product on another marketplace
- Including the product in a "bundle" they sell
- Uploading the product to a file-sharing service
- Sharing the download link with non-purchasers

Redistribution does **not** include:

- Using your template to create a unique output (a client website built with your design template)
- Referencing or recommending your product publicly
- Creating a derivative work that is substantially transformed

### 2.2 Anti-Redistribution Protections

| Protection | Difficulty | Effectiveness | Notes |
|-----------|-----------|---------------|-------|
| Clear license terms | Easy | Moderate | Deters good-faith violations |
| Watermarks/branding | Easy | Low | Easy to remove; annoys legitimate buyers |
| Unique download links per buyer | Easy (platform-handled) | Moderate | Gumroad, Payhip do this automatically |
| PDF DRM | Medium | Low | Frustrates buyers more than pirates |
| Customer-specific identifiers | Medium | High for tracing | Embed buyer name/email in product files; helps trace leaks |
| DMCA takedowns | Medium | High for platforms | Effective when you find your product on marketplaces |

**Recommended minimum:** Clear license terms + unique download links (platform default) + customer-specific identifier in the product (e.g., a comment in a template file: `Licensed to: {buyer_email}`).

### 2.3 Platform-Specific Redistribution Rules

| Platform | Built-in Protection | Notes |
|----------|-------------------|-------|
| **Gumroad** | Unique download links, limited download count (configurable) | Can set max downloads per purchase |
| **Payhip** | Unique links, PDF stamping (paid plans) | PDF stamping adds buyer name to every page |
| **Etsy** | Unique links, Etsy IP infringement reporting | File delivery via Etsy system |
| **Substack** | Subscriber-only content, no file downloads by default | Content is behind paywall, not downloadable files |

---

## 3. Refund Policies

### 3.1 Why You Need a Clear Refund Policy

- **Legal requirement in many jurisdictions** (EU Consumer Rights Directive requires refund options for digital goods unless the buyer waives this right at purchase)
- **Platform requirement** (Gumroad, Stripe, PayPal all have dispute resolution processes -- having a clear policy reduces chargebacks)
- **Trust signal** (a money-back guarantee increases conversion by reducing purchase risk)
- **Chargeback prevention** (a clear policy displayed before purchase is your strongest defense in payment disputes)

### 3.2 Common Refund Models

| Model | Terms | Best For | Risk |
|-------|-------|----------|------|
| **30-day no questions asked** | Full refund within 30 days, no reason needed | Building trust, launch period | Higher refund rate (5-15%) |
| **14-day with reason** | Refund within 14 days if buyer provides a reason | Established products | Moderate refund rate (3-8%) |
| **No refunds (with exceptions)** | No refunds, but honor duplicates and technical issues | Low-price products ($5-15) | Lowest refund rate, but more chargebacks |
| **Satisfaction guarantee** | Refund if buyer can show they tried and it did not help | Courses, educational content | Requires judgment calls |

**Recommended for most digital products:** 30-day no-questions-asked at launch (builds trust), transitioning to 14-day-with-reason after you have reviews and social proof.

### 3.3 Platform-Enforced Refund Policies

Some platforms have their own refund mechanisms that override or supplement yours:

| Platform | Refund Mechanism | Your Control |
|----------|-----------------|-------------|
| **Gumroad** | Seller sets policy; buyers can request; Gumroad mediates disputes | Full control; you approve/deny |
| **Stripe (direct)** | No built-in refund flow; you handle via dashboard or API | Full control |
| **PayPal** | Buyer protection allows disputes for 180 days | Limited -- PayPal sides with buyers often |
| **Etsy** | Etsy mediates; digital goods generally non-refundable per Etsy policy | Moderate control |

**Important:** PayPal buyer protection is aggressive. If you use PayPal, be generous with refunds -- it is cheaper to refund willingly than to lose a PayPal dispute (which also carries a $20 chargeback fee and damages your seller rating).

### 3.4 Handling Refund Requests

**Process:**

1. Respond within 24 hours (48 max)
2. If within your refund window: refund immediately, no friction
3. If outside your window: use judgment (long-time customers, first purchase, etc. -- err toward generosity)
4. If the buyer downloaded the product: still refund (you cannot "un-download" a digital product; fighting this creates bad reviews)
5. After refunding: revoke access if possible (Gumroad does this automatically)

**Template response:**

```
Hi [Name],

Refund processed — you should see it in your account within 3-5 business days.

No hard feelings. If there's anything specific that didn't work for you, I'd
appreciate the feedback (no obligation).

[Your name]
```

Short, gracious, no guilt. A refunded customer who feels respected may return later or recommend you despite not keeping the product.

---

## 4. Tax Basics

**Disclaimer (repeated for emphasis):** Tax law is jurisdiction-specific, changes frequently, and this section is general guidance only. Consult a tax professional.

### 4.1 US Tax Obligations

If you sell digital products and earn income, you have US federal tax obligations (assuming US residency or citizenship).

**Self-employment basics:**

- Digital product income is **self-employment income** reported on Schedule C (or Schedule C-EZ for simple cases)
- You owe **income tax** (federal + state) AND **self-employment tax** (15.3% for Social Security + Medicare)
- Quarterly estimated tax payments are required if you expect to owe $1,000+ for the year (Form 1040-ES)
- Keep records of all revenue AND expenses (platform fees, software, equipment, etc.)

**W-9 / W-8BEN:**

| Form | Who Files It | When |
|------|-------------|------|
| **W-9** | US persons (citizens, residents) | When a platform requests it (Gumroad, Stripe, etc.) before they pay you |
| **W-8BEN** | Non-US individuals | Same -- certifies you are not a US taxpayer |
| **1099-K** | The platform sends this to you AND the IRS | If you exceed $600 in gross payments in a calendar year |

**Key threshold:** Platforms must issue a 1099-K for $600+ in annual gross payments (as of 2024 IRS rules). This means the IRS knows your revenue. Report it.

### 4.2 Sales Tax on Digital Goods

Sales tax on digital goods is a fragmented, evolving area. The rules depend on where the buyer is located, not where you are.

**US state-level overview:**

- **States that tax digital goods:** Most states now tax digital products (40+ states as of 2025)
- **States that do not:** A shrinking list -- Montana, Oregon, New Hampshire, and Delaware have no general sales tax
- **Nexus:** You have sales tax obligation in states where you have "nexus" (physical presence or, since *South Dakota v. Wayfair* 2018, sufficient economic presence -- typically $100K in sales or 200 transactions in a state)

**Practical reality for small sellers ($0-50K/year):**

Most small digital product sellers are below the economic nexus threshold in most states. However:

- **You are still technically liable** in your home state
- **Platforms may handle this for you:** Gumroad collects and remits sales tax automatically on all sales (this is one of its strongest features for small sellers). Stripe does NOT -- you must handle it yourself or use a service like TaxJar or Avalara.

**Recommendation:** Use a platform that handles sales tax collection and remittance (Gumroad, Paddle, Lemon Squeezy). If you use Stripe directly, integrate with TaxJar or Avalara once you pass $10K/year in revenue.

### 4.3 International Considerations

**EU VAT (Value Added Tax):**

If you sell to EU customers, you must charge VAT regardless of your revenue level. This is the buyer's country's VAT rate (typically 17-27%).

| Approach | Difficulty | Best For |
|----------|-----------|----------|
| **Use a Merchant of Record platform** (Paddle, Lemon Squeezy, Gumroad) | Easy | Best for most sellers -- they handle VAT, remittance, invoicing |
| **Register for EU One-Stop Shop (OSS)** | Hard | Only if selling direct via your own checkout at high volume |
| **Block EU sales** | Easy but costly | Only if EU represents a tiny % and compliance is not worth it |

**UK VAT:** Post-Brexit, the UK has its own VAT regime. Same principle -- use a Merchant of Record platform or register separately.

**Canada GST/HST:** Similar to EU -- digital products sold to Canadian buyers require GST/HST collection above CAD $30K annually.

**Practical recommendation:** If you are a solo creator selling globally, **use a Merchant of Record (MoR) platform**. Paddle, Lemon Squeezy, and Gumroad act as the seller of record, meaning they handle all tax collection, remittance, and compliance. You receive a net payment. This eliminates international tax headaches entirely.

### 4.4 Record Keeping

**Keep these records for at least 7 years:**

- All revenue records (platform dashboards, payout statements)
- All expenses (software subscriptions, equipment, hosting, platform fees)
- Tax forms received (1099-K, W-9 submissions)
- Tax forms filed (Schedule C, quarterly estimates, state filings)
- Refund records
- Invoices issued (if selling B2B)

**Recommended tools:**

| Need | Tool | Why |
|------|------|-----|
| Income tracking | Platform dashboards + spreadsheet | Gumroad/Stripe dashboards are your source of truth |
| Expense tracking | Wave (free) or QuickBooks Self-Employed | Categorizes expenses, generates Schedule C reports |
| Tax filing | TurboTax Self-Employed or a CPA | Worth professional help once you pass $20K/year |
| International tax | Handled by MoR platform | Do not try to manage EU VAT yourself |

---

## 5. Essential Legal Pages

Every digital product storefront needs these pages (or sections on the sales page):

### 5.1 Terms of Use / Terms of Service

What buyers agree to when they purchase. Covers:
- License scope (what they can/cannot do with the product)
- Limitation of liability (the product is provided "as-is")
- Dispute resolution (how disagreements are handled)
- Governing law (which jurisdiction's laws apply)

### 5.2 Privacy Policy

Required by GDPR, CCPA, and most advertising platforms. Covers:
- What data you collect (name, email, payment info)
- Why you collect it (fulfill orders, send updates)
- Who you share it with (payment processor, email platform)
- How buyers can request data deletion

**Even if you only sell through Gumroad:** You still need a privacy policy if you collect emails for a newsletter or use analytics on a landing page.

### 5.3 Refund Policy

Covered in Section 3. Display it:
- On the sales page (below the CTA or in a FAQ section)
- In the purchase confirmation email
- In the product README/documentation

### 5.4 Cookie/Analytics Disclosure

If your landing page uses cookies or analytics (Google Analytics, Plausible, etc.), disclose it. EU law (GDPR) requires opt-in consent for non-essential cookies. Use a cookie banner or, better, use privacy-respecting analytics (Plausible, Fathom) that do not require consent banners.

---

## 6. Checklist

### Before Your First Sale

- [ ] License terms written and included in the product
- [ ] License terms displayed on the sales page
- [ ] Refund policy written and displayed
- [ ] Privacy policy published (even a simple one)
- [ ] Platform tax settings configured (W-9/W-8BEN submitted)
- [ ] Sales tax collection enabled (if platform supports it) or MoR platform chosen
- [ ] Record-keeping system in place (even a spreadsheet)

### Ongoing

- [ ] Quarterly estimated tax payments (if owing $1K+/year)
- [ ] Monthly review of refunds and chargebacks
- [ ] Annual: reconcile platform payouts with tax forms (1099-K)
- [ ] Annual: file Schedule C with federal return
- [ ] Annual: review license terms for needed updates
- [ ] Annual: check for changes in digital goods sales tax laws in your state

---

*Disclaimer: This document provides general educational guidance and does not constitute legal, tax, or financial advice. Laws and regulations vary by jurisdiction and are subject to change. Consult qualified professionals for advice specific to your situation.*

---

*Version: 0.1.0*
