---
name: content-media-engine
description: >
  Research trends, validate topics, generate article ideas, create abstracts, optimize
  content for specific platforms, and generate text-based media assets from .media.prompt
  YAML files via LLM chat completion APIs. Use this skill when the user wants to research
  content opportunities, find trending topics, do keyword research, validate article demand,
  generate article ideas in batch, create article abstracts or outlines, optimize content
  for Dev.to or Substack or Medium, plan a content calendar, design an article series,
  build a content funnel, find the right visualization library for article media, generate
  SVG graphics or illustrations, create Mermaid or PlantUML or Graphviz diagrams, scaffold
  HTML or React pages, produce LaTeX or Typst documents, compose ABC or LilyPond music
  notation, create WaveDrom timing diagrams, author KaTeX math expressions, or create any
  .media.prompt file targeting text-based output -- even if they don't say "content media
  engine." Also trigger when users mention trend research, keyword mining, topic validation,
  article ideation, content pipeline, abstract generation, editorial calendar, cross-posting
  strategy, article diagrams, data visualization for articles, content media types,
  .media.prompt, text_format, render chain, diagram generation, SVG authoring, mermaid
  prompt, LLM-generated markup, text-output media generation, or provider selection for
  media assets.
---

# Content Media Engine

Research-driven content ideation, validation, and abstract creation pipeline for technical publishing, combined with text-based media asset generation via LLM chat completion APIs.

## Overview

This skill provides two complementary capabilities:

1. **Content Strategy Pipeline** -- the operational pipeline for turning domain expertise into publishable content, from initial trend research through validated, platform-optimized article abstracts ready for drafting.
2. **Media Asset Generation** -- authoring `.media.prompt` YAML files that drive LLM providers to produce text-based media: diagrams, vector graphics, markup pages, documents, music notation, and engineering schematics.

- Research trends across web, communities, social media, and video/podcast
- Mine keywords with developer-query, long-tail, and problem-based strategies
- Validate topic demand with scoring rubrics and competitive gap analysis
- Generate article ideas in batch with full metadata and prioritization
- Create platform-optimized abstracts (Substack, Medium, Dev.to)
- Plan content calendars, series, and pillar strategies
- Design conversion funnels from discovery to paid subscribers
- Generate text-based media assets (SVG, diagrams, HTML, documents, music notation) via `.media.prompt` files

## Core Philosophy

1. **Research before creation** — Every article starts with evidence of demand, not intuition
2. **Platform-native optimization** — What works on Dev.to fails on Substack; optimize for the target
3. **Evergreen bias with timely spikes** — 70% searchable evergreen, 30% trending/timely
4. **Competitive differentiation** — If you can't beat existing content, don't write it
5. **Pipeline discipline** — Ideas flow through Research -> Validate -> Ideate -> Abstract -> Calendar

## When to Use This Skill

- **Researching content opportunities** — Trend analysis, community mining, gap identification
- **Doing keyword research** — Developer queries, long-tail mining, problem-based keywords
- **Validating article demand** — Demand scoring, competitive gap analysis, go/no-go decisions
- **Generating article ideas** — Batch ideation, problem-solution mining, series planning
- **Creating abstracts/outlines** — Full abstracts, quick batch abstracts, platform-optimized versions
- **Optimizing for platforms** — Dev.to tags/timing, Substack conversion, Medium SEO
- **Planning content calendars** — Monthly schedules, pillar mapping, cross-posting timelines
- **Designing content funnels** — Discovery -> engagement -> conversion strategies
- **Generating media assets** — SVG, Mermaid, PlantUML, Graphviz, HTML, React/TSX, LaTeX, Typst, ABC, LilyPond, WaveDrom, KaTeX via `.media.prompt` files
- **Authoring .media.prompt files** — Structured YAML that drives LLM providers to produce text-based media
- **Choosing media providers** — Provider and model selection for different format categories

> For strategic guidance on monetization, platform selection, and revenue models, see **content-publishing**.
> For SEO optimization of published content, see **seo-guru**.
> For market validation before committing to a niche, see **market-intelligence**.

## Media Asset Generation

