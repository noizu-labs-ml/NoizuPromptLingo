---
id: P-002
name: "Dr. Amara Osei"
slug: "amara-the-researcher"
archetype: "The Systematic Researcher"
segment: "primary"
tags: [researcher, academic, data-collection, web-scraping, accessibility]
---

# Dr. Amara Osei — The Systematic Researcher

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 38-48 |
| **Role** | Computational social scientist / PI |
| **Technical Level** | Intermediate (Python fluent, Rust-curious) |
| **Industry** | Academia / Research |
| **Location** | Toronto, Canada |

## Bio

Dr. Osei studies how misinformation spreads through web ecosystems. Her lab runs large-scale web data collection campaigns that are constantly broken by anti-bot measures, JavaScript-heavy SPAs, and the fragility of headless Chrome. She's tired of maintaining Playwright scripts that break every time a site redesigns. She wants a browser that treats structured data extraction as a first-class operation, not a hack layered on top of a consumer product.

## Goals

1. Collect web data at scale without maintaining brittle scraping infrastructure
2. Have programmatic access to rendered DOM, not just raw HTML
3. Build reproducible research pipelines where "visit page, extract data" is a composable step

## Frustrations

1. Headless Chrome is a resource hog and breaks unpredictably between versions
2. Playwright/Puppeteer scripts are write-once-break-often
3. Anti-bot systems detect headless browsers; she spends more time on evasion than research
4. Can't easily share browsing automation with non-technical collaborators

## Behaviors

- Manages a lab of 4 PhD students and 2 postdocs
- Runs data collection on a university HPC cluster
- Uses Jupyter notebooks for analysis, Python for orchestration
- Publishes reproducible research — automation scripts are part of the paper

## Job to Be Done

> "When I need to collect structured data from 10,000 web pages with rendered JavaScript content, I want a browser I can drive programmatically via standard tooling (MCP), so my data pipelines don't break every browser update and my students can focus on research, not DevOps."

## Relationship to Product

Dr. Osei finds therobotbrowses through a research software engineering newsletter. She'd adopt it for headless data collection first, then potentially as a daily driver if the rendering is good enough. She'd evangelize it in the computational social science community if it solves her reproducibility problem. She'd churn if it can't handle modern JavaScript-heavy sites.

## Scenarios

1. **Data collection campaign** — Dr. Osei's student writes an MCP-based pipeline: navigate to URL → wait for JS render → query DOM for article elements → extract text + metadata → store as JSON. It runs against 10,000 URLs on the cluster overnight.
2. **Reproducible methodology** — For a peer-reviewed paper, Dr. Osei publishes the exact MCP tool calls used to collect data. Reviewers can re-run the pipeline and verify results.
