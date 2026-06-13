---
id: P-007
name: "Nadia Kowalczyk"
slug: "api-developer"
archetype: "The Data Pipeline Builder"
segment: "edge-case"
tags: [api, developer, integration, data-consumer, quality-scores, b2b, creator-tier]
---

# Nadia Kowalczyk — The Data Pipeline Builder

## Demographics
| Field | Value |
|-------|-------|
| **Age** | 28 |
| **Role** | Software engineer / side-project builder |
| **Technical Level** | High |
| **Industry** | Software / AI |
| **Location** | Warsaw, Poland |

## Bio
Nadia builds tools at the intersection of web discovery and AI. Her current project is a personal feed aggregator that surfaces high-quality web content based on topic preferences — think RSS reader but with quality filtering. She's been manually building site allow-lists but realized gotta.cc's quality scores could be the signal layer she needs. She is methodical, reads API documentation thoroughly before touching code, and will immediately notice rate limit design flaws.

## Goals
1. Access quality scores programmatically to filter her aggregator's source pool
2. Query sites by category and minimum score thresholds without scraping
3. Keep her application's site database updated as new sites are added and scores change

## Frustrations
1. Most "quality" data sources aren't queryable — they're just human-curated lists with no score metadata
2. Scraping gotta.cc without an API is brittle and ethically questionable
3. API products in this space often have rate limits that make incremental sync impractical

## Behaviors
- Reads the full API docs before writing a line of code
- Tests edge cases: what happens when a site is removed? what's the delta/changelog endpoint?
- Monitors API response times and will switch to a competitor if reliability degrades
- Posts about tools she's building in tech communities — a positive mention of the API can drive significant developer signups

## Job to Be Done
> "I need a reliable, queryable source of web quality signals so I can build on top of it without rebuilding the curation layer myself."

## Relationship to Product
Nadia starts on Creator tier ($10/mo, API access included) and will upgrade to a higher tier if she needs higher rate limits or bulk export. She is a force multiplier — if she builds something compelling on top of the API and shares it, she drives other developers to the platform. Her API usage patterns will stress-test infrastructure assumptions. She files bug reports, posts in developer forums, and is the persona most likely to submit a GitHub issue if the API behaves unexpectedly.

## Scenarios
1. **Initial Integration** — Nadia reads the API docs, sets up OAuth, and runs her first query: all sites in "Science / Independent Research" with Depth >= 4 and Human Authorship >= 3. She gets 47 results. She integrates them into her aggregator's seed list.
2. **Incremental Sync** — Nadia sets up a nightly cron job that queries the /changes endpoint for the last 24 hours to find newly scored or rescored sites in her tracked categories. She notices the endpoint has no cursor-based pagination and files a feature request.
