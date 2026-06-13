# SEO Guru Knowledge Base -- Summary

> Condensed reference for LLM-age SEO optimization. For full details, read the numbered source files.
> **Review by:** 2026-07-07

---

## The Dual Paradigm (2026)

Traditional SEO and AI SEO (GEO/AEO/LLMO) are **additive, not competing**. 38% of AI Overview citations come from Google's top 10. AI search engines use live web search -- strong SEO directly powers AI visibility.

## Terminology

| Term | Meaning |
|------|---------|
| **SEO** | Search Engine Optimization -- rank in traditional results |
| **GEO** | Generative Engine Optimization -- get cited in AI-synthesized answers |
| **AEO** | Answer Engine Optimization -- win featured snippets + AI citations |
| **LLMO** | Large Language Model Optimization -- optimize for LLM brand understanding |

> **Note:** File 08 (Ladybugz) uses GEO for "Geographic Engine Optimization" (local SEO). All other files use GEO for "Generative Engine Optimization."

## Three Pillars

1. **Crawlability** -- Can AI bots read your content?
2. **Structure** -- Can AI extract discrete facts?
3. **Authority** -- Does AI trust your brand?

## Critical Numbers

| Metric | Value | Source |
|--------|-------|--------|
| AI Overviews on Google | ~55% of queries (Q1 2026; was ~13% early 2025) | Frase |
| Zero-click searches | 58.5% of US Google | LLMrefs |
| ChatGPT daily queries | 2B+ total (37.5M search-like) | Frase / LLMrefs |
| AI visitor conversion rate | 4.4x organic | Semrush |
| Schema markup citation lift | 28-40% | Averi/Princeton |
| Stats in content visibility lift | 30-40% | Princeton GEO |
| Content freshness decay | ~13 weeks | Frase |
| Perplexity fresh content | 76.4% updated <30 days | Averi |
| Listicle citation share | 32.5% of all AI citations | Averi |
| First 30% of page | 44% of LLM citations | Novara Labs |

> **Stat reconciliation notes:**
> - **ChatGPT queries**: "37.5M daily" (file 01, LLMrefs) = search-like prompts only. "2B+" (file 03, Frase) = all queries. Both valid for different contexts.
> - **AI Overviews**: "~13%" (file 01, LLMrefs, early 2025) → "40%+" (file 07, BrightEdge, mid-2025) → "~55%" (file 03, Frase, Q1 2026). Reflects rapid growth over time. Use ~55% as current.
> - **Schema lift "28-40%"**: consistent across all sources (Averi/Princeton GEO research, KDD 2024).

## Platform Citation Preferences

| Platform | Top Sources | Key Signal |
|----------|------------|------------|
| **ChatGPT** | Wikipedia (47.9%), Reddit (11.3%), G2, Forbes | Encyclopedic authority, comprehensive content |
| **Perplexity** | Reddit (46.7%), YouTube (13.9%), Gartner | Community consensus, freshness (<30 days) |
| **Google AI** | Reddit (21%), YouTube (18.8%), LinkedIn (15.2%) | Traditional ranking + schema markup |
| **Copilot** | Forbes, Gartner, SourceForge | Business publications, enterprise reviews |

## AI Crawler Bots (robots.txt)

Allow: `GPTBot`, `ChatGPT-User`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`, `Bytespider`, `CCBot`, `Anthropic-ai`, `OAI-SearchBot`

## Priority Schema Types

1. **FAQPage** -- highest-impact AEO optimization, maps to user queries
2. **Organization** -- with `@id`, `sameAs`, `knowsAbout` for entity disambiguation
3. **Article/BlogPosting** -- author, dates, publisher for citation attribution
4. **BreadcrumbList** -- hierarchy and topical context
5. **HowTo** -- step-by-step guides
6. **Review/AggregateRating** -- for review platforms like GNP

## Content Structure Rules

- Answer-first: first 1-2 sentences directly answer the heading's question
- Short paragraphs: 2-3 sentences max
- Descriptive headings: questions > vague labels
- Statistics every 150-200 words with source attribution
- Sections: 200-400 words, one concept each
- First 30% of page must be citation-worthy standalone

## Quick-Win Checklist

1. [ ] Unblock AI crawlers (robots.txt + Cloudflare) -- 10 min
2. [ ] Deploy llms.txt at domain root -- 30 min
3. [ ] Add FAQPage schema to key pages -- 1-3 hrs
4. [ ] Restructure top 10 pages answer-first -- 2-4 hrs
5. [ ] Add statistics with source citations -- 2-3 hrs
6. [ ] Add Organization schema with sameAs/knowsAbout -- 1 hr
7. [ ] Set up GA4 AI referral tracking -- 30 min
8. [ ] Baseline AI visibility audit (20 queries across platforms) -- 1 hr

## Measurement

- **Share of Voice**: brand frequency in AI responses (primary metric)
- **AI Referral Traffic**: GA4 filter by chat.openai.com, perplexity.ai, gemini.google.com
- **Citation Count**: which pages cited, how often, across which platforms
- **Content Freshness Score**: page age vs 13-week decay threshold
- **Manual Testing**: 15-20 queries monthly across ChatGPT, Perplexity, Google AI

## Source Files

See [00-sources-index.md](00-sources-index.md) for the full source list with URLs and attribution.