This skill includes a complete system for generating text-based media assets via LLM chat completion APIs. The core idea: you author a `.media.prompt` YAML file describing what you want, an LLM generates the text markup (SVG, Mermaid, LaTeX, etc.), and an optional render chain converts it to a final visual (PNG, PDF, etc.).

**You author the prompt file. The LLM generates the media. The render chain converts it.**

### Supported Formats

| text_format | Category | Output | Render Target | Notes |
|-------------|----------|--------|---------------|-------|
| mermaid | diagram | .mmd | .svg/.png via mmdc | Flowcharts, sequences, ERDs, Gantt |
| plantuml | diagram | .puml | .svg/.png via plantuml | Class, component, activity diagrams |
| graphviz | diagram | .dot | .svg/.png via dot | Dependency graphs, network topologies |
| drawio | diagram | .drawio | Opens in draw.io | XML-based, complex layouts |
| svg | image | .svg | Direct use | Logos, icons, illustrations |
| html | page | .html | .png via puppeteer | Landing pages, dashboards |
| tsx | component | .tsx | .png via puppeteer | React components with Tailwind |
| latex | document | .tex | .pdf via pdflatex | Papers, equations, formal docs |
| typst | document | .typ | .pdf via typst | Modern alternative to LaTeX |
| abc | music | .abc | Render via abcjs | Folk tunes, lead sheets |
| lilypond | music | .ly | .pdf via lilypond | Full scores, parts |
| wavedrom | engineering | .json | .svg via wavedrom | Timing diagrams, protocol signals |
| katex | math | .tex | Inline render | Math expressions, equations |

### Media Generation Workflow

1. User describes the desired asset (diagram, logo, page, etc.)
2. Select the appropriate `text_format` and provider
3. Generate a `.media.prompt` YAML file with system prompt, user prompt, provider config, and output format
4. Run `generate-media-prompt <file>.media.prompt`
5. CLI calls the LLM, writes primary output, runs the render chain

### Provider Selection

Quick rules for choosing the right LLM provider and model:

- **Structured markup** (Mermaid, PlantUML, SVG, LaTeX): use `anthropic` with `claude-sonnet-4-6`
- **Complex architecture** (React/TSX): use `anthropic` with `claude-opus-4-6`
- **Fast/cheap simple diagrams**: use `gemini-chat` with `gemini-2.5-flash`
- **Music notation**: use `gemini-chat` (good syntax adherence)

> For the full decision tree and provider configuration templates, see [references/provider-selection.md](references/provider-selection.md).

### Render Chains

Each text format produces a primary output file. Some formats require a render step to convert to a final visual output (PNG, SVG, PDF).

> For format-specific render chain configurations, see [references/render-chains.md](references/render-chains.md).

### Prompt Templates

Pre-built system prompts and example configurations for each format live in [references/prompt-templates/](references/prompt-templates/). Each template includes a tuned system prompt, recommended provider settings, and a working example `.media.prompt` structure.

### FIM Cross-Reference

Each supported format maps to detailed solution and use-case files in the bundled FIM library:

> For the complete format-to-FIM mapping table, see [references/fim-index.md](references/fim-index.md).
> FIM solutions: `references/fim/solution/{tool}.md`
> FIM use cases: `references/fim/use-case/{category}.md`

### Example Prompts

Working `.media.prompt` files ready to run are available in [assets/example-prompts/](assets/example-prompts/).

## Content Strategy Framework

```
Research ─── Validate ─── Ideate ─── Abstract ─── Calendar ─── Draft
   │            │           │           │            │           │
   │            │           │           │            │           │
  Trends     Demand      Batch      Full/Quick    Monthly    [out of scope]
  Keywords   Compete     Problem    Platform-opt  Series
  Community  Score/Go    Solution   Type-specific Pillars
```

Each phase has dedicated prompt templates in the references. Work left-to-right — skip phases only when demand is already validated (e.g., assigned topic from an editor).

## Pipeline Phases

### Phase 1: Research

Mine multiple sources for content opportunities before committing to any topic.

