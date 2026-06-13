---
id: A-002
name: "Crawler"
slug: "crawler-the-harvester"
archetype: "The Autonomous Data Harvester"
segment: "agent-primary"
agent_type: "autonomous-worker"
tags: [agent, headless, scraping, data-collection, batch, autonomous]
---

# Crawler — The Autonomous Data Harvester

## Agent Profile

| Field | Value |
|-------|-------|
| **Type** | Headless autonomous agent |
| **Interface** | MCP client → browser MCP server (headless mode) |
| **Autonomy Level** | High — executes pre-defined pipelines with minimal supervision |
| **Persistence** | Pipeline-scoped (stateless between runs, state stored externally) |
| **Trust Level** | Medium — full read access, navigation access, no credential access |

## Role

Crawler is the headless automation agent. It drives one or many browser instances to execute data collection pipelines: visit URLs, wait for rendering, extract structured data, handle pagination, retry failures. It's the agent Dr. Osei (P-002) writes pipelines for — the workhorse that runs overnight on a cluster.

## Capabilities

1. **Batch Navigation** — Open URLs from a queue, handle redirects, respect robots.txt
2. **Render Wait** — Wait for JavaScript rendering to complete (network idle, DOM stable)
3. **Structured Extraction** — Query DOM for elements matching selectors/patterns, return as JSON
4. **Pagination Handling** — Detect and follow pagination (next links, infinite scroll, load-more buttons)
5. **Error Recovery** — Retry failed requests, skip permanently broken URLs, log failures
6. **Rate Limiting** — Self-throttle to respect site rate limits and avoid IP blocks
7. **Pipeline Composition** — Chain extraction steps: visit → extract links → visit each → extract content

## Constraints

1. Must respect robots.txt by default (override requires explicit flag)
2. Cannot solve CAPTCHAs — escalates to human or skips
3. Cannot authenticate to sites — only public content unless credentials are explicitly provided
4. Must log every action for auditability (Dr. Osei needs reproducible methodology)
5. Resource-capped: max concurrent tabs, max memory per instance, timeout per page

## Interaction Patterns

- **Pipeline mode**: Receives a job definition (URL list + extraction rules + output format), executes, writes results
- **Supervised mode**: Runs pipeline but pauses on ambiguous situations (unexpected CAPTCHA, login wall, significantly different page structure) and escalates to human
- **Cluster mode**: Multiple Crawler instances coordinate via shared queue, deduplicating work

## Scenarios

1. **Academic data collection** — Dr. Osei's student defines a pipeline: fetch 10,000 news article URLs, wait for JS render, extract headline + body + publication date + author, output as JSONL. Crawler processes the queue overnight, logging each step for reproducibility.
2. **Price monitoring** — A pipeline visits 50 product pages daily, extracts prices, and writes to a time-series database. Crawler handles pagination, retries on network errors, and alerts on structural changes (selector no longer matches).
3. **Link graph construction** — Crawler visits a seed URL, extracts all links, follows them to depth 3, and builds an adjacency list — a web graph for research analysis.
