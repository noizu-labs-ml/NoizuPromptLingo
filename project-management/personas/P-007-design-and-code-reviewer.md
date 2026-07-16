---
id: P-007
name: "Sofia Reyes"
slug: "design-and-code-reviewer"
archetype: "The Design & Code Reviewer"
segment: "tertiary"
tags: [code-review, visual-review, github, qa]
---

# Sofia Reyes — The Design & Code Reviewer

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 31 |
| **Role** | Staff Engineer / Design Reviewer |
| **Technical Level** | Advanced |
| **Industry** | Consumer product |
| **Location** | Remote, EU |

## Bio

Sofia reviews both code and visual output — she's as likely to be annotating a screenshot of a generated screen as she is to be commenting on a GitHub pull request. She's usually reviewing an agent's work, not a human's, which changes what she looks for: fewer style nitpicks, more "did this actually do what was asked."

## Goals

1. Leave pixel-anchored comments directly on a screenshot rather than describing a location in prose.
2. Reach a clear verdict per review that downstream automation (or an agent) can act on.
3. Review a GitHub pull request's diff and comments without switching tools.

## Frustrations

1. Screenshot feedback tools that lose the anchor point when the underlying image changes.
2. Reviews with no compiled summary — just a scattered list of comments with no verdict.
3. Needing separate credentials or context to review a GitHub PR versus an in-platform artifact.

## Behaviors

- Drops an overlay comment directly on the coordinates of the issue, not a general "top-left area" note.
- Compiles a review into a single verdict once all overlay comments are addressed or acknowledged.
- Comments on GitHub PRs and issues from the same session as her in-platform reviews.

## Job to Be Done

> "When I'm reviewing an agent's generated screen or code change, I want to anchor feedback precisely and reach a clear verdict, so the next iteration addresses exactly what I flagged."

## Relationship to Product

Sofia's loyalty is entirely about precision — pixel-anchored overlays that survive re-renders, and a compiled verdict she can point to later. She'd stop using the in-platform review flow (and fall back to plain screenshots-in-chat) if overlay anchors drifted or if there were no way to mark a review complete with a definitive outcome.

## Scenarios

1. **Visual review** — Sofia opens a newly rendered screen artifact, drops three overlay comments at specific coordinates, and marks the review "changes requested."
2. **Verdict compile** — Sofia compiles a review's scattered comments into a single summary and attaches it back to the originating ticket.
3. **Cross-tool PR review** — Sofia comments on a GitHub pull request's diff and, in the same sitting, reviews the in-platform artifact the PR was generated from.