| Source | Method | Output |
|--------|--------|--------|
| Web search | Trend queries, "People also ask," autocomplete | Trending topics, keyword opportunities |
| Hacker News / Reddit | Community mining for debates, questions, pain points | Discussion-driven article angles |
| Twitter/X | Thread analysis, influencer gaps, hashtag trends | Timely topic signals |
| YouTube / Podcasts | View counts, quality gaps, unanswered discussions | Written-companion opportunities |
| Platform-specific | site:dev.to, site:medium.com, substack search | Platform performance patterns |

> For complete research prompt templates, see [references/research-prompts.md](references/research-prompts.md).

### Phase 2: Validate

Score topic demand before investing writing time.

**Demand Score** (out of 20):

| Factor | Score (1-5) | What to check |
|--------|-------------|---------------|
| Search volume | 1-5 | Google Trends, autocomplete, related queries |
| Community activity | 1-5 | Recent HN/Reddit/SO discussions (past 3-6 months) |
| Competition quality | 1-5 | Top 5 ranking articles — quality gaps found? |
| Timing relevance | 1-5 | Is this topic heating up, stable, or cooling? |

**Decision thresholds:** >12 = proceed, 8-12 = refine angle, <8 = skip.

**Competitive Gap Analysis:** Review top 5 ranking articles for: depth gaps, recency gaps, angle gaps, format gaps, audience gaps.

> For validation prompt templates, see [references/research-prompts.md](references/research-prompts.md) sections 4.1-4.2.

### Phase 3: Ideate

Generate article ideas in batch with full metadata for prioritization.

**Per idea, capture:**
- Title (SEO-optimized)
- Type (tutorial / explainer / opinion / comparison / list / case study / news analysis)
- Search intent and keywords
- Target platform
- Evergreen score (1-10)
- Effort estimate (hours)
- Conversion potential
- 2-3 sentence abstract
- Outline preview (3-5 sections)

**Two ideation modes:**
1. **Batch generation** — 10 ideas across a niche, ranked by priority
2. **Problem-solution mining** — Mine SO/Reddit/GitHub for developer problems, generate articles that solve them definitively

> For ideation prompt templates, see [references/research-prompts.md](references/research-prompts.md) section 5.

### Phase 4: Abstract

Create detailed abstracts that serve as drafting blueprints.

**Three abstract formats:**

| Format | When | Output |
|--------|------|--------|
| **Full abstract** | Single high-priority article | Metadata + audience + outline + differentiators + research list + effort estimate |
| **Quick batch** | Evaluating 5+ ideas | Title + platform + type + keyword + hook + summary + effort + priority |
| **Platform-optimized** | Known target platform | Platform-specific formatting, distribution, engagement tactics |

> For abstract templates, see [references/article-templates.md](references/article-templates.md).

### Phase 5: Plan

Organize abstracts into a publishing schedule.

- **Monthly calendar** — Weekly slots with title, type, platform, keywords, status
- **Content pillar mapping** — Balance across 4-5 pillars, identify underserved areas
- **Series planning** — Multi-part article sequences with cross-linking strategy
- **Cross-posting schedule** — Primary publish date + syndication timing

> For calendar and planning templates, see [references/content-calendar.md](references/content-calendar.md).

## Article Type Templates

Three structural templates for the most common article types:

| Type | Title Pattern | Key Elements |
|------|---------------|--------------|
| **Tutorial** | "How to [OUTCOME] with [TECHNOLOGY]" | Prerequisites, steps, code, pitfalls, next steps |
| **Comparison** | "[A] vs [B]: Which to Choose in [YEAR]" | TL;DR, criteria, head-to-head, decision framework |
| **Analysis** | "Why [CLAIM]" / "The [ADJ] Guide to [TOPIC]" | Thesis, evidence, counter-arguments, takeaways |

> For full fillable templates with required-element checklists, see [references/article-templates.md](references/article-templates.md).

## Platform Optimization

Each platform has distinct requirements for maximizing reach:

| Platform | Key Levers | Optimal Length | Best Posting |
|----------|------------|----------------|--------------|
| **Dev.to** | Tags (max 4), cover image, code quality, engagement hook | 800-2000 words | Tue-Thu, 8-10 AM EST |
| **Substack** | Email subject, preview text, paid conversion CTAs, community | 1500-3000 words | Consistent weekly cadence |
| **Medium** | Publication placement, tags (max 5), reading time (7-10 min), member-only | 1200-2500 words | Publication schedule |

