---
id: US-066
title: "Export Collection as OPML or JSON"
slug: "export-collection-opml-json"
personas: [P-001, P-007, P-008]
epic: "Collections & Lists"
priority: "could-have"
complexity: "S"
tags: [collections, export, opml, json, interoperability, rss]
---

# US-066: Export Collection as OPML or JSON

## User Story

**As a** web nostalgia explorer (P-001),
**I want to** export my collection as an OPML or JSON file,
**So that** I can import my curated list into an RSS reader or share it as a blogroll in the classic web tradition.

## Acceptance Criteria

- [ ] Given I am viewing one of my collections, when I click "Export", then I am presented with format options: OPML and JSON
- [ ] Given I select OPML export, when the file downloads, then it contains one `<outline>` element per site with `text` (site name), `xmlUrl` (RSS feed if known), and `htmlUrl` (site URL)
- [ ] Given I select JSON export, when the file downloads, then it contains an array of objects with fields: name, url, description, score, tags, category, date_added
- [ ] Given a collection is public, when an unauthenticated user visits the collection page, then an "Export" option is available for OPML (supporting the blogroll use case)
- [ ] Given I export a collection, when the file is generated, then the filename includes the collection name and export date

## Notes

OPML export for blogrolls is a key feature for P-001 (Web Nostalgia Explorer) who participates in the IndieWeb/blogroll revival community. RSS feed URLs will only be present when known — the AI scoring pipeline should attempt RSS feed discovery during site indexing. Related: US-060 (create collection), US-065 (manage collection).
