---
id: US-037
title: "Automatic duplicate bug detection"
personas: [lin-zhao]
domain: bugs
priority: medium
mvp_phase: "v0.3"
---

## User Story

As a **Lin Zhao (Platform Engineer)**, I want the system to automatically detect and flag potential duplicate bug reports before creation so that the bug database stays clean and effort isn't wasted on already-known issues.

## Acceptance Criteria

- [ ] During bug creation, after the title and description are entered, the system performs real-time similarity search against existing open bugs and displays potential duplicates ranked by confidence score
- [ ] Duplicate suggestions show: matching bug title, status, assignee, creation date, and a brief explanation of why the system considers it a match (shared keywords, similar stack traces, same component)
- [ ] The reporter can choose to: link their report as a duplicate (incrementing the original's "reports" count), proceed with creation anyway (overriding the suggestion), or merge their additional context into the existing bug
- [ ] Post-creation, a background agent periodically scans for duplicate clusters that were missed at creation time and flags them for review
- [ ] Duplicate detection uses semantic similarity (not just keyword matching) to catch bugs described in different words but reporting the same underlying issue

## Notes

Duplicate bugs are a governance headache at scale — Lin manages platform-level infrastructure where the same issue gets reported by multiple teams in different terms. Semantic similarity via embeddings is the right approach, but the system must be fast enough for real-time feedback during creation. Consider using the scale-free item model to support "related but not duplicate" links for bugs that share a root cause but manifest differently.