> For detailed platform optimization checklists, see [references/platform-optimization.md](references/platform-optimization.md).

## Conversion Strategy

Design a content funnel that moves readers from discovery to paid subscribers:

| Funnel Stage | Platform | Content Type | Goal |
|--------------|----------|--------------|------|
| **Top (Discovery)** | Dev.to, Medium, SEO | Tutorials, explainers | Awareness, email capture |
| **Middle (Engagement)** | Free Substack | Deeper insights, exclusive tips | Trust, demonstrate expertise |
| **Bottom (Conversion)** | Paid Substack teasers | Advanced content, community | Convert to paid |

## High-Potential Topic Categories

| Category | Examples | Characteristics |
|----------|----------|-----------------|
| **Evergreen** | Git workflows, Docker basics, API design, testing | High search, moderate competition, always relevant |
| **Trending** | New framework releases, AI/LLM dev, cloud updates | Time-sensitive window (days to weeks), first-mover advantage |
| **Underserved** | Niche tool tutorials, legacy modernization, cost optimization | Low competition, loyal following, high enterprise need |

## Tracking

Every article flows through a lifecycle: Idea -> Abstract -> Drafting -> Editing -> Published -> Promoted.

Track per article: ID, status, platform, pillar, dates, URLs, performance metrics (views, reads, likes, comments, shares, conversions), repurposing status.

Maintain an idea backlog with: source, priority, demand signals, competition level, unique angle, keywords, effort, abstract status, next action.

> For fillable tracking templates, see [assets/project-tracker.md](assets/project-tracker.md).

## Media & Visualization Library

This skill bundles a comprehensive **FIM (Fill-in-the-Middle) reference library** with detailed instructions for 173 visualization tools, document formats, and media processing solutions across 13 categories:

| Category | Solutions | Examples |
|----------|-----------|---------|
| Data Visualization | 18 | D3.js, Chart.js, Plotly, Vega-Lite, Matplotlib |
| 3D Graphics | 8 | Three.js, Babylon.js, A-Frame, React Three Fiber |
| Diagramming & UML | 15 | Mermaid, PlantUML, Graphviz, C4, Structurizr |
| Networks & Graphs | 11 | Cytoscape.js, Sigma.js, NetworkX, D3-Force |
| Animation & Creative | 13 | GSAP, Anime.js, P5.js, Lottie, Paper.js |
| Geospatial & Mapping | 11 | Leaflet, Mapbox GL, Deck.gl, OpenLayers |
| Document Processing | 12 | Pandoc, LaTeX, Typst, Sphinx, MkDocs |
| Mathematics | 12 | KaTeX, MathJax, SymPy, TikZ, SageMath |
| Music Notation | 13 | VexFlow, ABC.js, LilyPond, MusicXML |
| Engineering | 11 | WaveDrom, CircuiTikZ, KiCad, SchemDraw |
| Media Processing | 10 | Sharp, FFmpeg-WASM, PDFKit, SheetJS |
| Elixir Livebook | 8 | Kino-VegaLite, Kino-JS, Kino-Plotly |
| Specialized | 10 | Streamlit, Panel, ipywidgets, VTK.js |

Each solution file includes: installation, API overview, code examples, and use-case mappings. Use-case files provide cross-cutting guides (concise + verbose versions) for choosing between solutions.

> For the full media reference index with decision trees, see [references/media-reference.md](references/media-reference.md).
> For the complete inventory, see [references/fim/INVENTORY.md](references/fim/INVENTORY.md).
> For any specific tool, see `references/fim/solution/<tool>.md`.

## Quick Start Guides

### Research a Niche
1. Pick your domain (e.g., "Kubernetes," "React," "DevOps")
2. Run web search research prompt from [research-prompts.md](references/research-prompts.md) section 2.1
3. Mine communities with prompts from sections 2.2-2.4
4. Compile keyword opportunities from section 3
5. Validate top 3 topics with demand scoring from section 4

### Generate a Month of Content
1. Run batch ideation (section 5.1) for 10 ideas
2. Score each with demand validation (section 4.1)
3. Create quick abstracts for top 8 (article-templates section 2)
4. Map to content calendar (content-calendar section 1)
5. Assign to pillars (content-calendar section 2)

