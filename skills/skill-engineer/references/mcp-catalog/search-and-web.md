# Category: Search and Web

## Overview
Use tools in this category when a skill needs to fetch live data, scrape structured content, conduct research, or map a website's content. Common skill design scenarios: market intelligence (crawl competitor sites), content publishing (research topics before writing), SEO (audit external link profiles), AI templates (pull live context into prompts).

## MCP Services

| Name | Deployment | Key Features | Security Notes | Maturity |
|------|-----------|-------------|----------------|----------|
| Tavily MCP | Hosted SSE | Real-time search + extraction + crawling + site mapping | API key required; data routed through Tavily servers | Stable (AgentRank 81.36) |
| Brave Search MCP | Hosted SSE | Independent non-Google index, privacy-focused, official | API key required; Brave's own index, no Google dependency | Stable (official) |
| Exa MCP | Hosted SSE | Semantic/neural similarity search, find-similar-pages | API key required; trained embeddings model | Stable |
| Firecrawl MCP | Hosted SSE / Self-hosted | URL-to-markdown, structured extraction, batch crawl, scrape | API key for hosted; open-source for self-host | Stable (most-starred web research MCP) |
| Jina Reader MCP | Hosted SSE | URL to markdown, free tier, r.jina.ai shortcut | Free tier available; rate limits apply | Stable |
| Apify MCP | Hosted SSE | 10,000+ pre-built scrapers, marketplace actors | API key required; per-run billing | Stable |
| Puppeteer MCP | Local stdio | Browser automation, screenshots, JS execution | Runs locally; official Anthropic MCP | Stable (official) |

### Tavily MCP
- **What it does**: Real-time web search, content extraction, full-page crawling, and site mapping. Returns clean structured results optimized for LLM consumption. AgentRank 81.36 — top-rated for agentic search workflows.
- **Deployment**: Hosted SSE (api.tavily.com); API key required
- **Key features**: Search with relevance scoring, extract specific URLs to markdown, crawl domains breadth/depth-first, generate site maps for structure analysis
- **Security considerations**: All queries and extracted content pass through Tavily's servers. Do not use for scraping authenticated/private content. API key should be stored in env var, not hardcoded.
- **When to use**: Full research pipelines where you need search + extraction + crawl in one tool. Market intelligence skills, content research workflows, competitor analysis. Best when you need all three operations without stitching separate tools.
- **When to avoid**: Privacy-sensitive queries where sending search terms to a third party is unacceptable. Pure static page extraction where Jina Reader's free tier is sufficient. Self-hosted requirements.

### Firecrawl MCP
- **What it does**: Converts any URL to clean markdown, performs structured data extraction with schemas, batch-crawls entire sites, and handles SPAs/JS-rendered content. Most-starred web research MCP on GitHub.
- **Deployment**: Hosted SSE (api.firecrawl.dev) or self-hosted Docker container
- **Key features**: Scrape single URLs, crawl entire domains, batch process URL lists, extract structured JSON with a provided schema, screenshot pages
- **Security considerations**: Hosted version sends URLs and content to Firecrawl servers. Self-hosted version keeps all data local — preferred for proprietary or sensitive target sites. Rate limits apply on free tier.
- **When to use**: When crawl-first workflows are the primary need — building content datasets, auditing site structure, extracting product data. Self-host when data locality matters. Preferred over Tavily when you don't need search and want maximum crawl control.
- **When to avoid**: When you need real-time search (not just crawl). When the target site blocks crawlers aggressively and you need full browser JS execution (use Puppeteer instead).

### Brave Search MCP
- **What it does**: Official Brave Search MCP. Queries Brave's independent search index — built without relying on Google or Bing. Returns web results, news, and local results with privacy by design.
- **Deployment**: Hosted SSE; official Brave API key required (free tier available)
- **Key features**: Independent index not derived from Google, privacy-focused (no cross-site tracking), web + news + local search, goggles for customizing ranking
- **Security considerations**: Queries go to Brave's servers but Brave's privacy policy is stronger than most. No user tracking by default. API key required — store in env var.
- **When to use**: When Google-index bias is a concern (SEO research to see non-Google rankings), when privacy of search queries matters, when you want a second index for cross-validation. Good for skills that must avoid Google API dependencies.
- **When to avoid**: When you need content extraction beyond search snippets (pair with Firecrawl or Jina). When local/maps results are critical (Brave local is less mature than Google).

## CLI Tools

| Name | Install | What It Does | Skill Relevance |
|------|---------|-------------|-----------------|
| Crawl4AI | `pip install crawl4ai` | Open-source Python crawler, self-hosted, handles SPAs, async, no per-request fees | Content extraction at scale without API costs; use for batch processing in skill pipelines |

## Selection Guide

**Full research pipeline (search + extract + crawl):** Use Tavily MCP. Single tool handles the complete workflow — find pages, extract them, map domains.

**Crawl-first, no search needed:** Use Firecrawl MCP. Best structured extraction, self-hostable, most community support. For zero-cost self-hosted at scale, use Crawl4AI CLI instead.

**Privacy-sensitive search:** Use Brave Search MCP. Independent index, stronger privacy posture, official support.

**Semantic / similarity search:** Use Exa MCP. "Find pages similar to X" queries where keyword search fails.

**JS-heavy SPAs or need screenshots:** Use Puppeteer MCP. Runs locally, official, full browser control.

**Free tier, single URL to markdown:** Use Jina Reader MCP. Zero cost for low-volume extraction, simple r.jina.ai/URL shortcut.

**Need a specific scraper (Amazon, LinkedIn, etc.):** Use Apify MCP. 10,000+ pre-built actors for site-specific extraction.
