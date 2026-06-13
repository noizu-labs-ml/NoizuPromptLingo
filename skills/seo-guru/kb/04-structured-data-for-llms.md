# Structured Data for LLMs: Schema Markup Guide

> **Sources:**
> - [SiteUp.ai - Structured Data for LLMs](https://siteup.ai/blog/structured-data-for-llms) -- Retrieved 2026-04-07
> - [Walker Sands - Schema Markup for LLM Visibility](https://www.walkersands.com/about/blog/how-can-schema-markup-support-llm-visibility/) -- Retrieved 2026-04-07
> - [Dev.to - Website Visibility for AI](https://dev.to/williamwangai/how-to-make-your-website-visible-to-perplexity-chatgpt-and-google-ai-overviews-17fi) -- Retrieved 2026-04-07
> **Attribution:** SiteUp.ai, Walker Sands (Emma Riley), William Wang
> **Review by:** 2026-07-07
> **See also:** 12 for structured data from a dual SEO+GEO perspective.

---

## Impact Data

- Princeton GEO research: visibility lifts of up to **40%** in generative answers with structured, optimization-aware content
- Google Research: proper Schema implementation drives **25-35% increase in CTR** through enhanced rich snippets
- Pages with structured lists, quotes, and statistics: **30-40% higher visibility** in AI responses

## Primary Schema Types for LLM Visibility

### Organization (Enhanced)

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "@id": "https://example.com/#org",
  "name": "Example Co",
  "url": "https://example.com",
  "sameAs": [
    "https://www.wikidata.org/wiki/Q12345",
    "https://www.linkedin.com/company/example",
    "https://en.wikipedia.org/wiki/Example_Co"
  ],
  "knowsAbout": ["Generative Engine Optimization", "Schema.org JSON-LD"],
  "mentions": [
    {
      "@type": "Organization",
      "name": "Related Entity"
    }
  ]
}
```

**Critical properties:**
| Property | Purpose |
|----------|---------|
| `@id` | Stable entity identifier for disambiguation |
| `sameAs` | Identity anchor -- Wikidata, LinkedIn, Wikipedia URLs |
| `knowsAbout` | Topical expertise declaration |
| `mentions` | Entity co-occurrence for trust borrowing |
| `hasFAQ` | Nested question-answer structure |

### BlogPosting / Article

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Article Title",
  "author": {
    "@type": "Person",
    "name": "Author Name"
  },
  "datePublished": "2026-04-07",
  "dateModified": "2026-04-07",
  "publisher": {
    "@type": "Organization",
    "name": "Publisher Name"
  },
  "wordCount": 2500,
  "keywords": ["keyword1", "keyword2"],
  "articleSection": "Category"
}
```

### FAQPage

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "What is answer engine optimization?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Answer engine optimization is the practice of structuring content so AI platforms cite it when generating responses."
      }
    }
  ]
}
```

**Highest-impact AEO optimization** -- maps directly to user queries.

### BreadcrumbList

Structural aid for navigation and entity relationship mapping within site hierarchy.

### WebSite

Enables SearchAction for query understanding across platforms.

## robots.txt for AI Crawlers

```
# Allow AI crawlers
User-agent: GPTBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: Bytespider
Allow: /

User-agent: CCBot
Allow: /
```

## llms.txt File Format

Place at `/llms.txt`:
- Company name and one-line description
- About section (core offering, target audience, value proposition)
- Key pages with absolute URLs and descriptions
- Citation preference guidelines
- Contact information

Keep under 100 lines, factual language, no marketing jargon. Update when site structure changes.

## Technical Requirements

- **Server-side rendering required** -- AI crawlers cannot execute JavaScript
- Content behind tabs, accordions, dropdowns, sliders is invisible to AI bots
- Content behind logins/paywalls is inaccessible
- Validate schema with Google Rich Results Test
- Minimum 300 words per page

## Validation

Use Google's Rich Results Test for schema eligibility verification and debugging. Ensures markup meets machine-readability standards for both search engines and generative systems.