### Write One High-Priority Article
1. Validate demand (research-prompts section 4.1)
2. Analyze competition (research-prompts section 4.2)
3. Create full abstract (article-templates section 1)
4. Optimize for target platform (platform-optimization)
5. Add to tracker (project-tracker)

## Reference Guide

| Task | Read These |
|------|-----------|
| **Any research task** | `references/research-prompts.md` |
| **Creating abstracts** | `references/article-templates.md` |
| **Platform optimization** | `references/platform-optimization.md` |
| **Calendar planning** | `references/content-calendar.md` |
| **Tracking articles** | `assets/project-tracker.md` |
| **Content brief intake** | `assets/content-brief.md` |
| **Choosing visualization tools** | `references/media-reference.md` |
| **Specific tool implementation** | `references/fim/solution/<tool>.md` |
| **Media use-case overview** | `references/fim/use-case/<category>.md` |
| **Media provider selection** | `references/provider-selection.md` |
| **Render chain configuration** | `references/render-chains.md` |
| **Format-to-FIM mapping** | `references/fim-index.md` |
| **Media prompt templates** | `references/prompt-templates/<format>.md` |
| **Example .media.prompt files** | `assets/example-prompts/` |

## Related Skills

- **content-publishing** — Strategic guidance: monetization, platform selection, revenue models, audience building
- **seo-guru** — SEO/AEO optimization for published content, schema markup, search ranking
- **market-intelligence** — Niche validation, audience discovery, competitor analysis before committing
- **ai-templates** — Package content expertise as sellable digital products
- **conversion-engineer** — Multi-stream portfolio coordination across content + templates + merch
- **technical-writer** — Prose craft, editing, documentation quality

## Bundled Resources

### References
- [research-prompts.md](references/research-prompts.md) — Complete prompt library for trend research, keyword mining, topic validation, and idea generation
- [article-templates.md](references/article-templates.md) — Abstract creation templates (full, batch, platform-optimized) and article type frameworks (tutorial, comparison, analysis)
- [platform-optimization.md](references/platform-optimization.md) — Platform-specific optimization checklists for Dev.to, Substack, and Medium
- [content-calendar.md](references/content-calendar.md) — Monthly calendar, content pillar mapping, series planning, and cross-posting templates
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows for Claude Code
- [media-reference.md](references/media-reference.md) — Index and decision tree for 173 visualization/media tools across 13 categories
- [provider-selection.md](references/provider-selection.md) — LLM provider and model decision tree for each media format
- [render-chains.md](references/render-chains.md) — Post-processing render chain configurations for all text formats
- [fim-index.md](references/fim-index.md) — Cross-reference mapping from text_format to FIM solution and use-case files

### FIM Library (references/fim/)
Detailed implementation guides for visualization tools, document formats, and media processing:
- [fim/INVENTORY.md](references/fim/INVENTORY.md) — Complete inventory of 208 files with categories and completion status
- `fim/use-case/*.md` — 15 concise + 10 verbose cross-cutting use-case guides
- `fim/solution/*.md` — 173 individual tool/library reference files with API details and code examples

### Prompt Templates (references/prompt-templates/)
Pre-built system prompts and example configurations for each media format:
- `diagram-mermaid.md`, `diagram-plantuml.md`, `diagram-graphviz.md`, `diagram-drawio.md` — Diagram formats
- `svg-illustration.md` — SVG logos, icons, illustrations
- `html-page.md`, `react-component.md` — Pages and components
- `latex-document.md`, `typst-document.md` — Document formats
- `music-abc.md`, `music-lilypond.md` — Music notation
- `wavedrom-timing.md` — Engineering timing diagrams
- `katex-math.md` — Math expressions

### Assets
- [content-brief.md](assets/content-brief.md) — Fillable intake form for capturing content requirements, niche, audience, and goals
- [project-tracker.md](assets/project-tracker.md) — Article lifecycle and idea backlog tracking templates
- [example-prompts/](assets/example-prompts/) — Working `.media.prompt` files (SVG logo, architecture diagram, sequence diagram, landing page, ABC melody)
